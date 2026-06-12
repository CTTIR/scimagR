# Run an SCT Command

Internal helper that executes an SCT command via
[`system2()`](https://rdrr.io/r/base/system2.html), captures output, and
returns a structured result list.

## Usage

``` r
sct_run(cmd, args = character(), error_msg = NULL, verbose = TRUE)
```

## Arguments

- cmd:

  Character. Full SCT command name (e.g., "sct_deepseg").

- args:

  Character vector. Arguments to pass.

- error_msg:

  Character. Message on failure.

- verbose:

  Logical. Print command before running.

## Value

Named list with components: `exit_code`, `stdout`, `stderr`, `cmd`.
