# Spaghetti Plot

Shows individual patient trajectories over time with an optional
group-level smoother.

## Usage

``` r
plot_spaghetti(df, x, y, group, colour = NULL, smoother = TRUE, title = NULL)
```

## Arguments

- df:

  Data frame.

- x:

  Character. Column name for x-axis (numeric, e.g., days).

- y:

  Character. Column name for y-axis (numeric).

- group:

  Character. Column name for grouping (e.g., `"pat_id"`).

- colour:

  Character. Column name for colour aesthetic. Default `NULL`.

- smoother:

  Logical. Add group-level LOESS smoother. Default `TRUE`.

- title:

  Character. Plot title. Default `NULL`.

## Value

A ggplot2 object.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_spaghetti(df, x = "days_post_trauma", y = "csa",
               group = "pat_id", colour = "phase")
} # }
```
