# Check pydicom Availability

Verifies that Python 3 with pydicom is available.

## Usage

``` r
check_pydicom(python = Sys.getenv("PYTHON_BIN", "python3"), verbose = TRUE)
```

## Arguments

- python:

  Character. Python executable. Default uses `PYTHON_BIN` environment
  variable or `"python3"`.

- verbose:

  Logical. Print status message. Default `TRUE`.

## Value

Named list with components: `available`, `version`, `path`.

## Examples

``` r
if (FALSE) { # \dontrun{
check_pydicom()
} # }
```
