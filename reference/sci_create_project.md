# Create a New SCI MRI/CT Analysis Project

Sets up a complete workflowr project with full directory structure,
pre-configured YAML files, template Rmd files, CSV templates, and a
`.gitignore` tuned for neuroimaging projects.

## Usage

``` r
sci_create_project(
  path,
  title = "SCI Imaging Analysis",
  author = "Author Name",
  seed = 20260411L,
  open = TRUE
)
```

## Arguments

- path:

  Character. Directory for the new project.

- title:

  Character. Project title.

- author:

  Character. Author name.

- seed:

  Integer. Reproducibility seed. Default `20260411`.

- open:

  Logical. Open project in RStudio. Default `TRUE`.

## Value

Character. Path to created project (invisible).

## Examples

``` r
proj <- file.path(tempdir(), "my-sci-study")
sci_create_project(proj,
  title = "Cervical SCI Longitudinal MRI Analysis",
  author = "Jane Doe", open = FALSE)
#> 
#> ── Creating SCI project: Cervical SCI Longitudinal MRI Analysis ────────────────
#> ✔ Directory structure created.
#> ✔ Templates created.
#> ✔ Project created at /tmp/RtmptOUSAu/my-sci-study
#> ℹ Next steps:
#>   1. Place DICOM files in data/raw/dicom/
#>   2. Fill in data/metadata/imaging_registry.csv
#>   3. Fill in data/metadata/clinical_data.csv
#>   4. Run `sci_run_pipeline()`
list.files(proj)
#> [1] "analysis"   "code"       "data"       "manuscript" "results"   
#> [6] "scripts"   
unlink(proj, recursive = TRUE)
```
