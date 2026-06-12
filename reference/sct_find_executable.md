# Find SCT Executable Path

Resolves the path to an SCT executable, checking `SCT_DIR` environment
variable first, then falling back to
[`Sys.which()`](https://rdrr.io/r/base/Sys.which.html).

## Usage

``` r
sct_find_executable(cmd)
```

## Arguments

- cmd:

  Character. The SCT command name (e.g., "sct_deepseg").

## Value

Character. Full path to the executable, or empty string if not found.
