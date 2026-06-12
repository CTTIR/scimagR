# Create an Imaging Registry from DICOM Metadata

Takes raw DICOM metadata (from
[`extract_dicom_metadata()`](https://cttir.github.io/scimagR/reference/extract_dicom_metadata.md)),
restructures it into a proper imaging registry with computed fields
(days_post_trauma, phase classification), and optionally saves to CSV.

## Usage

``` r
create_registry(dicom_meta, trauma_dates, op_dates = NULL, output_csv = NULL)
```

## Arguments

- dicom_meta:

  Data frame or character path to DICOM metadata CSV.

- trauma_dates:

  Named vector: names = pat_id, values = trauma date (Date or character
  coercible to Date).

- op_dates:

  Named vector: names = pat_id, values = OP date. Optional.

- output_csv:

  Character. Path to save registry. Optional.

## Value

Tibble with registry columns.

## Examples

``` r
if (FALSE) { # \dontrun{
meta <- read.csv("dicom_metadata.csv")
trauma <- c(SCI001 = "2024-01-15", SCI002 = "2024-02-20")
reg <- create_registry(meta, trauma)
} # }
```
