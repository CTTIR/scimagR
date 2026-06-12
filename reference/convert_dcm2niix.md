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

Character vector of output NIfTI paths.

## Examples

``` r
if (FALSE) { # \dontrun{
convert_dcm2niix("data/raw/dicom/SCI001/ses-01", "data/nifti/SCI001/ses-01")
} # }
```
