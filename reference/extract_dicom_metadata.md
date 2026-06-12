# Extract DICOM Header Metadata

Walks a DICOM directory tree and extracts key header fields (StudyDate,
Modality, SeriesDescription, FieldStrength, etc.) from the first DICOM
file per session.

## Usage

``` r
extract_dicom_metadata(
  dicom_dir,
  output_csv,
  python = Sys.getenv("PYTHON_BIN", "python3")
)
```

## Arguments

- dicom_dir:

  Character. Root DICOM directory (expects `<pat_id>/<session>/`
  structure).

- output_csv:

  Character. Path for output CSV.

- python:

  Character. Python executable. Default uses `PYTHON_BIN` environment
  variable or `"python3"`.

## Value

Character. Path to output CSV (invisible).

## Examples

``` r
if (FALSE) { # \dontrun{
extract_dicom_metadata("data/raw/dicom", "data/metadata/dicom_metadata.csv")
} # }
```
