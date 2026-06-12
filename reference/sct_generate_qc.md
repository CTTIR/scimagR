# Generate SCT Quality Control Report

Creates an HTML QC report overlaying a segmentation on the original
image.

## Usage

``` r
sct_generate_qc(
  input,
  segmentation,
  qc_dir,
  process = "sct_deepseg",
  verbose = TRUE
)
```

## Arguments

- input:

  Character. Path to original NIfTI image.

- segmentation:

  Character. Path to segmentation overlay.

- qc_dir:

  Character. Directory for QC HTML output.

- process:

  Character. SCT process name for labeling. Default `"sct_deepseg"`.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Exit code (invisible).

## Examples

``` r
if (FALSE) { # \dontrun{
sct_generate_qc("sub-01_T2w.nii.gz", "sub-01_T2w_seg.nii.gz", "qc/")
} # }
```
