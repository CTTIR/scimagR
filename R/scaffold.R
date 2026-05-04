#' Create a New SCI MRI/CT Analysis Project
#'
#' Sets up a complete workflowr project with full directory structure,
#' pre-configured YAML files, template Rmd files, CSV templates, and
#' a `.gitignore` tuned for neuroimaging projects.
#'
#' @param path Character. Directory for the new project.
#' @param title Character. Project title.
#' @param author Character. Author name.
#' @param seed Integer. Reproducibility seed. Default `20260411`.
#' @param open Logical. Open project in RStudio. Default `TRUE`.
#' @return Character. Path to created project (invisible).
#' @export
#' @examples
#' \dontrun{
#' sci_create_project("~/projects/my-sci-study",
#'   title = "Cervical SCI Longitudinal MRI Analysis",
#'   author = "Raban Heller")
#' }
sci_create_project <- function(path,
                               title = "SCI Imaging Analysis",
                               author = "Author Name",
                               seed = 20260411L,
                               open = TRUE) {
  rlang::check_required(path)

  if (dir.exists(path)) {
    cli::cli_abort("Directory already exists: {.path {path}}")
  }

  cli::cli_h1("Creating SCI project: {title}")

  # Create directory structure
  dirs <- c(
    "analysis",
    "code",
    "data/raw/dicom",
    "data/raw/clinical",
    "data/nifti",
    "data/metadata",
    "data/segmentations",
    "data/parameters",
    "data/qc",
    "scripts",
    "results/figures",
    "results/tables",
    "results/models",
    "manuscript"
  )

  for (d in dirs) {
    dir.create(file.path(path, d), recursive = TRUE, showWarnings = FALSE)
  }
  cli::cli_alert_success("Directory structure created.")

  # Copy and fill templates
  template_dir <- system.file("templates", package = "scimagR")

  # _workflowr.yml
  writeLines(
    c(
      glue::glue("seed: {seed}"),
      "github: null"
    ),
    file.path(path, "analysis", "_workflowr.yml")
  )

  # _site.yml
  writeLines(
    c(
      glue::glue('name: "{title}"'),
      "output_dir: ../docs",
      "navbar:",
      glue::glue('  title: "{title}"'),
      "  left:",
      '    - text: "Home"',
      '      href: index.html',
      '    - text: "Pipeline"',
      '      menu:',
      '        - text: "00 Orchestrate"',
      '          href: 00-orchestrate.html',
      '        - text: "01 Data"',
      '          href: 01-data.html',
      '    - text: "Analysis"',
      '      menu:',
      '        - text: "02 Descriptive"',
      '          href: 02-descriptive.html',
      '        - text: "03 Lesion"',
      '          href: 03-lesion.html',
      '        - text: "04 Canal"',
      '          href: 04-canal.html',
      '        - text: "05 Longitudinal"',
      '          href: 05-longitudinal.html',
      '    - text: "Advanced"',
      '      menu:',
      '        - text: "06 Sensitivity"',
      '          href: 06-sensitivity.html',
      '        - text: "07 Prediction"',
      '          href: 07-prediction.html',
      '    - text: "Output"',
      '      menu:',
      '        - text: "08 Figures"',
      '          href: 08-manuscript-figures.html',
      '        - text: "09 Report"',
      '          href: 09-report.html',
      '    - text: "About"',
      '      href: about.html',
      '    - text: "License"',
      '      href: license.html',
      "output:",
      "  workflowr::wflow_html:",
      "    toc: true",
      "    toc_float: true",
      "    theme: cosmo",
      "    highlight: textmate"
    ),
    file.path(path, "analysis", "_site.yml")
  )

  # 00-config.R
  writeLines(
    c(
      "# Project configuration",
      glue::glue("# {title}"),
      glue::glue("# Author: {author}"),
      glue::glue("# Seed: {seed}"),
      "",
      "library(scimagR)",
      "library(dplyr)",
      "library(ggplot2)",
      "",
      "# Paths",
      'dir_data    <- here::here("data")',
      'dir_raw     <- here::here("data", "raw")',
      'dir_nifti   <- here::here("data", "nifti")',
      'dir_meta    <- here::here("data", "metadata")',
      'dir_seg     <- here::here("data", "segmentations")',
      'dir_params  <- here::here("data", "parameters")',
      'dir_qc      <- here::here("data", "qc")',
      'dir_results <- here::here("results")',
      'dir_figs    <- here::here("results", "figures")',
      'dir_tables  <- here::here("results", "tables")',
      'dir_models  <- here::here("results", "models")',
      "",
      "# Theme & palettes",
      "ggplot2::theme_set(theme_sci())",
      "",
      glue::glue("set.seed({seed})")
    ),
    file.path(path, "code", "00-config.R")
  )

  # Template Rmds
  rmd_templates <- list(
    "index" = "Home",
    "about" = "About",
    "license" = "License",
    "00-orchestrate" = "Pipeline Orchestration",
    "01-data" = "Data Import & Preprocessing",
    "02-descriptive" = "Descriptive Statistics",
    "03-lesion" = "Lesion Analysis",
    "04-canal" = "Spinal Canal Analysis",
    "05-longitudinal" = "Longitudinal Analysis",
    "06-sensitivity" = "Sensitivity Analyses",
    "07-prediction" = "Prediction Models",
    "08-manuscript-figures" = "Manuscript Figures",
    "09-report" = "Summary Report"
  )

  for (name in names(rmd_templates)) {
    rmd_title <- rmd_templates[[name]]
    rmd_content <- c(
      "---",
      glue::glue('title: "{rmd_title}"'),
      glue::glue('author: "{author}"'),
      glue::glue("date: \"`r Sys.Date()`\""),
      "output: workflowr::wflow_html",
      "---",
      "",
      "```{r setup, include=FALSE}",
      "knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)",
      'source(here::here("code", "00-config.R"))',
      "```",
      "",
      glue::glue("## {rmd_title}"),
      "",
      "<!-- Add analysis content here -->"
    )
    writeLines(rmd_content, file.path(path, "analysis", paste0(name, ".Rmd")))
  }

  # CSV templates (header-only)
  writeLines(
    "pat_id,session,study_date,modality,series_description,field_strength,trauma_date,days_post_trauma,phase,artifact_grade,notes",
    file.path(path, "data", "metadata", "imaging_registry.csv")
  )

  writeLines(
    "pat_id,age,sex,injury_level,ais_grade,trauma_date,op_date,notes",
    file.path(path, "data", "metadata", "clinical_data.csv")
  )

  writeLines(
    "pat_id,session,rater,date,seg_type,quality,notes",
    file.path(path, "data", "metadata", "qc_segmentation_log.csv")
  )

  # .gitignore
  writeLines(
    c(
      "# Data (large files)",
      "data/raw/",
      "data/nifti/",
      "data/segmentations/",
      "data/qc/",
      "*.nii",
      "*.nii.gz",
      "*.dcm",
      "",
      "# R artifacts",
      ".Rhistory",
      ".Rdata",
      ".RData",
      ".Ruserdata",
      ".DS_Store",
      "",
      "# Sensitive",
      "*mapping*.csv",
      "",
      "# Output (regenerated)",
      "docs/",
      "results/models/*.rds"
    ),
    file.path(path, ".gitignore")
  )

  cli::cli_alert_success("Templates created.")

  if (open && rlang::is_interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
    if (rstudioapi::isAvailable()) {
      rstudioapi::openProject(path, newSession = TRUE)
    }
  }

  cli::cli_alert_success("Project created at {.path {path}}")
  cli::cli_inform(c(
    "i" = "Next steps:",
    " " = "1. Place DICOM files in {.path data/raw/dicom/}",
    " " = "2. Fill in {.path data/metadata/imaging_registry.csv}",
    " " = "3. Fill in {.path data/metadata/clinical_data.csv}",
    " " = "4. Run {.fn sci_run_pipeline}"
  ))

  invisible(path)
}
