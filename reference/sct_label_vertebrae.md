# Label Vertebral Levels

Runs SCT's `sct_label_vertebrae` on a spinal cord segmentation. SCT
writes two files into `output_dir`, both named after the segmentation:
`<segmentation>_labeled.nii.gz` (the cord segmentation with each voxel
set to its vertebral level) and `<segmentation>_labeled_discs.nii.gz`
(one label per intervertebral disc). The first is returned, because it
is the vertebral level file that
[`sct_process_segmentation()`](https://cttir.github.io/scimagR/reference/sct_process_segmentation.md)
expects.

## Usage

``` r
sct_label_vertebrae(
  input,
  segmentation,
  contrast = "t2",
  output_dir = NULL,
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- input:

  Character. Path to T2w NIfTI file.

- segmentation:

  Character. Path to spinal cord segmentation.

- contrast:

  Character. MRI contrast type, `"t2"` (cord dark, CSF bright) or
  `"t1"`. Default `"t2"`.

- output_dir:

  Character. Directory for output labels. Defaults to the directory of
  `input`.

- overwrite:

  Logical. Re-run if output exists? Default `FALSE`.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Character. Path to the labelled segmentation
(`<segmentation>_labeled.nii.gz`), or `NA` on failure (non-zero exit
status, or no output file written).

## Examples

``` r
# Without the Spinal Cord Toolbox: an existing labelled segmentation is
# returned as is (here an empty placeholder file).
dir <- file.path(tempdir(), "sct-label-example")
dir.create(dir, showWarnings = FALSE)
t2w <- file.path(dir, "sub-01_T2w.nii.gz")
seg <- file.path(dir, "sub-01_T2w_seg.nii.gz")
file.create(t2w, seg, file.path(dir, "sub-01_T2w_seg_labeled.nii.gz"))
#> [1] TRUE TRUE TRUE
sct_label_vertebrae(t2w, seg)
#> ℹ Output exists, skipping: /tmp/Rtmp0suB2O/sct-label-example/sub-01_T2w_seg_labeled.nii.gz
#> [1] "/tmp/Rtmp0suB2O/sct-label-example/sub-01_T2w_seg_labeled.nii.gz"
unlink(dir, recursive = TRUE)

# \donttest{
# With SCT installed: label the PAM50 template (takes about a minute).
sct <- check_sct(verbose = FALSE)
if (sct$available && interactive()) {
  pam50 <- file.path(dirname(dirname(sct$path)), "data", "PAM50",
                     "template")
  t2w <- file.path(pam50, "PAM50_t2.nii.gz")
  seg <- file.path(pam50, "PAM50_cord.nii.gz")
  if (file.exists(t2w) && file.exists(seg)) {
    sct_label_vertebrae(t2w, seg, output_dir = tempdir())
  }
}
# }
```
