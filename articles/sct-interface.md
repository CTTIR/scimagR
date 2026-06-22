# SCT Interface

[![R-CMD-check](https://github.com/CTTIR/scimagR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CTTIR/scimagR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/CTTIR/scimagR/actions/workflows/pkgdown.yaml/badge.svg)](https://cttir.github.io/scimagR/)
[![CRAN
status](https://www.r-pkg.org/badges/version/scimagR)](https://CRAN.R-project.org/package=scimagR)
[![Codecov test
coverage](https://codecov.io/gh/CTTIR/scimagR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/CTTIR/scimagR?branch=main)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/scimagR)](https://cran.r-project.org/package=scimagR)
[![CRAN downloads
total](https://cranlogs.r-pkg.org/badges/grand-total/scimagR)](https://cran.r-project.org/package=scimagR)
[![License:
MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

## Overview

scimagR provides R wrappers for the Spinal Cord Toolbox (SCT)
command-line tools. These wrappers handle: - Path resolution (respects
`SCT_DIR` environment variable) - Input validation - Idempotent
execution (skip if output exists) - Structured error reporting -
Optional QC report generation

## Configuration

Set the `SCT_DIR` environment variable if SCT is not on your PATH:

``` r

Sys.setenv(SCT_DIR = "/path/to/sct")
```

Or add it to your `.Renviron`:

    SCT_DIR=/path/to/sct

## Spinal Cord Segmentation

``` r

library(scimagR)

sc_seg <- sct_segment_sc(
  input = "sub-01_T2w.nii.gz",
  qc_dir = "qc/"
)
```

## Lesion Segmentation (SCIsegV2)

``` r

lesion_seg <- sct_segment_lesion(
  input = "sub-01_T2w.nii.gz",
  qc_dir = "qc/"
)
```

## Vertebral Labeling

``` r

vert_labels <- sct_label_vertebrae(
  input = "sub-01_T2w.nii.gz",
  segmentation = sc_seg
)
```

## Parameter Extraction

``` r

# Lesion parameters (volume, length, tissue bridges)
lesion_csv <- sct_analyze_lesion(
  lesion_seg = lesion_seg,
  sc_seg = sc_seg
)

# Morphometric parameters (CSA, diameters per level)
csa_csv <- sct_process_segmentation(
  sc_seg = sc_seg,
  vert_labels = vert_labels
)
```

## QC Reports

Generate HTML QC reports to visually verify segmentations:

``` r

sct_generate_qc(
  input = "sub-01_T2w.nii.gz",
  segmentation = sc_seg,
  qc_dir = "qc/"
)
```

## Idempotent Execution

All SCT wrappers are idempotent by default. If the output file already
exists, the function returns the existing path without re-running:

``` r

# First call: runs segmentation
sct_segment_sc("sub-01_T2w.nii.gz")

# Second call: skips, returns existing path
sct_segment_sc("sub-01_T2w.nii.gz")

# Force re-run:
sct_segment_sc("sub-01_T2w.nii.gz", overwrite = TRUE)
```

## Troubleshooting

Common issues:

- **“Cannot find sct_deepseg on PATH”**: Set `SCT_DIR` or add SCT `bin/`
  to PATH
- **Segmentation fails silently**: Check stderr output in the returned
  result
- **Python errors**: Ensure the correct Python environment is activated
