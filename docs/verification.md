# Verification: from the V22 manuscript to the R report

**Result:** The versioned research companion was tested in Docker using **R 4.4.2** on 11 November 2026. The tested archive was `0.1.0-rc.1`. Version `0.1.0` preserves its R scripts and tests, input CSVs, synthetic fixture and Arabic reader; it adds the returned report, verification evidence and publication documentation. The candidate archive hash belongs to the original candidate, not to the expanded distribution.

| Evidence | What was checked |
|---|---|
| [V22 source fingerprint](source-fingerprint.json) | SHA-256, byte size, page count and bibliographic identity of the manuscript. The PDF itself is not redistributed. The candidate identifier in this historical record is retained. |
| Manuscript transcription and denominator review | All nine counts, percentages and page locators were compared with V22; the questions were checked against Appendix A. Each aggregate CSV record joins to one dictionary record. For every row, the included count (denominator) plus documented unknown and structurally inapplicable exclusions is 302. |
| [Comparison with an archived study output](reconciliation.md) | All nine numerators, valid denominators and one-decimal percentages agree. The dictionary follows V22 where earlier labels differ for three exclusions. Both outputs come from the same study. |
| [Runtime receipt](../verification/runtime-receipt.json) | The operator's completed server run reported PASS for the R project, nine aggregate rows, and the synthetic example. The acceptance check verified the expected counts/percentages, both languages in the report and all eight counts for the seven invented practice rows. The receipt records the image's local Docker ID; it is not a registry digest or a claim of an independent CI run. |
| [Returned R-generated report](../preview/verified-r-report.html) | On 12 November 2026, the returned HTML was examined directly. All nine rows matched the release input in bilingual labels, numerators, denominators, reported percentages and printed/PDF source locators. File SHA-256: `17023c977909af0d77f3143958ad6f49d71ba81f2e7072810f56bce3100b086f`. |
| [Offline Arabic reader](../preview/results-ar.html) | A separate Python standard-library tool renders the two CSVs as annotated Arabic result cards. This is a historical snapshot with the candidate label; it is not the file produced by R. |

The runtime receipt was prepared from the operator-supplied terminal summary. The returned HTML supplies additional inspectable evidence; the full server logs and hashes of all other generated outputs were not independently retrieved. The checks apply to aggregate arithmetic, presentation and the artificial teaching example. No household-level responses, original inferential analyses, field-platform performance or intervention outcomes were independently tested here.

## Repeat the check

From the project root run the three commands in the [README](../README.md). These commands write the rebuilt report and aggregate-check CSV to `outputs/` and keep the synthetic summary separate. To repeat the additional acceptance checks under R 4.4.2 in a UTF-8 locale, then run `Rscript --vanilla verification/accept-output.R` from that same directory. [The checker](../verification/accept-output.R) records the R version and session information in `outputs/`. You can compare generated output with the [returned report](../preview/verified-r-report.html).

To check the files distributed with the release on a system with GNU coreutils, run `sha256sum -c SHA256SUMS` from the project root. A matching hash shows that a file matches the identified bytes; it does not itself verify source responses or grant access to private materials.
