# Compute Cross-Sectional Area Ratio

Calculates the ratio of CSA at the injury level to the reference CSA
(average of adjacent levels).

## Usage

``` r
compute_csa_ratio(csa_injury, csa_above, csa_below)
```

## Arguments

- csa_injury:

  Numeric. CSA at injury level (mm^2).

- csa_above:

  Numeric. CSA one level above (mm^2).

- csa_below:

  Numeric. CSA one level below (mm^2).

## Value

Numeric. CSA ratio (unitless). `NA` if reference is \<= 0 or any input
is `NA`.

## Examples

``` r
compute_csa_ratio(csa_injury = 45, csa_above = 70, csa_below = 72)
#> [1] 0.6338028
```
