# SCI Publication Theme

A clean ggplot2 theme based on
[`ggplot2::theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
optimized for publication-ready neuroimaging figures, with no minor
gridlines and a bottom legend.

## Usage

``` r
theme_sci(base_size = 11, base_family = "")
```

## Arguments

- base_size:

  Numeric. Base font size. Default `11`.

- base_family:

  Character. Base font family. Default `""`, the device's standard
  sans-serif font (Helvetica or Arial on most systems), which works on
  every graphics device. Set `"Arial"` explicitly for devices that can
  use installed system fonts (e.g. `ragg` or Cairo PNG); the base
  [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device does not know
  this family.

## Value

A ggplot2 theme object.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_sci()
```
