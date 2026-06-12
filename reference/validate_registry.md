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
if (FALSE) { # \dontrun{
validate_registry("data/metadata/imaging_registry.csv")
} # }
```
