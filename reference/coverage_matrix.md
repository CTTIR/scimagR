# Create a Modality Coverage Matrix

Shows which patients have which modalities at which timepoints.

## Usage

``` r
coverage_matrix(registry)
```

## Arguments

- registry:

  Data frame. Validated registry with `pat_id`, `session`, `modality`,
  and optionally `artifact_grade` columns.

## Value

Tibble in wide format with one row per patient and one column per
session containing the modality.

## Examples

``` r
reg <- validate_registry(
  system.file("extdata", "example_registry.csv", package = "scimagR")
)
#> ✔ Registry validation passed.
coverage_matrix(reg)
#> # A tibble: 3 × 4
#>   pat_id `ses-01` `ses-02` `ses-03`
#>   <chr>  <chr>    <chr>    <chr>   
#> 1 SCI001 MRT      MRT      MRT     
#> 2 SCI002 CT+MRT   MRT      NA      
#> 3 SCI003 CT       MRT      MRT     
```
