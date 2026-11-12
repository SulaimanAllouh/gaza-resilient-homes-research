# How to read the released tables

Each aggregate row represents a specific response category. The same household can contribute to multiple rows. The nine rows describe different constructs and bases; their percentages are not parts of one whole. The keys are descriptive IDs assigned for this release and are not database IDs. Scope: six domains, one final manuscript. UTF-8; comma delimiter; one header row; a decimal point is the decimal separator.

| File / fields | Meaning |
|---|---|
| Both / indicator_id | Unique release key; exact one-to-one join between tables |
| Aggregate / domain, label_en, label_ar | Domain grouping and plain-language bilingual indicator labels prepared for this release, not verbatim questionnaire text |
| Aggregate / numerator, denominator | Number of participating households selecting the specified response; number included for this item |
| Aggregate / reported_pct | Percentage as printed in V22, to one decimal place. Use 100 × numerator / denominator to check, keeping full precision until the final display. |
| Aggregate / source_table, printed_page, pdf_page | Table or prose locator, printed page, one-based PDF page. Some notes extend to the following page. |
| Dictionary / question_id, instrument_printed_page, instrument_pdf_page | Retained question number and location in Appendix A; different from the location of the reported result |
| Dictionary / domain_ar, response_category | Arabic domain label and the category summarized; this is not an exhaustive response codebook |
| Dictionary / excluded_unknown, excluded_structural | Counts explicitly unknown and excluded, and structurally inapplicable. Zero means no such exclusion needed to account for that published denominator, not necessarily absence of other response categories in the questionnaire. |
| Dictionary / denominator_rule_en, denominator_rule_ar | Why this denominator applies, in English and Arabic |
| Dictionary / interpretation_en, interpretation_ar | What the item measures, how phrasing differs, and what it cannot establish |

**Two denominator examples.** Q37: 265/279 = 94.982…%, displayed as 95.0%; 23 unknown capacity responses excluded. Q40: 77/131 = 58.778…%, displayed as 58.8%; 171 cases were not applicable because greywater was not reused. The 171 are not 171 negative answers. For Q36, do not infer exclusive water use: the English prompt describes the main household storage and the Arabic prompt refers to washing-water storage (printed p. 81, PDF 98). Q38 is the sharing question; it is distinct from Q30, which asks about the type of facility.

**Selection and checking.** Nine broad marginal counts were selected; no location breakdown, rare household profiles, interview excerpts, linkage fields or contingency tables are included. Six rows have denominator 302. The remaining rows account for the enrolled survey households as 131+171, 297+5 and 279+23. Arithmetic and item coverage do not prove that the original responses were entered or interpreted correctly.
