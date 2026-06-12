# Segment Spinal Cord

Runs SCT's contrast-agnostic spinal cord segmentation model.

## Usage

``` r
sct_segment_sc(
  input,
  output = NULL,
  output_dir = NULL,
  overwrite = FALSE,
  verbose = TRUE,
  qc_dir = NULL
)
```

## Arguments

- input:

  Character. Path to NIfTI file (.nii.gz).

- output:

  Character. Path for output segmentation. Auto-generated if `NULL`.

- output_dir:

  Character. Directory for output. Alternative to `output`.

- overwrite:

  Logical. Re-run if output exists? Default `FALSE` (idempotent).

- verbose:

  Logical. Print progress. Default `TRUE`.

- qc_dir:

  Character. If provided, auto-generate QC report.

## Value

Character. Path to output segmentation file, or `NA` on failure.

## Examples

``` r
if (FALSE) { # \dontrun{
sct_segment_sc("sub-01_T2w.nii.gz")
} # }
```
