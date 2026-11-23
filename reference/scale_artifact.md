# Colour and Fill Scales for Artefact Grades

Manual scales using
[pal_artifact](https://cttir.github.io/scimagR/reference/pal_artifact.md);
the legend lists the grades from none to non-evaluable.

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
df <- data.frame(grade = classify_artifact(0:3), n = c(12, 7, 3, 1))
ggplot(df, aes(grade, n, fill = grade)) +
  geom_col() +
  scale_fill_artifact()
```
