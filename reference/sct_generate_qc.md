# Generate SCT Quality Control Report

Creates an HTML QC report with `sct_qc`, overlaying a segmentation on
the original image.

## Usage

``` r
sct_generate_qc(
  input,
  segmentation,
  qc_dir,
  process = "sct_deepseg_sc",
  verbose = TRUE,
  lesion = NULL,
  plane = c("sagittal", "axial")
)
```

## Arguments

- input:

  Character. Path to original NIfTI image.

- segmentation:

  Character. Path to segmentation overlay (the spinal cord mask for a
  lesion report).

- qc_dir:

  Character. Directory for QC HTML output.

- process:

  Character. The `sct_qc -p` process the report is made for, e.g.
  `"sct_deepseg_sc"` (default), `"sct_deepseg_lesion"` or
  `"sct_label_vertebrae"`. The former default `"sct_deepseg"`, which
  `sct_qc` does not accept, is treated as `"sct_deepseg_sc"`.

- verbose:

  Logical. Print progress. Default `TRUE`.

- lesion:

  Character. Path to the lesion mask. Required when
  `process = "sct_deepseg_lesion"`, ignored otherwise. Default `NULL`.

- plane:

  Character. `"sagittal"` (default) or `"axial"`; the plane of a lesion
  report.

## Value

Exit code (invisible).

## Details

For a lesion report (`process = "sct_deepseg_lesion"`), `segmentation`
is the spinal cord mask and `lesion` the lesion mask; `sct_qc` then also
needs the `plane` of the report.

## Examples

``` r
# Inputs are checked before SCT is called:
try(sct_generate_qc("missing_T2w.nii.gz", "missing_seg.nii.gz",
                    file.path(tempdir(), "qc")))
#> Error in sct_generate_qc("missing_T2w.nii.gz", "missing_seg.nii.gz", file.path(tempdir(),  : 
#>   Input file not found: missing_T2w.nii.gz

# \donttest{
# With SCT installed: QC report of the PAM50 template cord mask.
sct <- check_sct(verbose = FALSE)
if (sct$available) {
  pam50 <- file.path(dirname(dirname(sct$path)), "data", "PAM50",
                     "template")
  t2w <- file.path(pam50, "PAM50_t2.nii.gz")
  seg <- file.path(pam50, "PAM50_cord.nii.gz")
  if (file.exists(t2w) && file.exists(seg)) {
    sct_generate_qc(t2w, seg, qc_dir = file.path(tempdir(), "qc"))
  }
}
# }
```
