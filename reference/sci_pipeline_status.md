# Get Pipeline Status

Scans the project directory and reports which processing steps are
complete for each patient and session.

## Usage

``` r
sci_pipeline_status(project_dir)
```

## Arguments

- project_dir:

  Character. Path to workflowr project root.

## Value

Tibble with columns: `pat_id`, `session`, `converted`, `sc_seg`,
`lesion_seg`, `vert_labels`, `qc_done`, `params_extracted`.

## Examples

``` r
proj <- file.path(tempdir(), "status-study")
sci_create_project(proj, open = FALSE)
#> 
#> ── Creating SCI project: SCI Imaging Analysis ──────────────────────────────────
#> ✔ Directory structure created.
#> ✔ Templates created.
#> ✔ Project created at /tmp/RtmptOUSAu/status-study
#> ℹ Next steps:
#>   1. Place DICOM files in data/raw/dicom/
#>   2. Fill in data/metadata/imaging_registry.csv
#>   3. Fill in data/metadata/clinical_data.csv
#>   4. Run `sci_run_pipeline()`
sci_pipeline_status(proj)
#> # A tibble: 0 × 0
unlink(proj, recursive = TRUE)
```
