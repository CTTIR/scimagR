# Colour and Fill Scales for Imaging Modalities

Colour and Fill Scales for Imaging Modalities

## Usage

``` r
scale_colour_modality(...)

scale_fill_modality(...)
```

## Arguments

- ...:

  Additional arguments passed to
  [`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
  /
  [`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A ggplot2 scale object.

## Examples

``` r
library(ggplot2)
df <- data.frame(modality = c("CT", "MRT", "CT+MRT"), n = c(5, 14, 3))
ggplot(df, aes(modality, n, fill = modality)) +
  geom_col() +
  scale_fill_modality()
```
