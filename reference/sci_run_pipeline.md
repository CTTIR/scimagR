# Plan the SCI Analysis Pipeline

Checks a project created with
[`sci_create_project()`](https://cttir.github.io/scimagR/reference/sci_create_project.md)
and returns the plan of processing steps, each with the function that
performs it:

1.  DICOM metadata extraction
    ([`extract_dicom_metadata()`](https://cttir.github.io/scimagR/reference/extract_dicom_metadata.md))

2.  Anonymisation, if requested
    ([`anonymize_dicom()`](https://cttir.github.io/scimagR/reference/anonymize_dicom.md))

3.  DICOM to NIfTI conversion
    ([`convert_batch()`](https://cttir.github.io/scimagR/reference/convert_batch.md))

4.  Spinal cord segmentation
    ([`sct_segment_sc()`](https://cttir.github.io/scimagR/reference/sct_segment_sc.md))

5.  Lesion segmentation with SCIsegV2
    ([`sct_segment_lesion()`](https://cttir.github.io/scimagR/reference/sct_segment_lesion.md))

6.  Vertebral labelling
    ([`sct_label_vertebrae()`](https://cttir.github.io/scimagR/reference/sct_label_vertebrae.md))

7.  Parameter extraction
    ([`sct_analyze_lesion()`](https://cttir.github.io/scimagR/reference/sct_analyze_lesion.md),
    [`sct_process_segmentation()`](https://cttir.github.io/scimagR/reference/sct_process_segmentation.md))

8.  Merge & export
    ([`save_table()`](https://cttir.github.io/scimagR/reference/save_table.md),
    [`save_rds()`](https://cttir.github.io/scimagR/reference/save_rds.md))

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

  Integer vector. Which steps (1–8) to include in the plan. Default
  `1:8`. Other values are skipped with a warning.

- anonymize:

  Logical. Include the anonymisation step (step 2). Default `FALSE`.

- overwrite:

  Logical. Kept for compatibility; not used, because no step is run.
  Default `FALSE`.

- verbose:

  Logical. Print the plan. Default `TRUE`.

## Value

Tibble with one row per requested step: `step`, `name`, `status`
(`"pending"` or `"skipped"`) and `message` (the function to run, or the
reason for skipping).

## Details

`sci_run_pipeline()` is a planner, not a runner. It does **not** call
the Spinal Cord Toolbox, 'dcm2niix' or 'pydicom', does not read or write
any image, and does not look at which outputs already exist: every
requested step is reported as `"pending"` (step 2 as `"skipped"` unless
`anonymize = TRUE`), whatever its state on disk. Run the function named
in each row to perform the step, and use
[`sci_pipeline_status()`](https://cttir.github.io/scimagR/reference/sci_pipeline_status.md)
to see which outputs exist.

## Examples

``` r
proj <- file.path(tempdir(), "pipeline-study")
sci_create_project(proj, open = FALSE)
#> 
#> ── Creating SCI project: SCI Imaging Analysis ──────────────────────────────────
#> ✔ Directory structure created.
#> ✔ Templates created.
#> ✔ Project created at /tmp/Rtmptg3SMc/pipeline-study
#> ℹ Next steps:
#>   1. Place DICOM files in data/raw/dicom/
#>   2. Fill in data/metadata/imaging_registry.csv
#>   3. Fill in data/metadata/clinical_data.csv
#>   4. Plan the processing steps with `sci_run_pipeline()`
sci_run_pipeline(proj, steps = 1:3)
#> 
#> ── Step 1: DICOM metadata extraction ──
#> 
#> ℹ Run `extract_dicom_metadata()` for this step.
#> Step 2 (Anonymisation): skipped (anonymize = FALSE)
#> 
#> ── Step 3: DICOM to NIfTI conversion ──
#> 
#> ℹ Run `convert_batch()` for this step.
#> 
#> ── Pipeline Summary ──
#> 
#> 2 pending, 1 skipped
#> # A tibble: 3 × 4
#>    step name                      status  message                     
#>   <int> <chr>                     <chr>   <chr>                       
#> 1     1 DICOM metadata extraction pending run extract_dicom_metadata()
#> 2     2 Anonymisation             skipped anonymize = FALSE           
#> 3     3 DICOM to NIfTI conversion pending run convert_batch()         
unlink(proj, recursive = TRUE)
```
