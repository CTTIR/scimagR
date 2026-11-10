# Batch Convert DICOM to NIfTI

Iterates over a registry and converts all sessions from DICOM to NIfTI.

## Usage

``` r
convert_batch(
  registry,
  dicom_root,
  nifti_root,
  compress = TRUE,
  verbose = TRUE
)
```

## Arguments

- registry:

  Data frame with `pat_id` and `session` columns.

- dicom_root:

  Character. Root DICOM directory.

- nifti_root:

  Character. Root NIfTI output directory.

- compress:

  Logical. Gzip output. Default `TRUE`.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Tibble with columns: `pat_id`, `session`, `status`, `n_files`.

## Examples

``` r
reg <- validate_registry(
  system.file("extdata", "example_registry.csv", package = "scimagR")
)
#> ✔ Registry validation passed.
# A session that cannot be converted (here: its DICOM folder is missing)
# gets status "error" and a warning; the batch carries on.
convert_batch(reg[1, ],
  dicom_root = file.path(tempdir(), "dicom"),
  nifti_root = file.path(tempdir(), "nifti")
)
#> Warning: Conversion failed for SCI001/ses-01: DICOM directory not found:
#> /tmp/RtmpGur4Jb/dicom/SCI001/ses-01
#> Batch conversion: 0 succeeded, 1 failed.
#> # A tibble: 1 × 4
#>   pat_id session status n_files
#>   <chr>  <chr>   <chr>    <int>
#> 1 SCI001 ses-01  error        0

if (FALSE) { # \dontrun{
# Not run: needs DICOM files and the external 'dcm2niix' converter.
convert_batch(reg, "data/raw/dicom", "data/nifti")
} # }
```
