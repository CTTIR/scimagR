# Extract Morphometric Parameters

Runs `sct_process_segmentation` to compute cross-sectional area (CSA),
AP diameter, and transverse diameter per vertebral level.

## Usage

``` r
sct_process_segmentation(
  sc_seg,
  vert_labels,
  output_dir = NULL,
  perslice = FALSE,
  verbose = TRUE
)
```

## Arguments

- sc_seg:

  Character. Path to spinal cord segmentation NIfTI.

- vert_labels:

  Character. Path to vertebral labels NIfTI.

- output_dir:

  Character. Directory for CSV output.

- perslice:

  Logical. Compute per-slice metrics. Default `FALSE`.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Character. Path to output CSV, or `NA` on failure.

## Examples

``` r
if (FALSE) { # \dontrun{
sct_process_segmentation("sub-01_seg.nii.gz", "sub-01_labels-disc.nii.gz")
} # }
```
