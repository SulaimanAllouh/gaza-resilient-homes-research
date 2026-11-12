# Synthetic records for a denominator exercise

The seven invented practice records in `synthetic-practice.csv` do not correspond to people, households, dissertation variables, or empirical observations. Practice tokens have no research meaning.

Run `Rscript scripts/run_synthetic.R` from the project root. Expected counts: 7 rows; 6 eligible; 3 observed, including 1 valid zero. One eligible record has an unknown count, one has a missing response, and one was not asked. The seventh record is structurally ineligible. Empty cells are never interpreted as zero. The script writes the counts to `outputs/synthetic-demo-summary.csv` and marks each output as synthetic.

The checks deliberately assume the rules of this exercise only. Consult the actual measurement registry before applying any analogous rule to a dissertation variable.
