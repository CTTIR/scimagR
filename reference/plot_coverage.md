# Plot Modality Coverage Matrix

Creates a tile plot showing modality coverage per patient and session,
with optional artifact grade overlay.

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
