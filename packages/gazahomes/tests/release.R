library(gazahomes)
a <- home_indicators()
d <- home_dictionary()
res <- check_indicators()
stopifnot(nrow(a) == 9L, nrow(d) == 9L, all(res$ok),
          setequal(a$indicator_id, d$indicator_id),
          all(validUTF8(a$label_ar)), all(validUTF8(d$denominator_rule_ar)),
          any(grepl("\\p{Arabic}", a$label_ar, perl = TRUE)))
by_question <- function(q) {
    res[match(d$indicator_id[d$question_id == q], res$indicator_id), ]
}
q37 <- by_question("Q37")
q36 <- by_question("Q36")
q40 <- by_question("Q40")
stopifnot(q37$numerator == 265L, q37$denominator == 279L,
          q37$excluded_unknown == 23L, q37$reported_pct == 95.0,
          q36$numerator == 117L, q36$denominator == 297L, q36$excluded_unknown == 5L,
          q40$numerator == 77L, q40$denominator == 131L, q40$excluded_structural == 171L)
stopifnot(identical(res, check_indicators(a, d[rev(seq_len(nrow(d))), ])))
# Keep altered tables strictly inside tests; no test fixtures are installed as data.
bad <- a
bad$reported_pct[1L] <- 0
stopifnot(!check_indicators(bad, d)$rounding_ok[1L])
bad_d <- d
bad_d$excluded_unknown[1L] <- 1L
s <- check_indicators(a, bad_d)
stopifnot(!s$denominator_ok[1L], s$rounding_ok[1L], !s$ok[1L])
expect_error <- function(x) inherits(try(x, silent = TRUE), "try-error")
stopifnot(expect_error(check_indicators(a, d[-1, ])))
bad_d <- d
bad_d$indicator_id[2] <- bad_d$indicator_id[1]
stopifnot(expect_error(check_indicators(a, bad_d)))
bad <- a
bad$numerator[1] <- bad$denominator[1] + 1
stopifnot(expect_error(check_indicators(bad, d)))
bad <- a
bad$numerator[1] <- NA_integer_
stopifnot(expect_error(check_indicators(bad, d)))
