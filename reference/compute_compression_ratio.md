# Compute Spinal Cord Compression Ratio

Calculates the anteroposterior compression ratio of the spinal cord, the
ratio of its anterior-posterior (sagittal) diameter to its transverse
diameter (Ogino et al. 1983). Vectorised over both arguments; an
argument of length 1 is recycled, other length mismatches are an error.

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

Numeric vector of compression ratios (unitless). An element is `NA` if
`transverse` \<= 0 or any of its inputs is `NA`.

## References

Ogino H, Tada K, Okada K, et al. (1983). Canal diameter, anteroposterior
compression ratio, and spondylotic myelopathy of the cervical spine.
*Spine* 8(1):1–15.
[doi:10.1097/00007632-198301000-00001](https://doi.org/10.1097/00007632-198301000-00001)

## Examples

``` r
compute_compression_ratio(ap = 6.5, transverse = 12.0)
#> [1] 0.5416667
compute_compression_ratio(ap = c(6.5, 7.1), transverse = c(12.0, 11.4))
#> [1] 0.5416667 0.6228070
```
