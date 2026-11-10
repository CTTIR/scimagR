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
reg <- validate_registry(
  system.file("extdata", "example_registry.csv", package = "scimagR")
)
#> ✔ Registry validation passed.
evaluable <- filter_evaluable(reg, max_artifact = 1)
#> Filtered: 8 -> 6 (2 excluded)
evaluable
#> # A tibble: 6 × 11
#>   pat_id session study_date modality series_description field_strength
#>   <chr>  <chr>   <date>     <chr>    <chr>                       <dbl>
#> 1 SCI001 ses-01  2024-01-20 MRT      T2w_sag                         3
#> 2 SCI001 ses-02  2024-03-15 MRT      T2w_sag                         3
#> 3 SCI001 ses-03  2024-07-20 MRT      T2w_sag                         3
#> 4 SCI002 ses-02  2024-05-20 MRT      T2w_sag                         3
#> 5 SCI003 ses-02  2024-06-01 MRT      T2w_sag                         3
#> 6 SCI003 ses-03  2025-04-01 MRT      T2w_sag                         3
#> # ℹ 5 more variables: trauma_date <date>, days_post_trauma <dbl>, phase <chr>,
#> #   artifact_grade <dbl>, notes <chr>
```
