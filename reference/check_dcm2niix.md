# Check dcm2niix Availability

Verifies that dcm2niix is installed and on PATH.

## Usage

``` r
check_dcm2niix(verbose = TRUE)
```

## Arguments

- verbose:

  Logical. Print status message. Default `TRUE`.

## Value

Named list with components: `available`, `version`, `path`.

## Examples

``` r
# Reports availability; returns `available = FALSE` when not installed.
check_dcm2niix(verbose = FALSE)$available
#> [1] FALSE
```
