# Anonymize DICOM Files

Replaces identifying header fields (PatientName, PatientID,
PatientBirthDate, etc.) and removes private tags. Saves an ID mapping
CSV to a user-specified secure location.

## Usage

``` r
anonymize_dicom(
  dicom_dir,
  mapping_csv,
  prefix = "SCI",
  python = Sys.getenv("PYTHON_BIN", "python3")
)
```

## Arguments

- dicom_dir:

  Character. Root DICOM directory.

- mapping_csv:

  Character. Path for ID mapping output. **Store securely!**

- prefix:

  Character. Anonymized ID prefix. Default `"SCI"`.

- python:

  Character. Python executable. Default `"python3"`.

## Value

Exit code (invisible).

## Details

**WARNING:** This modifies DICOM files in-place. Create a backup first.
The mapping CSV must NOT be stored in the project directory.

## Examples

``` r
if (FALSE) { # \dontrun{
anonymize_dicom("data/raw/dicom", "/secure/id_mapping.csv")
} # }
```
