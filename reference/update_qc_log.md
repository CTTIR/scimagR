# Update a QC Log

Adds one or more QC entries to a QC log.

## Usage

``` r
update_qc_log(qc_log, entries, output_csv = NULL)
```

## Arguments

- qc_log:

  Tibble. Existing QC log (from
  [`create_qc_log()`](https://cttir.github.io/scimagR/reference/create_qc_log.md)).

- entries:

  Data frame. New entries with the same columns as `qc_log`.

- output_csv:

  Character. Optional path to save updated log.

## Value

Updated QC log tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
qc <- create_qc_log()
entry <- tibble::tibble(
  pat_id = "SCI001", session = "ses-01", rater = "RH",
  date = Sys.Date(), seg_type = "sc", quality = "good", notes = ""
)
qc <- update_qc_log(qc, entry)
} # }
```
