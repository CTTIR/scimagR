# Run the SCI Analysis Pipeline

Orchestrates all external tool steps in sequence:

1.  DICOM metadata extraction

2.  Anonymization (if requested)

3.  DICOM to NIfTI conversion

4.  Spinal cord segmentation

5.  Lesion segmentation (SCIsegV2)

6.  Vertebral labeling

7.  Parameter extraction

8.  Merge & export

## Usage

``` r
sci_run_pipeline(
  project_dir,
  steps = 1:8,
  anonymize = FALSE,
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- project_dir:

  Character. Path to workflowr project root.

- steps:

  Integer vector. Which steps to run. Default `1:8`.

- anonymize:

  Logical. Run anonymization step. Default `FALSE`.

- overwrite:

  Logical. Re-process existing outputs. Default `FALSE`.

- verbose:

  Logical. Print progress. Default `TRUE`.

## Value

Tibble with pipeline status per step.

## Details

Each step checks for existing outputs (idempotent). The pipeline can be
interrupted and resumed at any step.

## Examples

``` r
if (FALSE) { # \dontrun{
sci_run_pipeline("~/projects/my-sci-study", steps = 1:3)
} # }
```
