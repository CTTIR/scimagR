# Get Pipeline Status

Scans `data/nifti/<pat_id>/<session>/` of the project and reports which
processing outputs exist for each patient and session. A step counts as
done when its file is present:

- `converted`: any `.nii` or `.nii.gz` file;

- `sc_seg`: a spinal cord mask, `*_seg.nii(.gz)` other than a lesion
  mask;

- `lesion_seg`: a lesion mask, `*_lesion_seg.nii(.gz)`;

- `vert_labels`: vertebral labels from
  [`sct_label_vertebrae()`](https://cttir.github.io/scimagR/reference/sct_label_vertebrae.md),
  `*_labeled.nii(.gz)` or `*_labeled_discs.nii(.gz)` (the earlier naming
  `*_labels-disc.nii(.gz)` is also recognised);

- `qc_done`: a `qc/` folder in the session folder;

- `params_extracted`: a `.csv` file or an `*_analysis.xls(x)`
  spreadsheet from
  [`sct_analyze_lesion()`](https://cttir.github.io/scimagR/reference/sct_analyze_lesion.md).

## Usage

``` r
sci_pipeline_status(project_dir)
```

## Arguments

- project_dir:

  Character. Path to workflowr project root.

## Value

Tibble with one row per session and the columns `pat_id`, `session`,
`converted`, `sc_seg`, `lesion_seg`, `vert_labels`, `qc_done`,
`params_extracted` (zero rows if no session folder exists).

## Examples

``` r
proj <- file.path(tempdir(), "status-study")
sci_create_project(proj, open = FALSE)
#> 
#> ── Creating SCI project: SCI Imaging Analysis ──────────────────────────────────
#> ✔ Directory structure created.
#> ✔ Templates created.
#> ✔ Project created at /tmp/Rtmp0suB2O/status-study
#> ℹ Next steps:
#>   1. Place DICOM files in data/raw/dicom/
#>   2. Fill in data/metadata/imaging_registry.csv
#>   3. Fill in data/metadata/clinical_data.csv
#>   4. Plan the processing steps with `sci_run_pipeline()`
sci_pipeline_status(proj)
#> # A tibble: 0 × 8
#> # ℹ 8 variables: pat_id <chr>, session <chr>, converted <lgl>, sc_seg <lgl>,
#> #   lesion_seg <lgl>, vert_labels <lgl>, qc_done <lgl>, params_extracted <lgl>
unlink(proj, recursive = TRUE)
```
