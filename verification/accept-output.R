# Acceptance check for the exact v0.1.0-rc.1 release.
# Run from the extracted project root after the three original Rscript commands.
# Uses the standard R distribution only. No private records or network access.
options(warn = 2)
check <- function(ok, why) {
  if (!isTRUE(ok)) stop(paste("ACCEPTANCE FAILED:", why), call. = FALSE)
}
check(dir.exists("outputs"), "outputs directory missing")
actual_r <- as.character(getRversion())
writeLines(actual_r, "outputs/r-version.txt", useBytes = TRUE)
writeLines(capture.output(utils::sessionInfo()), "outputs/session-info.txt", useBytes = TRUE)
check(identical(actual_r, "4.4.2"), paste("R 4.4.2 required; saw", actual_r))
check(isTRUE(l10n_info()[["UTF-8"]]), "UTF-8 locale required for bilingual output")
read_csv <- function(path) {
  check(file.exists(path), paste("missing", path))
  utils::read.csv(path, colClasses = "character", check.names = FALSE,
                  stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = "")
}
align_by <- function(d, field, ids) {
  check(field %in% names(d), paste("missing key", field))
  vals <- d[[field]]
  check(length(vals) == length(ids) && !anyNA(vals) &&
        !anyDuplicated(vals) && setequal(vals, ids),
        paste(field, "keys/count do not match release"))
  d[match(ids, vals), , drop = FALSE]
}
num_eq <- function(actual, expect, name, tolerance = 1e-9) {
  v <- suppressWarnings(as.numeric(actual))
  check(length(v) == length(expect) && all(is.finite(v)) &&
        all(abs(v - expect) <= tolerance), paste(name, "values differ"))
}
fields <- function(x, keys) check(all(keys %in% names(x)), "expected columns missing")
indicators <- c("shelter_unfit", "thermal_extreme_always", "dignity_privacy_insufficient",
                "toilet_shared", "greywater_nuisance_sometimes", "night_lighting_unavailable",
                "material_barrier", "storage_below250", "drinking_storage_below250")
numer <- c(214, 111, 224, 196, 77, 135, 121, 117, 265)
denom <- c(302, 302, 302, 302, 131, 302, 302, 297, 279)
pct <- c(70.9, 36.8, 74.2, 64.9, 58.8, 44.7, 40.1, 39.4, 95.0)
a <- align_by(read_csv("outputs/aggregate-check.csv"), "indicator_id", indicators)
src <- align_by(read_csv("data/published_aggregates.csv"), "indicator_id", indicators)
fields(a, c("numerator", "denominator", "reported_pct", "recalculated_pct", "difference_pp", "rounding_check", "label_en", "label_ar"))
fields(src, c("label_en","label_ar"))
num_eq(a$numerator, numer, "numerator")
num_eq(a$denominator, denom, "denominator")
num_eq(a$reported_pct, pct, "reported_pct")
num_eq(a$recalculated_pct, 100 * numer / denom, "recalculated_pct", 5.1e-7)
num_eq(a$difference_pp, 100 * numer / denom - pct, "difference_pp", 5.1e-7)
check(all(a$rounding_check == "within_one_decimal_tolerance"), "aggregate rounding status")
check(identical(a$label_en, src$label_en) && identical(a$label_ar, src$label_ar), "bilingual labels do not match pinned input")
check(all(nzchar(src$label_en)) && all(grepl("[\u0600-\u06ff]", src$label_ar, perl = TRUE)), "empty English or non-Arabic indicator labels")

metrics <- c("total_rows", "eligible_rows", "observed_rows", "observed_zero_rows",
             "unknown_rows", "missing_rows", "not_asked_rows", "not_applicable_rows")
s <- align_by(read_csv("outputs/synthetic-demo-summary.csv"), "measure", metrics)
fields(s, c("count", "evidence"))
num_eq(s$count, c(7, 6, 3, 1, 1, 1, 1, 1), "synthetic summary counts")
check(all(s$evidence == "synthetic_training_only"), "synthetic labels missing")

report <- "outputs/aggregate-report.html"
check(file.exists(report) && file.size(report) > 0L, "HTML report missing or empty")
markup <- rawToChar(readBin(report, "raw", n = file.size(report)))
check(validUTF8(markup), "HTML bytes are not valid UTF-8")
Encoding(markup) <- "UTF-8"
has <- function(text) grepl(text, markup, fixed = TRUE)
check(has('<meta charset="utf-8">') && has('lang="en"') && has('lang="ar" dir="rtl"'), "HTML language/charset metadata")
# The nine labels in this particular pinned release contain no HTML metacharacters.
check(all(vapply(src$label_en, has, logical(1))) && all(vapply(src$label_ar, has, logical(1))),
      "HTML does not contain all nine English and all nine Arabic indicator labels")

cat("OUTPUT_ACCEPTANCE=PASS\nAGGREGATE_ROWS=9\nSYNTHETIC_METRICS=8\nBILINGUAL_LABEL_PAIRS=9\n", sep = "")
