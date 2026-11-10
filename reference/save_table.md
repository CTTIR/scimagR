# Save Table as Excel

Saves a data frame as .xlsx via writexl.

## Usage

``` r
save_table(df, filename, path)
```

## Arguments

- df:

  A data frame.

- filename:

  Character. Output filename (e.g., `"table1.xlsx"`).

- path:

  Character. Output directory.

## Value

Character. Full path to saved file (invisible).

## Examples

``` r
out <- save_table(mtcars, "cars.xlsx", tempdir())
#> ✔ Table saved: /tmp/RtmptOUSAu/cars.xlsx
file.exists(out)
#> [1] TRUE
unlink(out)
```
