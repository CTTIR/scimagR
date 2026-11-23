# Extract DICOM Header Metadata

Walks a DICOM directory tree and extracts key header fields (StudyDate,
Modality, SeriesDescription, MagneticFieldStrength, etc.) from the first
DICOM file per session, using the bundled Python script and 'pydicom'.

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

Character. Path to output CSV (invisible). The CSV has one row per
session with the columns `pat_id`, `session`, `dcm_path`, `study_date`,
`modality`, `series_description`, `field_strength`, `manufacturer`,
`scanner_model`, `slice_thickness`, `pixel_spacing`, `rows`, `columns`
and `institution`.

## Details

The `pat_id` and `session` columns are taken from the folder names
(`<dicom_dir>/<pat_id>/<session>/`), so that they match the paths that
[`convert_batch()`](https://cttir.github.io/scimagR/reference/convert_batch.md)
builds from the registry. The `PatientID` header, which may hold an
identifying hospital number, is not exported. `modality` holds the DICOM
code (`"MR"`, `"CT"`);
[`create_registry()`](https://cttir.github.io/scimagR/reference/create_registry.md)
maps `"MR"` to the registry code `"MRT"`.

## Examples

``` r
# \donttest{
# Needs Python 3 with 'pydicom'. The bundled DICOM files are synthetic
# 8 x 8 pixel slices of one made-up patient with two sessions.
if (check_pydicom(verbose = FALSE)$available) {
  dicom_root <- system.file("extdata", "dicom", package = "scimagR")
  csv <- extract_dicom_metadata(dicom_root,
                                file.path(tempdir(), "dicom_metadata.csv"))
  meta <- utils::read.csv(csv)
  meta[, c("pat_id", "session", "study_date", "modality")]
}
# }
```
