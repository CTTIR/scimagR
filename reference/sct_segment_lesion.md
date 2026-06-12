# Segment SCI Lesion

Runs SCIsegV2 lesion segmentation model via SCT.

## Usage

``` r
sct_segment_lesion(
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

  Character. Path to T2w NIfTI file (.nii.gz).

- output:

  Character. Path for output segmentation. Auto-generated if `NULL`.

- output_dir:

  Character. Directory for output. Alternative to `output`.

- overwrite:

  Logical. Re-run if output exists? Default `FALSE`.

- verbose:

  Logical. Print progress. Default `TRUE`.

- qc_dir:

  Character. If provided, auto-generate QC report.

## Value

Character. Path to output lesion segmentation, or `NA` on failure.

## Examples

``` r
if (FALSE) { # \dontrun{
sct_segment_lesion("sub-01_T2w.nii.gz")
} # }
```
