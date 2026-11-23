# Anonymise DICOM Files

Replaces identifying header fields and removes private tags in every
file below `dicom_dir`, using the bundled Python script and 'pydicom'.
Each patient folder (`<dicom_dir>/<folder>/`) gets a new ID
`<prefix>001`, `<prefix>002`, ... in alphabetical folder order; the
mapping from folder name to new ID is saved to `mapping_csv`.

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

  Character. Anonymised ID prefix. Default `"SCI"`.

- python:

  Character. Python executable. Default uses `PYTHON_BIN` environment
  variable or `"python3"`.

## Value

Exit code (invisible).

## Details

**WARNING:** This modifies DICOM files in-place. Create a backup first.
The mapping CSV must NOT be stored in the project directory.

What is changed: `PatientID` is set to the new ID; `PatientName`,
`PatientBirthDate`, `PatientAddress`, `PatientTelephoneNumbers`,
`ReferringPhysicianName`, `InstitutionName`, `InstitutionAddress`,
`InstitutionalDepartmentName`, `PhysiciansOfRecord`,
`PerformingPhysicianName` and `OperatorsName` are emptied, and all
private tags are removed. Everything else is kept, including dates,
`PatientSex`, `PatientAge`, `AccessionNumber`, UIDs and burned-in
annotations in the pixel data. The folder names are not changed either,
so rename folders that carry names or hospital numbers yourself. This is
a minimal de-identification, not the DICOM PS3.15 Basic Application
Level Confidentiality Profile; check it against your data protection
requirements before sharing data.

## Examples

``` r
# \donttest{
# Needs Python 3 with 'pydicom'. Works on a copy of the bundled
# synthetic DICOM files, because the files are changed in place.
if (check_pydicom(verbose = FALSE)$available) {
  work <- file.path(tempdir(), "anon-example")
  dir.create(work, showWarnings = FALSE)
  file.copy(system.file("extdata", "dicom", package = "scimagR"), work,
            recursive = TRUE)
  mapping <- file.path(tempdir(), "secure", "id_mapping.csv")
  anonymize_dicom(file.path(work, "dicom"), mapping)
  utils::read.csv(mapping)
  unlink(c(work, dirname(mapping)), recursive = TRUE)
}
# }
```
