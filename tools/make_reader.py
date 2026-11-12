"""Build the offline Arabic reader from the two public CSVs (Python standard library).
This new convenience tool does not reproduce the original Python analyses."""
import csv
import html
import json
from decimal import Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
def table(name):
    with (ROOT / 'data' / name).open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))
def safe(x):
    return html.escape(str(x), quote=True)
def fail(msg):
    raise ValueError(msg)
def main():
    metadata = json.loads((ROOT / 'docs/source-fingerprint.json').read_text(encoding="utf-8"))
    rows, definitions = table("published_aggregates.csv"), table("indicator_dictionary.csv")
    unique = lambda rs: {r["indicator_id"] for r in rs}
    ids = unique(rows)
    if not rows or len(ids)!=len(rows) or unique(definitions)!=ids or len(definitions)!=len(ids):
        fail("Missing/duplicate dictionary or indicator rows")
    by_id = {d['indicator_id']:d for d in definitions}
    total = len(rows); groups = len({r['domain'] for r in rows})
    blocks=[]
    for i,r in enumerate(rows,1):
        d=by_id[r['indicator_id']]
        a,b,reported=int(r['numerator']),int(r['denominator']),Decimal(r['reported_pct'])
        if not 0<=a<=b or b<=0: fail(r['indicator_id'] + ': invalid counts')
        exact=Decimal(100)*a/b
        if abs(exact-reported)>Decimal('0.05'): fail(r['indicator_id'] + ': percentage mismatch')
        if b+int(d['excluded_unknown'])+int(d['excluded_structural'])!=302:
            fail(r['indicator_id'] + ': denominator accounting mismatch for V22')
        if int(r['pdf_page'])-int(r['printed_page'])!=17: fail('Incorrect chapter 4 page mapping')
        blocks.append(f"""<article id="{safe(r['indicator_id'])}">
        <div class="line"><span class="domain">{safe(d['domain_ar'])} · <bdi>{safe(d['question_id'])}</bdi></span><span class="idx">{i:02d} / {total:02d}</span></div>
        <h3>{safe(r['label_ar'])}</h3><p class="en" lang="en" dir="ltr">{safe(r['label_en'])}</p>
        <div class="measure"><strong dir="ltr">{reported:.1f}%</strong><span> {a} من {b} أسرة</span></div>
        <div class="track" aria-hidden="true"><i style="width:{reported:.1f}%"></i></div>
        <p><b>من دخل في الحساب؟</b> {safe(d['denominator_rule_ar'])}</p>
        <p class="note">{safe(d['interpretation_ar'])}</p>
        <p class="src">النتيجة: ص {safe(r['printed_page'])} (صفحة {safe(r['pdf_page'])} في ملف PDF) · الأداة: ص {safe(d['instrument_printed_page'])}. <bdi lang="en">{safe(r['source_table'])}</bdi></p></article>""")
    style="""*{box-sizing:border-box}html{font-size:17px}body{margin:0;background:#f6f4ed;color:#172f31;font-family:'DejaVu Sans',Tahoma,Arial,sans-serif;line-height:1.72}main{max-width:1080px;margin:auto;padding:24px 28px 48px}header{border-top:7px solid #d9a355;background:#173c40;color:#fff;border-radius:5px;padding:27px 34px 30px}header small{color:#ffddb1}h1{font-size:clamp(1.65rem,4.5vw,2.8rem);line-height:1.42;margin:9px 0}header p{max-width:770px;color:#e1eee8;margin:0}h2{font-size:1.42rem;margin:30px 0 8px}.intro{max-width:900px;margin:0 0 16px}.chips{display:flex;flex-wrap:wrap;gap:8px;margin-top:18px}.chips span{border:1px solid #769592;padding:3px 11px;border-radius:18px;font-size:.8rem}article{background:#fff;border:1px solid #d9ded4;border-radius:4px;padding:18px 20px;break-inside:avoid}article h3{margin:10px 0 4px;line-height:1.5;font-size:1.1rem}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}.domain{color:#11645f;font-size:.83rem;font-weight:bold}.idx{font:12px sans-serif;color:#5b6864;direction:ltr}.line,.measure{display:flex;align-items:baseline;justify-content:space-between;gap:8px}.measure{justify-content:flex-start;gap:16px;margin:9px 0 2px}.measure strong{font-size:1.7rem;line-height:1.2;color:#135e58;font-variant-numeric:tabular-nums}.measure span,.note{font-size:.86rem;color:#42534f}.en{font-size:.8rem;line-height:1.45;color:#536663;text-align:left}.track{height:5px;background:#eceee7;margin:8px 0 12px;border-radius:3px}.track i{display:block;background:#438779;height:100%;border-radius:3px}article p{margin:5px 0;font-size:.89rem}.src{border-top:1px solid #e1e5df;margin-top:11px;padding-top:8px;color:#586661;font-size:.73rem}.wrap{overflow-wrap:anywhere}.panel{border-right:5px solid #c39456;padding:12px 18px;background:#f0ebdf}.ref{background:#e8efea;padding:16px 20px;border-radius:4px;font-size:.9rem}footer{margin-top:26px;border-top:1px solid #cbd3c9;padding:12px 0;color:#455853;font-size:.79rem}code{direction:ltr;unicode-bidi:isolate;overflow-wrap:anywhere}a{color:#126760} @media(max-width:650px){main{padding:12px 12px 30px}header{padding:18px}.grid{grid-template-columns:1fr}article{padding:15px}}@media print{body{background:white;font-size:10pt}main{padding:0}.grid{display:block}article{margin:8pt 0}header{background:white;color:#173c40;padding:10pt}header p,header small{color:#173c40}.chips{display:none}}"""
    doc=f"""<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>المنازل المرنة في غزة | نتائج من الرسالة</title><style>{style}</style></head><body><main><header><small>سليمان محمد سليمان اللوح · الجامعة الإسلامية بغزة</small><h1>كيف وصفت الأسر المشاركة ظروف السكن والخدمات؟</h1><p>تسعة مؤشرات من دراسة المنازل المرنة والمستدامة في غزة. تعرض كل بطاقة عدد الأسر التي اختارت إجابة بعينها، وعدد من دخلت إجاباتهم في حساب النسبة، والموضع الذي يمكن الرجوع إليه في الرسالة.</p><div class="chips"><span>{total} مؤشرات</span><span>{groups} مجالات</span><span>302 أسرة مشاركة</span><span dir="ltr" lang="en">v{safe(metadata['release_candidate'])}</span></div></header>
    <h2>كيف تُقرأ الأرقام؟</h2><p class="intro">جُمعت الاستبانات بين 5 يناير و21 يونيو 2026. اختيرت الأسر قصدياً وبالإحالة، فلا تمثل النسب تقديرات لجميع أسر غزة. تصف المؤشرات ما أفادت به الأسر، وقد تجيب الأسرة نفسها عن عدة أسئلة؛ لا تُجمع النسب معًا ولا تُحوّل إلى درجة مرونة.</p>
    <p class="panel"><b>لماذا يتغير المقام؟</b> حين لا تعرف الأسرة سعة خزانها، تُستبعد إجابتها من نسبة السعة المعروفة. وحين لا تُعيد استخدام المياه الرمادية، لا ينطبق عليها سؤال الإزعاج أصلًا. يظل السببان منفصلين.</p>
    <h2>المؤشرات ومصادرها</h2><section class="grid" aria-label="مؤشرات وصفية">{''.join(blocks)}</section>
    <h2>عن الدراسة وهذا الإصدار</h2><p>اختيرت 26 أسرة من عينة الاستبانة للمقابلات. وقيّم 12 خبيرًا الإطار في مرحلة مستقلة. أبقى الباحث على 15 عنصرًا بعد تعديل تسعة منها وتقييد ستة بشروط صريحة. التقييم الميداني لأثر الإطار خطوة لاحقة.</p>
    <p>أُعيد حساب النسب هنا من البسط والمقام الواردين في الرسالة. لا يحتوي هذا الإصدار على استجابات أسر منفردة، ولا يعيد تشغيل التحليل على السجلات الأصلية. نموذج البيانات الاصطناعية منفصل في الحزمة البرمجية.</p>
    <div class="ref"><b>المرجع:</b><div dir="ltr" lang="en">{safe(metadata['author'])}. (2026). <i>{safe(metadata['title'])}</i>. {safe(metadata['institution'])}. V22, Chapter 4 and Appendix A.</div>لتتبع هذه الصفحات، استخدم ملف الرسالة المؤرخ على غلافه أكتوبر 2026. تُعرض أرقام الصفحات المطبوعة وأرقام قارئ PDF معًا.</div>
    <footer>نسخة مرشحة للإتاحة · 11 نوفمبر 2026 · تقرير ثابت يمكن قراءته دون اتصال. بُني من ملفي المؤشرات وقاموسها داخل مشروع R.</footer></main></body></html>"""
    out=ROOT/'preview'/'results-ar.html'
    out.parent.mkdir(exist_ok=True)
    out.write_text(doc,encoding="utf-8")
    print(f"{len(rows)} aggregates checked; reader: {out.name}")
if __name__ == "__main__":
    main()
