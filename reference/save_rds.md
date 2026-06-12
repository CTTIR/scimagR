# Save R Object as RDS

Saves any R object as .rds with a confirmation message.

## Usage

``` r
save_rds(obj, filename, path)
```

## Arguments

- obj:

  Any R object.

- filename:

  Character. Output filename (e.g., `"model_fit.rds"`).

- path:

  Character. Output directory.

## Value

Character. Full path to saved file (invisible).

## Examples

``` r
if (FALSE) { # \dontrun{
save_rds(mtcars, "cars.rds", tempdir())
} # }
```
