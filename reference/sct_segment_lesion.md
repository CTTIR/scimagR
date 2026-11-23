# Segment SCI Lesion

Runs the SCIsegV2 lesion segmentation model (Karthik et al. 2025)
through `sct_deepseg` (`sct_deepseg lesion_sci_t2` from SCT 7.0,
`sct_deepseg -task seg_sc_lesion_t2w_sci` before). The model segments
both the lesion and the spinal cord: the lesion mask is written to
`output`, the cord mask next to it with the suffix `_sc_seg` (for the
default output `<input>_lesion_seg.nii.gz` this is
`<input>_sc_seg.nii.gz`).

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

  Character. Path for output lesion segmentation. Auto-generated if
  `NULL`: `<input>_lesion_seg.nii.gz` in `output_dir`.

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

Character. Path to output lesion segmentation, or `NA` on failure
(non-zero exit status, no lesion mask written, or the mask could not be
saved to `output`).

## References

Karthik EN, Valošek J, Farner L, et al. (2025). SCIsegV2: A universal
tool for segmentation of intramedullary lesions in spinal cord injury.
In *Applications of Medical Artificial Intelligence* (AMAI 2024),
Lecture Notes in Computer Science, pp. 198–209.
[doi:10.1007/978-3-031-82007-6_19](https://doi.org/10.1007/978-3-031-82007-6_19)

## Examples

``` r
# Without the Spinal Cord Toolbox: an existing lesion mask is returned as
# is (here an empty placeholder file).
dir <- file.path(tempdir(), "sct-lesion-example")
dir.create(dir, showWarnings = FALSE)
t2w <- file.path(dir, "sub-01_T2w.nii.gz")
file.create(t2w, file.path(dir, "sub-01_T2w_lesion_seg.nii.gz"))
#> [1] TRUE TRUE
sct_segment_lesion(t2w)
#> ℹ Output exists, skipping: /tmp/Rtmptg3SMc/sct-lesion-example/sub-01_T2w_lesion_seg.nii.gz
#> [1] "/tmp/Rtmptg3SMc/sct-lesion-example/sub-01_T2w_lesion_seg.nii.gz"
unlink(dir, recursive = TRUE)

# \donttest{
# With SCT installed: run SCIsegV2 on your own T2-weighted image.
# This runs a deep-learning model and can take several minutes.
t2w <- "sub-01_T2w.nii.gz"
if (check_sct(verbose = FALSE)$available && file.exists(t2w)) {
  sct_segment_lesion(t2w, output_dir = tempdir())
}
# }
```
