# Segment Spinal Cord

Runs the contrast-agnostic spinal cord segmentation model of the Spinal
Cord Toolbox (Bédard et al. 2025) through `sct_deepseg`. The wrapper
uses the task syntax of the installed SCT version
(`sct_deepseg spinalcord` from SCT 7.0,
`sct_deepseg -task seg_sc_contrast_agnostic` before).

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

  Character. Path for output segmentation. Auto-generated if `NULL`:
  `<input>_seg.nii.gz` in `output_dir`.

- output_dir:

  Character. Directory for output. Alternative to `output`. Defaults to
  the directory of `input`.

- overwrite:

  Logical. Re-run if output exists? Default `FALSE` (idempotent).

- verbose:

  Logical. Print progress. Default `TRUE`.

- qc_dir:

  Character. If provided, `sct_deepseg` also writes its HTML QC report
  to this directory.

## Value

Character. Path to output segmentation file, or `NA` on failure
(non-zero exit status, or no output file written).

## References

Bédard S, Karthik EN, Tsagkas C, et al. (2025). Towards
contrast-agnostic soft segmentation of the spinal cord. *Medical Image
Analysis* 101:103473.
[doi:10.1016/j.media.2025.103473](https://doi.org/10.1016/j.media.2025.103473)

## Examples

``` r
# Without the Spinal Cord Toolbox: an existing output is returned as is,
# so finished sessions are skipped (here with an empty placeholder file).
dir <- file.path(tempdir(), "sct-seg-example")
dir.create(dir, showWarnings = FALSE)
t2w <- file.path(dir, "sub-01_T2w.nii.gz")
file.create(t2w, file.path(dir, "sub-01_T2w_seg.nii.gz"))
#> [1] TRUE TRUE
sct_segment_sc(t2w)
#> ℹ Output exists, skipping: /tmp/Rtmptg3SMc/sct-seg-example/sub-01_T2w_seg.nii.gz
#> [1] "/tmp/Rtmptg3SMc/sct-seg-example/sub-01_T2w_seg.nii.gz"
unlink(dir, recursive = TRUE)

# \donttest{
# With SCT installed: segment the PAM50 T2w template shipped with SCT.
# This runs a deep-learning model and can take several minutes.
sct <- check_sct(verbose = FALSE)
if (sct$available && interactive()) {
  pam50_t2 <- file.path(dirname(dirname(sct$path)), "data", "PAM50",
                        "template", "PAM50_t2.nii.gz")
  if (file.exists(pam50_t2)) {
    sct_segment_sc(pam50_t2, output_dir = tempdir())
  }
}
# }
```
