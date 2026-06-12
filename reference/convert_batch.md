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
if (FALSE) { # \dontrun{
convert_batch(registry, "data/raw/dicom", "data/nifti")
} # }
```
