\name{home_indicators}
\alias{home_indicators}
\alias{home_dictionary}
\title{Read Published Household Indicators and Their Bilingual Dictionary}
\usage{
home_indicators()

home_dictionary()
}
\description{
Read the two unchanged CSV tables from the Gaza Resilient Homes Research
companion, version 0.1.0. Each table has nine rows, one per indicator.
}
\details{
The non-probability household survey included 302 participating households.
These marginal counts describe the participating households, not population
prevalence. They cannot be joined into household records, combined into a
general resilience score, or used to estimate the causal effect of an
intervention. Unknown answers and structurally inapplicable answers have
different meanings. A single household can contribute to multiple
indicators. Use the dictionary before interpreting a denominator.
}
\value{
\code{home_indicators()} returns a data frame with \code{indicator_id},
English domain and bilingual labels (\code{domain}, \code{label_en},
\code{label_ar}), counts (\code{numerator}, \code{denominator}), the
reported percentage (\code{reported_pct}), and the thesis reference
(\code{source_table}, \code{printed_page}, \code{pdf_page}).

\code{home_dictionary()} returns a data frame with \code{indicator_id},
\code{question_id}, \code{domain_ar}, \code{response_category}, counts of
excluded answers (\code{excluded_unknown}, \code{excluded_structural}),
English and Arabic denominator rules and interpretation notes
(\code{denominator_rule_en}, \code{denominator_rule_ar},
\code{interpretation_en}, \code{interpretation_ar}), and questionnaire
page references (\code{instrument_printed_page}, \code{instrument_pdf_page}).
Use \code{indicator_id} to join them.
}
\source{
Sulaiman M. S. Allouh, Gaza Resilient Homes Research: selected household
indicators, version 0.1.0.
\url{https://github.com/SulaimanAllouh/gaza-resilient-homes-research/releases/tag/v0.1.0}
}
\examples{
a <- home_indicators()
d <- home_dictionary()
q37 <- d[d$question_id == "Q37", ]
a[a$indicator_id == q37$indicator_id,
  c("label_en", "numerator", "denominator", "reported_pct")]
q37[, c("excluded_unknown", "denominator_rule_en")]
}
\seealso{\code{\link{check_indicators}}}
