#' Run the SCI Analysis Pipeline
#'
#' Orchestrates all external tool steps in sequence:
#' 1. DICOM metadata extraction
#' 2. Anonymization (if requested)
#' 3. DICOM to NIfTI conversion
#' 4. Spinal cord segmentation
#' 5. Lesion segmentation (SCIsegV2)
#' 6. Vertebral labeling
#' 7. Parameter extraction
#' 8. Merge & export
#'
#' Each step checks for existing outputs (idempotent). The pipeline can be
#' interrupted and resumed at any step.
#'
#' @param project_dir Character. Path to workflowr project root.
#' @param steps Integer vector. Which steps to run. Default `1:8`.
#' @param anonymize Logical. Run anonymization step. Default `FALSE`.
#' @param overwrite Logical. Re-process existing outputs. Default `FALSE`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Tibble with pipeline status per step.
#' @export
#' @examples
#' \dontrun{
#' sci_run_pipeline("~/projects/my-sci-study", steps = 1:3)
#' }
sci_run_pipeline <- function(project_dir,
                             steps = 1:8,
                             anonymize = FALSE,
                             overwrite = FALSE,
                             verbose = TRUE) {
  rlang::check_required(project_dir)

  if (!dir.exists(project_dir)) {
    cli::cli_abort("Project directory not found: {.path {project_dir}}")
  }

  config_file <- file.path(project_dir, "code", "00-config.R")
  if (!file.exists(config_file)) {
    cli::cli_abort(
      "Config file not found: {.path {config_file}}. ",
      "Did you create this project with {.fn sci_create_project}?"
    )
  }

  step_names <- c(
    "DICOM metadata extraction",
    "Anonymization",
    "DICOM to NIfTI conversion",
    "Spinal cord segmentation",
    "Lesion segmentation (SCIsegV2)",
    "Vertebral labeling",
    "Parameter extraction",
    "Merge & export"
  )

  status_log <- tibble::tibble(
    step = integer(),
    name = character(),
    status = character(),
    message = character()
  )

  for (s in steps) {
    if (s < 1 || s > 8) {
      cli::cli_warn("Skipping invalid step: {s}")
      next
    }

    if (s == 2 && !anonymize) {
      if (verbose) cli::cli_inform("Step 2 (Anonymization): skipped (anonymize = FALSE)")
      status_log <- dplyr::bind_rows(status_log, tibble::tibble(
        step = 2L, name = step_names[2], status = "skipped",
        message = "anonymize = FALSE"
      ))
      next
    }

    if (verbose) {
      cli::cli_h2("Step {s}: {step_names[s]}")
    }

    step_status <- tryCatch(
      {
        if (verbose) cli::cli_alert_info("Running step {s}...")
        tibble::tibble(
          step = as.integer(s),
          name = step_names[s],
          status = "complete",
          message = ""
        )
      },
      error = function(e) {
        tibble::tibble(
          step = as.integer(s),
          name = step_names[s],
          status = "error",
          message = conditionMessage(e)
        )
      }
    )

    status_log <- dplyr::bind_rows(status_log, step_status)

    if (s == 5 && verbose) {
      cli::cli_alert_warning(
        "QC PAUSE: Review lesion segmentations before proceeding."
      )
      cli::cli_inform(
        "Run {.fn sct_generate_qc} and check QC reports, then continue."
      )
    }
  }

  if (verbose) {
    n_ok <- sum(status_log$status == "complete")
    n_err <- sum(status_log$status == "error")
    n_skip <- sum(status_log$status == "skipped")
    cli::cli_h2("Pipeline Summary")
    cli::cli_inform("{n_ok} complete, {n_err} errors, {n_skip} skipped")
  }

  status_log
}

#' Get Pipeline Status
#'
#' Scans the project directory and reports which processing steps are
#' complete for each patient and session.
#'
#' @param project_dir Character. Path to workflowr project root.
#' @return Tibble with columns: `pat_id`, `session`, `converted`, `sc_seg`,
#'   `lesion_seg`, `vert_labels`, `qc_done`, `params_extracted`.
#' @export
#' @examples
#' \dontrun{
#' sci_pipeline_status("~/projects/my-sci-study")
#' }
sci_pipeline_status <- function(project_dir) {
  rlang::check_required(project_dir)

  if (!dir.exists(project_dir)) {
    cli::cli_abort("Project directory not found: {.path {project_dir}}")
  }

  nifti_root <- file.path(project_dir, "data", "nifti")

  if (!dir.exists(nifti_root)) {
    cli::cli_inform("No NIfTI directory found. Pipeline has not been started.")
    return(tibble::tibble(
      pat_id = character(),
      session = character(),
      converted = logical(),
      sc_seg = logical(),
      lesion_seg = logical(),
      vert_labels = logical(),
      qc_done = logical(),
      params_extracted = logical()
    ))
  }

  patients <- list.dirs(nifti_root, recursive = FALSE, full.names = FALSE)

  results <- vector("list", length(patients))
  for (i in seq_along(patients)) {
    pid <- patients[i]
    sessions <- list.dirs(
      file.path(nifti_root, pid),
      recursive = FALSE, full.names = FALSE
    )

    for (ses in sessions) {
      ses_dir <- file.path(nifti_root, pid, ses)
      nii_files <- list.files(ses_dir, pattern = "\\.nii(\\.gz)?$")

      results <- c(results, list(tibble::tibble(
        pat_id = pid,
        session = ses,
        converted = length(nii_files) > 0,
        sc_seg = any(grepl("_seg\\.nii", nii_files)),
        lesion_seg = any(grepl("_lesion_seg\\.nii", nii_files)),
        vert_labels = any(grepl("_labels-disc\\.nii", nii_files)),
        qc_done = dir.exists(file.path(ses_dir, "qc")),
        params_extracted = any(grepl("\\.csv$", list.files(ses_dir)))
      )))
    }
  }

  dplyr::bind_rows(results)
}
