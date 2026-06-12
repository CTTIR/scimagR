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
if (FALSE) { # \dontrun{
sci_create_project("~/projects/my-sci-study",
  title = "Cervical SCI Longitudinal MRI Analysis",
  author = "Raban Heller")
} # }
```
