# Filter to Evaluable Imaging Sessions

Filters a dataset to sessions that meet artifact grade and modality
criteria for analysis.

## Usage

``` r
filter_evaluable(
  df,
  max_artifact = 2,
  modalities = c("MRT", "CT+MRT"),
  verbose = TRUE
)
```

## Arguments

- df:

  Data frame with `artifact_grade` and `modality` columns.

- max_artifact:

  Integer. Maximum artifact grade to include. Default `2`.

- modalities:

  Character vector. Modalities to include. Default `c("MRT", "CT+MRT")`.

- verbose:

  Logical. Print exclusion summary. Default `TRUE`.

## Value

Filtered data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
evaluable <- filter_evaluable(registry, max_artifact = 2)
} # }
```
