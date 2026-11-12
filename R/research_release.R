# Public-release utilities, created after the dissertation. R + its standard
# distribution only. They read released tables, not a household-level export.

read_release_csv <- function(path) {
  if (!file.exists(path)) stop("Missing input: ", path, call. = FALSE)
  out <- utils::read.csv(path, colClasses = "character", check.names = FALSE,
                        stringsAsFactors = FALSE, na.strings = "",
                        strip.white = TRUE, fileEncoding = "UTF-8")
  names(out) <- sub("^\uFEFF", "", names(out))
  out
}

write_release_csv <- function(x, path) {
  utils::write.csv(x, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}

require_fields <- function(x, fields) {
  if (!is.data.frame(x) || !nrow(x)) stop("Input table must have rows.", call. = FALSE)
  if (anyDuplicated(names(x))) stop("Duplicate input column name.", call. = FALSE)
  absent <- setdiff(fields, names(x))
  if (length(absent)) stop("Missing column(s): ", paste(absent, collapse = ", "), call. = FALSE)
}

complete_text <- function(x) all(!is.na(x) & nzchar(trimws(as.character(x))))
numeric_value <- function(x) suppressWarnings(as.numeric(as.character(x)))

check_aggregates <- function(x) {
  fields <- c("indicator_id", "domain", "label_en", "label_ar", "numerator",
              "denominator", "reported_pct", "source_table", "printed_page", "pdf_page")
  require_fields(x, fields)
  x <- x[fields]
  for (field in fields) {
    if (!complete_text(x[[field]])) stop("Empty value in ", field, ".", call. = FALSE)
  }
  if (anyDuplicated(trimws(x$indicator_id))) stop("Duplicate indicator_id.", call. = FALSE)
  n <- numeric_value(x$numerator)
  d <- numeric_value(x$denominator)
  p <- numeric_value(x$reported_pct)
  if (any(!is.finite(n) | !is.finite(d) | !is.finite(p))) {
    stop("Counts and percentages must be finite numbers.", call. = FALSE)
  }
  if (any(n != floor(n) | d != floor(d) | d <= 0 | n < 0 | n > d)) {
    stop("Need integer counts with 0 <= numerator <= denominator and denominator > 0.", call. = FALSE)
  }
  if (any(p < 0 | p > 100 | abs(10 * p - round(10 * p)) > 1e-8)) {
    stop("Reported percentages must be 0-100 with at most one decimal place.", call. = FALSE)
  }
  raw_pct <- 100 * (n / d)
  # Compare with an unrounded ratio. At an exact 0.05 percentage-point boundary
  # both adjacent one-decimal representations are consistent; do not infer which
  # tie convention the dissertation used. Tiny epsilon absorbs binary arithmetic.
  difference <- raw_pct - p
  bad <- abs(difference) > 0.05 + 1e-9
  if (any(bad)) {
    stop("Reported percentage inconsistent with counts: ",
         paste(x$indicator_id[bad], collapse = ", "), call. = FALSE)
  }
  x$numerator <- n
  x$denominator <- d
  x$reported_pct <- p
  x$recalculated_pct <- round(raw_pct, 6)
  x$difference_pp <- round(difference, 6)
  x$rounding_check <- "within_one_decimal_tolerance"
  x
}

escape_html <- function(x) {
  x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  gsub("'", "&#39;", x, fixed = TRUE)
}

write_aggregate_report <- function(checked, path) {
  # Format a checked table only; escape all human-provided text before writing.
  display_pct <- sprintf("%.1f", checked$reported_pct)
  rows <- vapply(seq_len(nrow(checked)), function(i) {
    sprintf(paste0('<tr><th scope="row"><span>%s</span><br><span class="ar" lang="ar" dir="rtl">%s</span></th>',
                   '<td class="counts">%s / %s</td><td><strong>%s%%</strong>',
                   '<span class="track" aria-hidden="true"><i style="width:%s%%"></i></span></td>',
                   '<td>%s<br>p. %s &middot; PDF %s</td></tr>'),
            escape_html(checked$label_en[i]), escape_html(checked$label_ar[i]),
            checked$numerator[i], checked$denominator[i], display_pct[i], display_pct[i],
            escape_html(checked$source_table[i]), escape_html(checked$printed_page[i]),
            escape_html(checked$pdf_page[i]))
  }, character(1), USE.NAMES = FALSE)
  html <- c('<!doctype html>', '<html lang="en"><head><meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    '<title>Household findings | Gaza Resilient Homes Research</title>',
    '<style>',
    ':root{color-scheme:light}*{box-sizing:border-box}body{margin:0;color:#172c27;background:#f4f2e9;font:1rem/1.55 system-ui,sans-serif}',
    'main{max-width:62rem;margin:2rem auto;background:white;padding:clamp(1rem,4vw,3rem);border-top:.4rem solid #18745e}',
    'h1,h2,p{margin:0 0 .8rem}h1{font-size:clamp(1.7rem,4vw,2.55rem);line-height:1.12}.eyebrow{color:#235a4b;font-weight:bold}',
    '.note{background:#f0f6f2;padding:1rem;margin:1rem 0}table{width:100%;border-collapse:collapse;margin:1rem 0}caption{text-align:left;font-weight:bold}',
    'th,td{padding:.65rem .45rem;vertical-align:top;border-bottom:1px solid #c5d5cf;text-align:left}thead th{background:#e7f0ec}th[scope=row]{width:44%;font-weight:550}',
    '.ar{color:#35584c;font-weight:400;display:inline-block}.counts{white-space:nowrap}.track{display:block;background:#dde8df;height:.4rem;width:min(100%,5.5rem)}',
    '.track i{background:#14705a;height:100%;display:block}.scroll{overflow-x:auto}small{color:#38524a}@media print{main{padding:0;margin:0}.track{display:none}}',
    '</style></head><body><main>',
    '<p class="eyebrow">GAZA RESILIENT HOMES RESEARCH &middot; DISSERTATION V22</p>',
    '<h1>Selected findings among participating households</h1>',
    '<p lang="ar" dir="rtl">نتائج مختارة بين الأسر المشاركة في دراسة المنازل المرنة في غزة</p>',
    '<div class="note">Each row reproduces a reported aggregate and identifies its source. The denominator belongs to that row. Indicators may overlap and do not describe mutually exclusive groups.</div>',
    '<p lang="ar" dir="rtl">يعرض كل سطر عدد الحالات ومقام النسبة وموضعها في الرسالة. قد تتداخل المؤشرات. النسب تخص الأسر المشاركة ولا تمثل تقديرات لجميع أسر غزة.</p>',
    '<div class="scroll"><table><caption>Dissertation aggregates checked against their numerators and denominators</caption>',
    '<thead><tr><th scope="col">Indicator / المؤشر</th><th scope="col">n / N</th><th scope="col">Reported %</th><th scope="col">V22 source</th></tr></thead><tbody>',
    rows, '</tbody></table></div>',
    '<p><small>p. = printed page; PDF = one-based PDF page. The check compares 100 × n/N with the reported percentage (tolerance: 0.05 percentage points plus a numerical epsilon). It confirms arithmetic only. Household-level analyses have not been rerun from participant records in this release.</small></p>',
    '</main></body></html>')
  con <- file(path, open = "w", encoding = "UTF-8")
  on.exit(close(con))
  writeLines(html, con = con)
}

summarise_synthetic <- function(x) {
  fields <- c("example_id", "eligibility", "response_state", "practice_token_count")
  require_fields(x, fields)
  if (!complete_text(x$example_id) || anyDuplicated(x$example_id)) stop("Invalid example IDs.", call. = FALSE)
  states <- c("OBSERVED", "UNKNOWN", "MISSING", "NOT_ASKED", "NOT_APPLICABLE")
  if (!all(x$response_state %in% states) || !all(x$eligibility %in% c("ELIGIBLE", "INELIGIBLE"))) {
    stop("Unrecognised eligibility or response state.", call. = FALSE)
  }
  if (any((x$eligibility == "INELIGIBLE") != (x$response_state == "NOT_APPLICABLE"))) {
    stop("Eligibility and NOT_APPLICABLE must agree in this example.", call. = FALSE)
  }
  observed <- x$response_state == "OBSERVED"
  present <- !is.na(x$practice_token_count) & nzchar(trimws(as.character(x$practice_token_count)))
  if (any(observed != present)) stop("A count is required exactly for OBSERVED records.", call. = FALSE)
  vals <- numeric_value(x$practice_token_count[observed])
  if (any(!is.finite(vals) | vals < 0 | vals != floor(vals))) stop("Invalid observed count.", call. = FALSE)
  data.frame(measure = c("total_rows", "eligible_rows", "observed_rows", "observed_zero_rows",
                         "unknown_rows", "missing_rows", "not_asked_rows", "not_applicable_rows"),
             count = c(nrow(x), sum(x$eligibility == "ELIGIBLE"), sum(observed), sum(vals == 0),
                       sum(x$response_state == "UNKNOWN"), sum(x$response_state == "MISSING"),
                       sum(x$response_state == "NOT_ASKED"), sum(x$response_state == "NOT_APPLICABLE")),
             evidence = "synthetic_training_only", stringsAsFactors = FALSE)
}
