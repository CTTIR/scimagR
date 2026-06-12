# SCI Publication Theme

A clean ggplot2 theme based on
[`ggplot2::theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
optimized for publication-ready neuroimaging figures. Uses Arial font,
no minor gridlines, and a bottom legend.

## Usage

``` r
theme_sci(base_size = 11, base_family = "Arial")
```

## Arguments

- base_size:

  Numeric. Base font size. Default `11`.

- base_family:

  Character. Base font family. Default `"Arial"`.

## Value

A ggplot2 theme object.

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_sci()
} # }
```
