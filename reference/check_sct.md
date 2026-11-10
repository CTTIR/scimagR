# Check Spinal Cord Toolbox Availability

Verifies that SCT is installed and on PATH. Returns version and path
information.

## Usage

``` r
check_sct(verbose = TRUE)
```

## Arguments

- verbose:

  Logical. Print status message. Default `TRUE`.

## Value

Named list with components:

- `available`: Logical.

- `version`: Character. Version string or `NA`.

- `path`: Character. Path to `sct_version` executable or `NA`.

## Examples

``` r
# Reports availability; returns `available = FALSE` when not installed.
check_sct(verbose = FALSE)$available
#> [1] FALSE
```
