# gazahomes

مرشّح خاص، الإصدار 0.0.1. تقرأ الحزمة الجداول المجمعة المنشورة لإصدار البحث
v0.1.0 من داخل R دون اتصال بالإنترنت. لا تحتوي على بيانات أسرية فردية،
ولا تعيد تشغيل تحليلات الرسالة الاستدلالية، ولا تمثّل نسبها جميع سكان غزة.

Offline R interface for the nine aggregate indicators and bilingual question
dictionary from Sulaiman M. S. Allouh's public [research companion, v0.1.0](https://github.com/SulaimanAllouh/gaza-resilient-homes-research/releases/tag/v0.1.0).
No contributed R packages are needed. This source is a candidate, not a
published CRAN or R-universe package.

From the parent directory of this source tree on a machine with R:
```sh
R CMD build gazahomes
R CMD check --no-manual gazahomes_0.0.1.tar.gz
R CMD INSTALL gazahomes_0.0.1.tar.gz
```
Or install an already built local source archive in R:
```r
install.packages("gazahomes_0.0.1.tar.gz", repos = NULL, type = "source")
library(gazahomes)
a <- home_indicators()
d <- home_dictionary()
q37 <- d[d$question_id == "Q37", ]
a[a$indicator_id == q37$indicator_id,
  c("label_ar", "numerator", "denominator", "reported_pct")]
q37[, c("excluded_unknown", "denominator_rule_ar")]
stopifnot(all(check_indicators()$ok))
citation("gazahomes")
```

**Q37:** 265 of the 279 households reporting a drinking-water storage capacity
category placed it below 250 litres (95.0%); 23 of the 302 households explicitly
did not know their capacity. The question measures a reported storage
category, not per-person water supply, water quality, or an adequacy standard.

The two CSVs under `inst/extdata` are byte-for-byte releases, not
new observations. Cite the original thesis/table/page when discussing
findings; cite the published companion when using its data. New package code
is MIT; released tables and dictionary are CC BY 4.0. See `inst/NOTICE` and
`inst/licenses/` for attribution and full notices.
