# gazahomes 0.0.1 · R package

**Sulaiman M. S. Allouh** · A small R interface to nine published household indicators and the bilingual question dictionary for the Gaza housing study. The percentages describe the participating households. No participant-level data are distributed.

## Install and reproduce one result

For installation from the [public R-universe repository](https://sulaimanallouh.r-universe.dev/gazahomes), run:

```r
install.packages("gazahomes", repos = "https://sulaimanallouh.r-universe.dev")
```

Alternatively, to work offline, download [the tested source archive](https://github.com/SulaimanAllouh/gaza-resilient-homes-research/releases/download/gazahomes-v0.0.1/gazahomes_0.0.1.tar.gz) first, then choose it from R:

```r
install.packages(file.choose(), repos = NULL, type = "source")
library(gazahomes)
x <- home_indicators()
x[x$indicator_id == "drinking_storage_below250",
  c("numerator", "denominator", "reported_pct")]
stopifnot(nrow(x) == 9L, all(check_indicators()$ok))
```

The drinking-water storage row gives 265/279 = 95.0%: 23 of the 302 surveyed households reported that the capacity was unknown. The dictionary records the denominator rule. Recalculating percentages does not reproduce the individual responses or establish field effectiveness.

## Verification

The owner’s 12 November 2026 development-server receipt records an offline `R CMD check --no-manual` with status OK on R 4.4.2, plus installation and use of the resulting source archive. The verified files were backed up locally and compared with the three review-draft assets (archive, check log and checksum manifest). This is a check of the specified source artifact and environment; it is not a CRAN submission or an R-universe build result.

| File | SHA-256 from the verification receipt |
|---|---|
| gazahomes_0.0.1.tar.gz | `6680da74fa3b5967f9e799c44622e2c4be0e35629154017d8822c131b643b0f3` |
| 00check.log | `08c3959f37da09c7992fd5904d672ea632d4564e673cbbb4e59ba40fdd0b8176` |

## Public installation verification

On 12 November 2026, the [R-universe build](https://github.com/r-universe/sulaimanallouh/actions/runs/43228755647) deployed the package after checks on Linux, Windows, macOS and WebAssembly. A [separate R 4.4.2 session](https://github.com/SulaimanAllouh/sulaimanallouh.r-universe.dev/actions/runs/43229167694/job/131219701903) installed the source from the public R-universe index into an empty library and reproduced the nine checks, including 265/279 for drinking-water storage and 23 unknown responses. The SHA-256 above identifies the GitHub release archive; the repository builds its own distribution from the same tagged source.

## Citation

When using the R package, cite: **Allouh, S. M. S. (2026). *gazahomes: Explore Published Household Indicators from a Gaza Housing Study* (R package version 0.0.1).** [BibTeX](CITATION-0.0.1.bib).

The `citation("gazahomes")` entries in the verified archive identify the [research companion v0.1.0](https://github.com/SulaimanAllouh/gaza-resilient-homes-research/releases/tag/v0.1.0) and the 2026 thesis. Cite the thesis table and page for an empirical finding. The package README and NOTICE retain the candidate wording from the checked build; no package files were changed after verification.

**بالعربية:** عند استخدام الدوال، استشهد بحزمة `gazahomes` وإصدارها `0.0.1`. وعند نقل نتيجة عن الأسر، أضف إحالة إلى جدول الرسالة وصفحته. ملف البيانات وقاموسه مطابقان للمادة المنشورة في الإصدار البحثي `v0.1.0`.
