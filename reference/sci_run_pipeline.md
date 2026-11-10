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
proj <- file.path(tempdir(), "pipeline-study")
sci_create_project(proj, open = FALSE)
#> 
#> ── Creating SCI project: SCI Imaging Analysis ──────────────────────────────────
#> ✔ Directory structure created.
#> ✔ Templates created.
#> ✔ Project created at /tmp/RtmpGur4Jb/pipeline-study
#> ℹ Next steps:
#>   1. Place DICOM files in data/raw/dicom/
#>   2. Fill in data/metadata/imaging_registry.csv
#>   3. Fill in data/metadata/clinical_data.csv
#>   4. Run `sci_run_pipeline()`
sci_run_pipeline(proj, steps = 1:3)
#> 
#> ── Step 1: DICOM metadata extraction ──
#> 
#> ℹ Running step 1...
#> Step 2 (Anonymization): skipped (anonymize = FALSE)
#> 
#> ── Step 3: DICOM to NIfTI conversion ──
#> 
#> ℹ Running step 3...
#> 
#> ── Pipeline Summary ──
#> 
#> 2 complete, 0 errors, 1 skipped
#> # A tibble: 3 × 4
#>    step name                      status   message            
#>   <int> <chr>                     <chr>    <chr>              
#> 1     1 DICOM metadata extraction complete ""                 
#> 2     2 Anonymization             skipped  "anonymize = FALSE"
#> 3     3 DICOM to NIfTI conversion complete ""                 
unlink(proj, recursive = TRUE)
```
