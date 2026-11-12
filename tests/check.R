# Run: Rscript tests/check.R
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
root <- if (length(script_arg)) normalizePath(file.path(dirname(sub("^--file=", "", script_arg[1])), "..")) else getwd()
source(file.path(root, "R", "research_release.R"), encoding = "UTF-8")
fails_with <- function(expr, fragment) {
  msg <- tryCatch({force(expr); NULL}, error = function(e) conditionMessage(e))
  stopifnot(!is.null(msg), grepl(fragment, msg, fixed = TRUE))
}

# 1/16 is an exact halfway at one decimal place; arithmetic alone cannot
# distinguish the dissertation's tie convention.
fixture <- data.frame(indicator_id = c("a", "b"), domain = "demo", label_en = "<demo & label>",
                      label_ar = "مثال", numerator = 1L, denominator = 16L,
                      reported_pct = c(6.2, 6.3), source_table = "unit fixture",
                      printed_page = "x", pdf_page = "x", stringsAsFactors = FALSE)
res <- check_aggregates(fixture)
stopifnot(all(res$recalculated_pct == 6.25), identical(res$difference_pp, c(0.05, -0.05)))
bad <- fixture; bad$reported_pct[1] <- 6.1
fails_with(check_aggregates(bad), "inconsistent")
bad <- fixture; bad$denominator[1] <- 0
fails_with(check_aggregates(bad), "integer counts")
bad <- fixture; bad$numerator[1] <- 16.5
fails_with(check_aggregates(bad), "integer counts")
bad <- fixture; bad$indicator_id[2] <- "a"
fails_with(check_aggregates(bad), "Duplicate indicator_id")
bad <- fixture; bad$printed_page[1] <- ""
fails_with(check_aggregates(bad), "Empty value in printed_page")
bad <- fixture; bad$label_ar <- NULL
fails_with(check_aggregates(bad), "Missing column")
bad <- fixture; bad$numerator[1] <- 0; bad$reported_pct[1] <- 0
stopifnot(check_aggregates(bad)$recalculated_pct[1] == 0)
tmp <- tempfile(fileext = ".html")
write_aggregate_report(res, tmp)
markup <- readLines(tmp, encoding = "UTF-8")
stopifnot(any(grepl("&lt;demo &amp; label&gt;", markup, fixed = TRUE)))
unlink(tmp)

practice <- read_release_csv(file.path(root, "examples", "synthetic-practice.csv"))
p <- summarise_synthetic(practice)
counts <- setNames(p$count, p$measure)
stopifnot(counts[["total_rows"]] == 7, counts[["eligible_rows"]] == 6,
          counts[["observed_rows"]] == 3, counts[["observed_zero_rows"]] == 1,
          all(counts[c("unknown_rows","missing_rows","not_asked_rows","not_applicable_rows")] == 1))
bad <- practice; bad$practice_token_count[bad$response_state == "UNKNOWN"] <- "0"
fails_with(summarise_synthetic(bad), "exactly for OBSERVED")
bad <- practice; bad$eligibility[bad$response_state == "NOT_APPLICABLE"] <- "ELIGIBLE"
fails_with(summarise_synthetic(bad), "Eligibility and NOT_APPLICABLE")
real_table <- check_aggregates(read_release_csv(file.path(root, "data", "published_aggregates.csv")))
message("Passed arithmetic, schema, HTML-escaping and synthetic denominator tests; ",
        nrow(real_table), " aggregate rows also passed.")
