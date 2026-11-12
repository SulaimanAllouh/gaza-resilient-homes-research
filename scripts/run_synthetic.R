# Separate teaching demonstration. No dissertation records, estimates or fits.
# Run: Rscript scripts/run_synthetic.R
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
root <- if (length(script_arg)) normalizePath(file.path(dirname(sub("^--file=", "", script_arg[1])), "..")) else getwd()
source(file.path(root, "R", "research_release.R"), encoding = "UTF-8")
x <- summarise_synthetic(read_release_csv(file.path(root, "examples", "synthetic-practice.csv")))
out <- file.path(root, "outputs")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
write_release_csv(x, file.path(out, "synthetic-demo-summary.csv"))
message("Synthetic practice exercise only. Wrote outputs/synthetic-demo-summary.csv.")
