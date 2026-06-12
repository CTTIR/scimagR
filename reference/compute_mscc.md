# Compute Maximum Spinal Cord Compression (MSCC)

Calculates MSCC using the formula: \$\$MSCC = (1 - d_i / ((d_a + d_b) /
2)) \times 100\$\$

## Usage

``` r
compute_mscc(di, da, db)
```

## Arguments

- di:

  Numeric. Sagittal AP diameter at injury level (mm).

- da:

  Numeric. Sagittal AP diameter one level above (mm).

- db:

  Numeric. Sagittal AP diameter one level below (mm).

## Value

Numeric. MSCC percentage. `NA` if any input is `NA` or if the reference
diameter is \<= 0.

## Examples

``` r
compute_mscc(di = 5.2, da = 8.1, db = 8.5)
#> [1] 37.3494
compute_mscc(di = 0, da = 8, db = 8) # 100% compression
#> [1] 100
```
