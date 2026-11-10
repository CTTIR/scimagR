# Validate an Imaging Registry

Checks: required columns present, no duplicate pat_id x session, dates
are valid, days_post_trauma \>= 0, artifact_grade in 0–4, modality in
allowed values.

## Usage

``` r
validate_registry(registry, strict = TRUE)
```

## Arguments

- registry:

  Data frame or character path to CSV.

- strict:

  Logical. Stop on errors (`TRUE`) or warn (`FALSE`). Default `TRUE`.

## Value

Invisibly returns the validated registry tibble.

## Examples

``` r
reg_file <- system.file("extdata", "example_registry.csv",
                        package = "scimagR")
reg <- validate_registry(reg_file)
#> ✔ Registry validation passed.
reg
#> # A tibble: 8 × 11
#>   pat_id session study_date modality series_description field_strength
#>   <chr>  <chr>   <date>     <chr>    <chr>                       <dbl>
#> 1 SCI001 ses-01  2024-01-20 MRT      T2w_sag                       3  
#> 2 SCI001 ses-02  2024-03-15 MRT      T2w_sag                       3  
#> 3 SCI001 ses-03  2024-07-20 MRT      T2w_sag                       3  
#> 4 SCI002 ses-01  2024-02-25 CT+MRT   T2w_sag                       1.5
#> 5 SCI002 ses-02  2024-05-20 MRT      T2w_sag                       3  
#> 6 SCI003 ses-01  2024-03-05 CT       CT_cervical                  NA  
#> 7 SCI003 ses-02  2024-06-01 MRT      T2w_sag                       3  
#> 8 SCI003 ses-03  2025-04-01 MRT      T2w_sag                       3  
#> # ℹ 5 more variables: trauma_date <date>, days_post_trauma <dbl>, phase <chr>,
#> #   artifact_grade <dbl>, notes <chr>
```
