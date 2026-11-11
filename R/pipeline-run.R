#' Run the SCI Analysis Pipeline
#'
#' Checks a project created with [sci_create_project()] and returns the plan
#' of processing steps, each with the function that performs it:
#' 1. DICOM metadata extraction ([extract_dicom_metadata()])
#' 2. Anonymization, if requested ([anonymize_dicom()])
#' 3. DICOM to NIfTI conversion ([convert_batch()])
#' 4. Spinal cord segmentation ([sct_segment_sc()])
#' 5. Lesion segmentation with SCIsegV2 ([sct_segment_lesion()])
#' 6. Vertebral labeling ([sct_label_vertebrae()])
#' 7. Parameter extraction ([sct_analyze_lesion()],
#'    [sct_process_segmentation()])
#' 8. Merge & export ([save_table()], [save_rds()])
#'
#' `sci_run_pipeline()` does not run the external tools itself: every
#' requested step is reported as `"pending"` until you run its function.
#' Use [sci_pipeline_status()] to see which outputs already exist.
#'
#' @param project_dir Character. Path to workflowr project root.
#' @param steps Integer vector. Which steps to run. Default `1:8`.
#' @param anonymize Logical. Run anonymization step. Default `FALSE`.
#' @param overwrite Logical. Kept for compatibility; not used while the
#'   runner only plans steps. Default `FALSE`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Tibble with one row per requested step: `step`, `name`,
#'   `status` (`"pending"` or `"skipped"`) and `message` (the function to
#'   run, or the reason for skipping).
#' @export
#' @examples
#' proj <- file.path(tempdir(), "pipeline-study")
#' sci_create_project(proj, open = FALSE)
#' sci_run_pipeline(proj, steps = 1:3)
#' unlink(proj, recursive = TRUE)
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

  step_functions <- c(
    "extract_dicom_metadata()",
    "anonymize_dicom()",
    "convert_batch()",
    "sct_segment_sc()",
    "sct_segment_lesion()",
    "sct_label_vertebrae()",
    "sct_analyze_lesion() and sct_process_segmentation()",
    "save_table() and save_rds()"
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

    if (verbose) cli::cli_alert_info("Run {.code {step_functions[s]}} for this step.")
    step_status <- tibble::tibble(
      step = as.integer(s),
      name = step_names[s],
      status = "pending",
      message = paste("run", step_functions[s])
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
    n_pending <- sum(status_log$status == "pending")
    n_skip <- sum(status_log$status == "skipped")
    cli::cli_h2("Pipeline Summary")
    cli::cli_inform("{n_pending} pending, {n_skip} skipped")
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
#' proj <- file.path(tempdir(), "status-study")
#' sci_create_project(proj, open = FALSE)
#' sci_pipeline_status(proj)
#' unlink(proj, recursive = TRUE)
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
