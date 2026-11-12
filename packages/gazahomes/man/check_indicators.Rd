\name{check_indicators}
\alias{check_indicators}
\title{Check Reported Percentages and Reconcile Survey Denominators}
\usage{
check_indicators(indicators = home_indicators(),
                 dictionary = home_dictionary())
}
\arguments{
\item{indicators}{Data frame with character key \code{indicator_id} and
numeric columns \code{numerator}, \code{denominator}, \code{reported_pct}.
Defaults to the released table. May be a subset with a matching dictionary.}
\item{dictionary}{Data frame with the same set of unique keys and numeric
columns \code{excluded_unknown} and \code{excluded_structural}. Rows
may be in a different order.}
}
\description{
Check whether the reported percentages agree with the published counts to
one decimal place and each denominator plus exclusions sums to the 302
households in the original study. This checks internal arithmetic only; it
does not validate the original field records or data collection.
}
\details{
A difference of up to 0.05 percentage points is allowed, with a small
floating-point tolerance. At an exact rounding midpoint either adjacent
one-decimal value is accepted, as in the upstream release. Invalid input
such as duplicate or unmatched IDs, missing numeric inputs, non-integral
counts, or a numerator greater than its denominator raises an error.
Arithmetically inconsistent but otherwise valid rows return \code{FALSE}.
The function does not test whether edited data are identical to the release.
}
\value{
A data frame in the order of \code{indicators}. Each row contains the ID,
counts and exclusions, the reported and unrounded calculated percentages
(\code{reported_pct}, \code{calculated_pct}), and three logical columns:
\code{rounding_ok}, \code{denominator_ok}, and \code{ok} (both).
}
\examples{
checked <- check_indicators()
all(checked$ok)
checked[checked$excluded_unknown > 0, c("indicator_id", "excluded_unknown")]
}
\seealso{\code{\link{home_indicators}}, \code{\link{home_dictionary}}}
