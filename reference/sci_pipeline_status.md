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
if (FALSE) { # \dontrun{
sci_pipeline_status("~/projects/my-sci-study")
} # }
```
