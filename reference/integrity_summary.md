# Print Data Integrity Summary

Reports dimensions, missing values per column, and duplicate count for a
data frame. Returns the data frame invisibly for piping.

## Usage

``` r
integrity_summary(df, id_cols = NULL)
```

## Arguments

- df:

  Data frame to summarize.

- id_cols:

  Character vector. Columns to check for duplicates. Default `NULL`
  (skip duplicate check).

## Value

Invisibly returns `df`.

## Examples

``` r
reg <- validate_registry(
  system.file("extdata", "example_registry.csv", package = "scimagR")
)
#> ✔ Registry validation passed.
integrity_summary(reg, id_cols = c("pat_id", "session"))
#> 
#> ── Data Integrity Summary ──
#> 
#> Dimensions: 8 rows x 11 columns
#> 
#> ── Missing Values 
#> field_strength: 1 (12.5%)
#> notes: 6 (75%)
#> ✔ No duplicates on pat_id x session.
```
