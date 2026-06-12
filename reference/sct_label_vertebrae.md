# Label Vertebral Levels

Runs SCT's vertebral labeling on a spinal cord segmentation.

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

  Character. MRI contrast type. Default `"t2"`.

- output_dir:

  Character. Directory for output labels. Defaults to the directory of
  `input`.

- overwrite:

  Logical. Re-run if output exists? Default `FALSE`.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Character. Path to vertebral label NIfTI, or `NA` on failure.

## Examples

``` r
if (FALSE) { # \dontrun{
sct_label_vertebrae("sub-01_T2w.nii.gz", "sub-01_T2w_seg.nii.gz")
} # }
```
