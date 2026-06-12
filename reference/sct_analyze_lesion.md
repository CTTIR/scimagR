# Extract Lesion Parameters

Runs `sct_analyze_lesion` to compute lesion volume, length, max axial
damage ratio, and tissue bridge measurements.

## Usage

``` r
sct_analyze_lesion(lesion_seg, sc_seg, output_dir = NULL, verbose = TRUE)
```

## Arguments

- lesion_seg:

  Character. Path to lesion segmentation NIfTI.

- sc_seg:

  Character. Path to spinal cord segmentation NIfTI.

- output_dir:

  Character. Directory for CSV output.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Character. Path to output CSV, or `NA` on failure.

## Examples

``` r
if (FALSE) { # \dontrun{
sct_analyze_lesion("sub-01_lesion_seg.nii.gz", "sub-01_seg.nii.gz")
} # }
```
