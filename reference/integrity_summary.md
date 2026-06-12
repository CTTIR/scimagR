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
if (FALSE) { # \dontrun{
registry |> integrity_summary(id_cols = c("pat_id", "session"))
} # }
```
