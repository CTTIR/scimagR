# Violin + Box Plot

Creates a violin plot with embedded boxplot (no outlier points) and
jittered individual data points. Uses viridis palette by default.

## Usage

``` r
plot_violin_box(df, x, y, fill = x, title = NULL, ylab = y)
```

## Arguments

- df:

  Data frame.

- x:

  Character. Column name for x-axis (categorical).

- y:

  Character. Column name for y-axis (numeric).

- fill:

  Character. Column name for fill aesthetic. Default same as `x`.

- title:

  Character. Plot title. Default `NULL`.

- ylab:

  Character. Y-axis label. Default same as `y`.

## Value

A ggplot2 object.

## Examples

``` r
set.seed(1)
df <- data.frame(
  phase = rep(c("acute", "subacute", "chronic"), each = 10),
  mscc = c(rnorm(10, 30, 8), rnorm(10, 22, 6), rnorm(10, 15, 5))
)
plot_violin_box(df, x = "phase", y = "mscc", fill = "phase")
```
