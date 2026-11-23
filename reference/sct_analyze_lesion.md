# Extract Lesion Parameters

Runs `sct_analyze_lesion` to compute lesion volume, length, maximum
axial damage ratio and tissue bridge measurements. SCT writes the
results to a spreadsheet named after the lesion mask:
`<lesion_seg>_analysis.xlsx` (SCT 6.5 and later) or
`<lesion_seg>_analysis.xls` (SCT 6.4).

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

  Character. Directory for the output files. Defaults to the directory
  of `lesion_seg`.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Character. Path to the analysis spreadsheet written by SCT, or `NA` on
failure (non-zero exit status, or no spreadsheet written).

## Examples

``` r
# Inputs are checked before SCT is called:
try(sct_analyze_lesion("missing_lesion_seg.nii.gz", "missing_seg.nii.gz"))
#> Error in sct_analyze_lesion("missing_lesion_seg.nii.gz", "missing_seg.nii.gz") : 
#>   Lesion segmentation not found: missing_lesion_seg.nii.gz

# \donttest{
# With SCT installed: analyse your own lesion and cord masks, for example
# those written by sct_segment_lesion().
lesion <- "sub-01_T2w_lesion_seg.nii.gz"
cord <- "sub-01_T2w_sc_seg.nii.gz"
if (check_sct(verbose = FALSE)$available &&
    file.exists(lesion) && file.exists(cord)) {
  sct_analyze_lesion(lesion, cord, output_dir = tempdir())
}
# }
```
