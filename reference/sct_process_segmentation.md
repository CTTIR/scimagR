# Extract Morphometric Parameters

Runs `sct_process_segmentation` to compute cross-sectional area (CSA),
AP diameter, transverse diameter and other shape metrics of the spinal
cord. By default SCT averages the metrics over all slices of the
segmentation and leaves the `VertLevel` column of the CSV empty. Use
`vert` to restrict the average to vertebral levels (`VertLevel` then
lists them), `perlevel = TRUE` to get one row per level, or
`perslice = TRUE` to get one row per slice with its vertebral level.

## Usage

``` r
sct_process_segmentation(
  sc_seg,
  vert_labels,
  output_dir = NULL,
  perslice = FALSE,
  verbose = TRUE,
  vert = NULL,
  perlevel = FALSE
)
```

## Arguments

- sc_seg:

  Character. Path to spinal cord segmentation NIfTI.

- vert_labels:

  Character. Path to the vertebral level file, i.e. the labelled
  segmentation returned by
  [`sct_label_vertebrae()`](https://cttir.github.io/scimagR/reference/sct_label_vertebrae.md).

- output_dir:

  Character. Directory for CSV output. Defaults to the directory of
  `sc_seg`.

- perslice:

  Logical. Compute per-slice metrics. Default `FALSE`.

- verbose:

  Logical. Print progress. Default `TRUE`.

- vert:

  Vertebral levels to aggregate over, as a numeric vector (e.g. `2:7`
  for C2 to C7) or a character string in SCT syntax (e.g. `"2:7"`).
  Default `NULL` (all slices).

- perlevel:

  Logical. One row per vertebral level in `vert`. Needs `vert`. Default
  `FALSE`.

## Value

Character. Path to output CSV (`<sc_seg>_csa.csv`), or `NA` on failure
(non-zero exit status, or no CSV written).

## Examples

``` r
# Inputs are checked before SCT is called:
try(sct_process_segmentation("missing_seg.nii.gz",
                             "missing_seg_labeled.nii.gz"))
#> Error in sct_process_segmentation("missing_seg.nii.gz", "missing_seg_labeled.nii.gz") : 
#>   SC segmentation not found: missing_seg.nii.gz

# \donttest{
# With SCT installed: CSA per vertebral level of the PAM50 template cord.
sct <- check_sct(verbose = FALSE)
if (sct$available) {
  pam50 <- file.path(dirname(dirname(sct$path)), "data", "PAM50",
                     "template")
  cord <- file.path(pam50, "PAM50_cord.nii.gz")
  levels <- file.path(pam50, "PAM50_levels.nii.gz")
  if (file.exists(cord) && file.exists(levels)) {
    csv <- sct_process_segmentation(cord, levels, output_dir = tempdir(),
                                    vert = 2:4, perlevel = TRUE)
    if (!is.na(csv)) utils::read.csv(csv, check.names = FALSE)
  }
}
# }
```
