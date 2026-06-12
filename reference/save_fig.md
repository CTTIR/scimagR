# Save Figure with Standard Conventions

Saves a ggplot2 plot at publication-ready resolution with white
background.

## Usage

``` r
save_fig(plot, filename, path, width = 7, height = 5, dpi = 600)
```

## Arguments

- plot:

  A ggplot2 object.

- filename:

  Character. Output filename (e.g., `"fig1_mscc.png"`).

- path:

  Character. Output directory.

- width:

  Numeric. Figure width in inches. Default `7`.

- height:

  Numeric. Figure height in inches. Default `5`.

- dpi:

  Integer. Resolution. Default `600`.

## Value

Character. Full path to saved file (invisible).

## Examples

``` r
if (FALSE) { # \dontrun{
p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
save_fig(p, "test_plot.png", tempdir())
} # }
```
