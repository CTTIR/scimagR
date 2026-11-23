#' Plan the SCI Analysis Pipeline
#'
#' Checks a project created with [sci_create_project()] and returns the plan
#' of processing steps, each with the function that performs it:
#' 1. DICOM metadata extraction ([extract_dicom_metadata()])
#' 2. Anonymisation, if requested ([anonymize_dicom()])
#' 3. DICOM to NIfTI conversion ([convert_batch()])
#' 4. Spinal cord segmentation ([sct_segment_sc()])
#' 5. Lesion segmentation with SCIsegV2 ([sct_segment_lesion()])
#' 6. Vertebral labelling ([sct_label_vertebrae()])
#' 7. Parameter extraction ([sct_analyze_lesion()],
#'    [sct_process_segmentation()])
#' 8. Merge & export ([save_table()], [save_rds()])
#'
#' `sci_run_pipeline()` is a planner, not a runner. It does **not** call
#' the Spinal Cord Toolbox, 'dcm2niix' or 'pydicom', does not read or write
#' any image, and does not look at which outputs already exist: every
#' requested step is reported as `"pending"` (step 2 as `"skipped"` unless
#' `anonymize = TRUE`), whatever its state on disk. Run the function named
#' in each row to perform the step, and use [sci_pipeline_status()] to see
#' which outputs exist.
#'
#' @param project_dir Character. Path to workflowr project root.
#' @param steps Integer vector. Which steps (1--8) to include in the plan.
#'   Default `1:8`. Other values are skipped with a warning.
#' @param anonymize Logical. Include the anonymisation step (step 2).
#'   Default `FALSE`.
#' @param overwrite Logical. Kept for compatibility; not used, because no
#'   step is run. Default `FALSE`.
#' @param verbose Logical. Print the plan. Default `TRUE`.
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
      if (verbose) {
        cli::cli_inform("Step 2 (Anonymization): skipped (anonymize = FALSE)")
      }
      status_log <- dplyr::bind_rows(status_log, tibble::tibble(
        step = 2L, name = step_names[2], status = "skipped",
        message = "anonymize = FALSE"
      ))
      next
    }

    if (verbose) {
      cli::cli_h2("Step {s}: {step_names[s]}")
    }

    if (verbose) {
      cli::cli_alert_info("Run {.code {step_functions[s]}} for this step.")
    }
    step_status <- tibble::tibble(
      step = as.integer(s),
      name = step_names[s],
      status = "pending",
      message = paste("run", step_functions[s])
    )

    status_log <- dplyr::bind_rows(status_log, step_status)

    if (s == 5 && verbose) {
      cli::cli_alert_warning(
        "QC PAUSE: review the lesion segmentations before steps 6-8."
      )
      cli::cli_inform(
        "Check the QC reports ({.arg qc_dir} or {.fn sct_generate_qc})."
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
#' Scans `data/nifti/<pat_id>/<session>/` of the project and reports which
#' processing outputs exist for each patient and session. A step counts as
#' done when its file is present:
#' * `converted`: any `.nii` or `.nii.gz` file;
#' * `sc_seg`: a spinal cord mask, `*_seg.nii(.gz)` other than a lesion mask;
#' * `lesion_seg`: a lesion mask, `*_lesion_seg.nii(.gz)`;
#' * `vert_labels`: vertebral labels from [sct_label_vertebrae()],
#'   `*_labeled.nii(.gz)` or `*_labeled_discs.nii(.gz)` (the earlier
#'   naming `*_labels-disc.nii(.gz)` is also recognised);
#' * `qc_done`: a `qc/` folder in the session folder;
#' * `params_extracted`: a `.csv` file or an `*_analysis.xls(x)`
#'   spreadsheet from [sct_analyze_lesion()].
#'
#' @param project_dir Character. Path to workflowr project root.
#' @return Tibble with one row per session and the columns `pat_id`,
#'   `session`, `converted`, `sc_seg`, `lesion_seg`, `vert_labels`,
#'   `qc_done`, `params_extracted` (zero rows if no session folder exists).
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
    return(empty_pipeline_status())
  }

  patients <- list.dirs(nifti_root, recursive = FALSE, full.names = FALSE)

  results <- list()
  for (pid in patients) {
    sessions <- list.dirs(
      file.path(nifti_root, pid),
      recursive = FALSE, full.names = FALSE
    )

    for (ses in sessions) {
      ses_dir <- file.path(nifti_root, pid, ses)
      files <- list.files(ses_dir)
      nii_files <- grep("\\.nii(\\.gz)?$", files, value = TRUE)
      seg_files <- grep("_seg\\.nii(\\.gz)?$", nii_files, value = TRUE)

      results[[length(results) + 1L]] <- tibble::tibble(
        pat_id = pid,
        session = ses,
        converted = length(nii_files) > 0,
        sc_seg = any(!grepl("_lesion_seg\\.nii", seg_files)),
        lesion_seg = any(grepl("_lesion_seg\\.nii", seg_files)),
        vert_labels = any(grepl(
          "(_labeled|_labeled_discs|_labels-disc)\\.nii(\\.gz)?$", nii_files
        )),
        qc_done = dir.exists(file.path(ses_dir, "qc")),
        params_extracted = any(grepl("(\\.csv|_analysis\\.xlsx?)$", files))
      )
    }
  }

  if (length(results) == 0L) {
    return(empty_pipeline_status())
  }
  dplyr::bind_rows(results)
}

# Zero-row result of sci_pipeline_status() with the documented columns.
empty_pipeline_status <- function() {
  tibble::tibble(
    pat_id = character(),
    session = character(),
    converted = logical(),
    sc_seg = logical(),
    lesion_seg = logical(),
    vert_labels = logical(),
    qc_done = logical(),
    params_extracted = logical()
  )
}
