# Gaza Resilient Homes Research

[الدليل بالعربية](README.ar.md) · [Aggregate table (CSV)](data/published_aggregates.csv) · [Verified R report (HTML)](preview/verified-r-report.html)

**Version 0.1.0 · Research companion by Sulaiman M. S. Allouh.** This project lets readers inspect nine household indicators from a Gaza housing study, trace each to its question and page in the thesis, and check each reported percentage in R. The two CSVs and both reports work offline.

For example, 265 households reported drinking-water storage below 250 litres. Of the 302 surveyed households, 279 reported a capacity category and 23 answered that they did not know it. The appropriate percentage is **265/279 = 95.0%**, rounded to one decimal place. The dictionary explains the denominator and why a stated unknown must not be counted as zero (V22, Table 4.7 and note, printed pp. 82–83; PDF pp. 99–100).

## Explore the findings

| What you want to do | File |
|---|---|
| Read the nine rows in English and Arabic | [R-generated table](preview/verified-r-report.html) |
| Read the results and interpretation in Arabic | [Offline Arabic reader](preview/results-ar.html) |
| Use the figures in your own analysis | [Nine aggregate records](data/published_aggregates.csv) and [companion dictionary](data/indicator_dictionary.csv), joined on `indicator_id` |
| Inspect eligibility rules or check the source | [Data guide](docs/data-guide.md), [three denominator decisions](docs/reconciliation.md), [study provenance](docs/study-provenance.md) |

Download the HTML files and open them locally in a browser. The Arabic reader retains the version label of the snapshot from which it was generated, `0.1.0-rc.1`. The R report is the output returned after the successful execution on 11 November 2026; its contents were checked on 12 November. [Verification record](docs/verification.md).

## Rebuild the report

Open a terminal at the root of the extracted project. Use a standard installation of R; the verified interpreter was **R 4.4.2**, and the project uses no add-on R packages.

```sh
Rscript --vanilla tests/check.R
Rscript --vanilla scripts/build_aggregates.R
Rscript --vanilla scripts/run_synthetic.R
```

The second command writes `outputs/aggregate-check.csv` and `outputs/aggregate-report.html`. The third writes `outputs/synthetic-demo-summary.csv` from [seven invented practice records](examples/README.md). This separate exercise shows how zero, unknown, missing, not asked, and not applicable affect a denominator. No study participant is represented in it. The optional command `python3 tools/make_reader.py` regenerates the Arabic reader using the Python standard library.

## What the study supports

The source is *A Practical Framework for Building Resilient and Sustainable Homes in War-Affected Regions: A Gaza Case Study*, Sulaiman M. S. Allouh, The Islamic University–Gaza (October 2026; manuscript V22). A non-probability sample of 302 households participated in the survey; 26 households from that sample also took part in interviews. Twelve external experts assessed the proposed framework separately.

The nine indicators cover six study domains and describe the participating households. Each row is a marginal count for one response category. The percentages cannot be added together or used to estimate prevalence across Gaza. The project checks the reported counts and produces tables; it does not reconstruct the individual responses or re-run the thesis's inferential analyses. The full thesis, household records, interview materials and private field-platform code are not in this repository.

## Cite and reuse

Cite the thesis and its specific table or page when discussing a finding. Cite the versioned companion when using these scripts, tables or reports. [Citation examples and access scope](docs/access-and-citation.md) · [CITATION.cff](CITATION.cff).

The [license map](LICENSE.md) identifies the MIT scope for code and the CC BY 4.0 scope for the separately identified materials upon authorized publication. It does not extend to underlying participant records or the full thesis.
