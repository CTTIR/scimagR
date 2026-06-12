# SCT Interface

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
