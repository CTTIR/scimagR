# Pipeline Walkthrough

![scimagR logo](figures/logo.svg)![scimagR logo](figures/logo-dark.svg)

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

The SCI imaging workflow has 8 sequential steps, each performed by its
own function (Spinal Cord Toolbox, ‘dcm2niix’ and ‘pydicom’ wrappers).
[`sci_run_pipeline()`](https://cttir.github.io/scimagR/reference/sci_run_pipeline.md)
checks the project and returns this plan, naming the function to run for
every requested step; it does not run the external tools itself, so each
step is reported as `"pending"`.

## Pipeline Steps

| Step | Name                      | Tool           | Output                      |
|------|---------------------------|----------------|-----------------------------|
| 1    | DICOM metadata extraction | pydicom        | metadata CSV                |
| 2    | Anonymization (optional)  | pydicom        | anonymized DICOMs + mapping |
| 3    | DICOM to NIfTI conversion | dcm2niix       | .nii.gz files               |
| 4    | Spinal cord segmentation  | SCT            | \_seg.nii.gz                |
| 5    | Lesion segmentation       | SCT (SCIsegV2) | \_lesion_seg.nii.gz         |
| 6    | Vertebral labeling        | SCT            | \_labels-disc.nii.gz        |
| 7    | Parameter extraction      | SCT            | CSVs with metrics           |
| 8    | Merge & export            | R              | combined dataset            |

## Planning the Pipeline

``` r

library(scimagR)

status <- sci_run_pipeline(
  project_dir = "~/projects/my-sci-study",
  steps = 1:8,
  anonymize = FALSE
)
```

## Running Individual Steps

Plan only specific steps by setting the `steps` argument, then run the
function each row names:

``` r

# Just the DICOM conversion
sci_run_pipeline("~/projects/my-sci-study", steps = 3)

# The segmentation steps
sci_run_pipeline("~/projects/my-sci-study", steps = 4:5)
```

## The QC Pause

After Step 5 (lesion segmentation), the pipeline pauses for manual QC.
This is critical: automated lesion segmentation must be visually
verified before extracting quantitative parameters.

During the QC pause:

1.  Open the QC HTML reports in `data/qc/`
2.  Grade each segmentation in the QC log
3.  Re-run failed segmentations if needed
4.  Continue with steps 6-8

## Checking Pipeline Status

``` r

sci_pipeline_status("~/projects/my-sci-study")
```

This returns a tibble showing which steps are complete for each patient
and session.

## Artifact Grading Strategy

After visual QC, assign artifact grades (0-4) in the imaging registry:

- **0 (none)**: Perfect image quality
- **1 (mild)**: Minor artifacts, measurements reliable
- **2 (moderate)**: Visible artifacts, measurements acceptable
- **3 (severe)**: Major artifacts, measurements unreliable
- **4 (non-evaluable)**: Cannot be analyzed

Use
[`filter_evaluable()`](https://cttir.github.io/scimagR/reference/filter_evaluable.md)
to exclude sessions with grade \> 2:

``` r

evaluable <- filter_evaluable(registry, max_artifact = 2)
```

## Coverage Matrix

After processing, check your data coverage:

``` r

plot_coverage(registry)
```

This tile plot shows which modalities are available for each patient at
each timepoint, with artifact grades overlaid.

## Resuming After Interruption

[`sci_pipeline_status()`](https://cttir.github.io/scimagR/reference/sci_pipeline_status.md)
scans the project for existing outputs, so after an interruption it
shows where to continue:

``` r

sci_pipeline_status("~/projects/my-sci-study")
```
