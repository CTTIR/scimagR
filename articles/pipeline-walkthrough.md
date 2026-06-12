# Pipeline Walkthrough

## Overview

[`sci_run_pipeline()`](https://cttir.github.io/scimagR/reference/sci_run_pipeline.md)
orchestrates the full SCI imaging processing workflow in 8 sequential
steps. Each step is idempotent and the pipeline can be interrupted and
resumed at any point.

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

## Running the Full Pipeline

``` r

library(scimagR)

status <- sci_run_pipeline(
  project_dir = "~/projects/my-sci-study",
  steps = 1:8,
  anonymize = FALSE
)
```

## Running Individual Steps

Run only specific steps by setting the `steps` argument:

``` r

# Just convert DICOMs
sci_run_pipeline("~/projects/my-sci-study", steps = 3)

# Run segmentation steps
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

The pipeline is designed to be resilient to interruptions. Simply re-run
with the same arguments — existing outputs will be detected and skipped:

``` r

# Re-running skips completed steps automatically
sci_run_pipeline("~/projects/my-sci-study", steps = 1:8)

# Force re-processing with overwrite = TRUE
sci_run_pipeline("~/projects/my-sci-study", steps = 4:5, overwrite = TRUE)
```
