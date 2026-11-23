# Convert DICOM to NIfTI

Converts a single session's DICOM files to NIfTI format using dcm2niix.

## Usage

``` r
convert_dcm2niix(dicom_dir, output_dir, compress = TRUE, verbose = TRUE)
```

## Arguments

- dicom_dir:

  Character. Path to session DICOM directory.

- output_dir:

  Character. Path for NIfTI output.

- compress:

  Logical. Gzip output. Default `TRUE`.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Character vector of the NIfTI paths in `output_dir`. An error is raised
if 'dcm2niix' exits with a non-zero status.

## Examples

``` r
# \donttest{
# Needs the external 'dcm2niix' converter. Converts one session of the
# bundled synthetic DICOM files.
if (check_dcm2niix(verbose = FALSE)$available) {
  session <- system.file("extdata", "dicom", "SCI001", "ses-01",
                         package = "scimagR")
  convert_dcm2niix(session, file.path(tempdir(), "nifti", "ses-01"))
}
# }
```
