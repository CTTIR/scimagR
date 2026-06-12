# Compute Spinal Cord Compression Ratio

Calculates the ratio of anterior-posterior to transverse diameter.

## Usage

``` r
compute_compression_ratio(ap, transverse)
```

## Arguments

- ap:

  Numeric. Anterior-posterior diameter (mm).

- transverse:

  Numeric. Transverse diameter (mm).

## Value

Numeric. Compression ratio (unitless). `NA` if `transverse` \<= 0 or any
input is `NA`.

## Examples

``` r
compute_compression_ratio(ap = 6.5, transverse = 12.0)
#> [1] 0.5416667
```
