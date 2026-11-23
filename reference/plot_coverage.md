# Plot Modality Coverage Matrix

Creates a tile plot showing modality coverage per patient and session.
If the registry has an `artifact_grade` column, each tile shows the
grade and a caption explains the numbers.

## Usage

``` r
plot_coverage(registry)
```

## Arguments

- registry:

  Data frame. Validated registry.

## Value

A ggplot2 object.

## Examples

``` r
reg <- validate_registry(
  system.file("extdata", "example_registry.csv", package = "scimagR")
)
#> ✔ Registry validation passed.
plot_coverage(reg)
```
