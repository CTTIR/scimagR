# Forest Plot

Creates a forest plot for comparing model estimates with confidence
intervals. Useful for sensitivity analysis comparisons.

## Usage

``` r
plot_forest(estimates_df, xlab = "Estimate", title = NULL, vline = 0)
```

## Arguments

- estimates_df:

  Data frame with columns: `model`, `estimate`, `ci_lower`, `ci_upper`.

- xlab:

  Character. X-axis label. Default `"Estimate"`.

- title:

  Character. Plot title. Default `NULL`.

- vline:

  Numeric. Position of reference line. Default `0`.

## Value

A ggplot2 object.

## Examples

``` r
if (FALSE) { # \dontrun{
est <- data.frame(
  model = c("Full", "Sensitivity 1", "Sensitivity 2"),
  estimate = c(-2.1, -1.9, -2.3),
  ci_lower = c(-3.5, -3.4, -3.8),
  ci_upper = c(-0.7, -0.4, -0.8)
)
plot_forest(est)
} # }
```
