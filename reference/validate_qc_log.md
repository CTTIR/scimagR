# Validate a QC Log

Checks required columns and valid quality values.

## Usage

``` r
validate_qc_log(qc_log)
```

## Arguments

- qc_log:

  Data frame or path to CSV.

## Value

Invisibly returns the validated QC log.

## Examples

``` r
qc <- tibble::tibble(
  pat_id = "SCI001", session = "ses-01", rater = "RH",
  date = as.Date("2025-01-10"), seg_type = "sc", quality = "good",
  notes = ""
)
validate_qc_log(qc)
#> ✔ QC log validation passed.
```
