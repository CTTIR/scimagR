# Compute Maximum Spinal Cord Compression (MSCC)

Calculates MSCC as defined by Fehlings et al. (1999): \$\$MSCC = (1 -
d_i / ((d_a + d_b) / 2)) \times 100\$\$

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

Numeric vector of MSCC percentages. An element is `NA` if any of its
inputs is `NA` or if its reference diameter (`(da + db) / 2`) is \<= 0.

## Details

All arguments are vectorised, so the function can be used inside
[`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
on registry columns. An argument of length 1 is recycled to the length
of the others; any other mismatch of lengths is an error.

## References

Fehlings MG, Rao SC, Tator CH, et al. (1999). The optimal radiologic
method for assessing spinal canal compromise and cord compression in
patients with cervical spinal cord injury. Part II: Results of a
multicenter study. *Spine* 24(6):605–613 (MSCC definition in the
Methods).
[doi:10.1097/00007632-199903150-00023](https://doi.org/10.1097/00007632-199903150-00023)

## Examples

``` r
compute_mscc(di = 5.2, da = 8.1, db = 8.5)
#> [1] 37.3494
compute_mscc(di = 0, da = 8, db = 8) # 100% compression
#> [1] 100

# Vectorised: one value per measurement
compute_mscc(di = c(5.2, 6.0, NA), da = c(8.1, 8.0, 8.2), db = 8.4)
#> [1] 36.96970 26.82927       NA
```
