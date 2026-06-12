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
if (FALSE) { # \dontrun{
ggplot(df, aes(x, y, colour = phase)) + geom_point() + scale_colour_phase()
} # }
```
