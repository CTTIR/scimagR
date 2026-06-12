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
if (FALSE) { # \dontrun{
reg <- validate_registry("imaging_registry.csv", strict = FALSE)
cm <- coverage_matrix(reg)
} # }
```
