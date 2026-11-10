# Colour and Fill Scales for Artifact Grades

Colour and Fill Scales for Artifact Grades

## Usage

``` r
scale_colour_artifact(...)

scale_fill_artifact(...)
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
df <- data.frame(grade = c("none", "mild", "moderate", "severe"),
                 n = c(12, 7, 3, 1))
ggplot(df, aes(grade, n, fill = grade)) +
  geom_col() +
  scale_fill_artifact()
```
