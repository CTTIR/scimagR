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

  Character. Column name for x-axis (categorical). Groups are shown in
  factor level order, so use a factor (e.g. from
  [`classify_phase()`](https://cttir.github.io/scimagR/reference/classify_phase.md))
  to control the order.

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
  # a factor keeps the phases in clinical rather than alphabetical order
  phase = classify_phase(rep(c(5, 40, 400), each = 10)),
  mscc = c(rnorm(10, 30, 8), rnorm(10, 22, 6), rnorm(10, 15, 5))
)
plot_violin_box(df, x = "phase", y = "mscc", fill = "phase",
                ylab = "MSCC (%)")
```
