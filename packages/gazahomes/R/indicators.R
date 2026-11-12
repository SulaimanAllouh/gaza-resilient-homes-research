# Keep both released CSVs readable directly, including in non-UTF-8 locales.
read_home_table <- function(filename) {
    path <- system.file("extdata", filename, package = "gazahomes",
                        mustWork = TRUE)
    utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE,
                    encoding = "UTF-8", na.strings = character())
}

home_indicators <- function() {
    read_home_table("published_aggregates.csv")
}

home_dictionary <- function() {
    read_home_table("indicator_dictionary.csv")
}

table_keys <- function(x, cols) {
    if (!is.data.frame(x) || nrow(x) == 0L || anyDuplicated(names(x)) ||
        !all(c("indicator_id", cols) %in% names(x))) {
        stop("Expected a non-empty data frame with the documented columns.",
             call. = FALSE)
    }
    k <- x[["indicator_id"]]
    if (!is.character(k) || anyNA(k) || any(!nzchar(trimws(k))) ||
        anyDuplicated(k)) {
        stop("Indicator identifiers must be nonempty and unique.", call. = FALSE)
    }
    k
}

count_vector <- function(x) {
    is.numeric(x) && all(is.finite(x)) && all(x >= 0) && all(x == floor(x))
}

check_indicators <- function(indicators = home_indicators(),
                             dictionary = home_dictionary()) {
    keys <- table_keys(indicators, c("numerator", "denominator", "reported_pct"))
    dk <- table_keys(dictionary, c("excluded_unknown", "excluded_structural"))
    if (!setequal(keys, dk)) {
        stop("Both tables must contain the same indicator IDs.", call. = FALSE)
    }

    # Preserve the published order while reconciling rows by key, never position.
    dict <- dictionary[match(keys, dk), , drop = FALSE]
    n <- indicators[["numerator"]]
    d <- indicators[["denominator"]]
    p <- indicators[["reported_pct"]]
    u <- dict[["excluded_unknown"]]
    s <- dict[["excluded_structural"]]
    if (!all(vapply(list(n, d, u, s), count_vector, logical(1))) ||
        any(d <= 0 | n > d)) {
        stop("Counts must be nonnegative integers, with 0 <= n <= d and d > 0.",
             call. = FALSE)
    }
    if (!is.numeric(p) || any(!is.finite(p)) || any(p < 0 | p > 100) ||
        any(abs(10*p - round(10*p)) > 1e-8)) {
        stop("Reported percentages must be finite and given to one decimal place or less.",
             call. = FALSE)
    }
    exact <- 100 * as.double(n) / as.double(d)
    # Use the same half-unit tolerance as the public v0.1.0 R project, including
    # exact halfway cases; the published table does not specify a tie convention.
    rounding_ok <- abs(exact - p) <= 0.05 + 1e-9
    denominator_ok <- (as.double(d) + u + s) == 302
    data.frame(indicator_id = keys, numerator = n, denominator = d,
               excluded_unknown = u, excluded_structural = s,
               reported_pct = p, calculated_pct = exact,
               rounding_ok = rounding_ok, denominator_ok = denominator_ok,
               ok = rounding_ok & denominator_ok, stringsAsFactors = FALSE)
}
