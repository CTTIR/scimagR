# Colour and Fill Scales for SCI Phases

Convenience wrappers around
[`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
and
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
using
[pal_phase](https://cttir.github.io/scimagR/reference/pal_phase.md).

## Usage

``` r
scale_colour_phase(...)

scale_fill_phase(...)
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
df <- data.frame(
  days = c(3, 40, 150, 400),
  csa = c(70, 64, 60, 58),
  phase = c("acute", "subacute", "intermediate", "chronic")
)
ggplot(df, aes(days, csa, colour = phase)) +
  geom_point(size = 3) +
  scale_colour_phase()
```
