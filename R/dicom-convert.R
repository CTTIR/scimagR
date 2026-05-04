#' Convert DICOM to NIfTI
#'
#' Converts a single session's DICOM files to NIfTI format using dcm2niix.
#'
#' @param dicom_dir Character. Path to session DICOM directory.
#' @param output_dir Character. Path for NIfTI output.
#' @param compress Logical. Gzip output. Default `TRUE`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Character vector of output NIfTI paths.
#' @export
#' @examples
#' \dontrun{
#' convert_dcm2niix("data/raw/dicom/SCI001/ses-01", "data/nifti/SCI001/ses-01")
#' }
convert_dcm2niix <- function(dicom_dir,
                             output_dir,
                             compress = TRUE,
                             verbose = TRUE) {
  rlang::check_required(dicom_dir)
  rlang::check_required(output_dir)

  if (!dir.exists(dicom_dir)) {
    cli::cli_abort("DICOM directory not found: {.path {dicom_dir}}")
  }

  dcm2niix_check <- check_dcm2niix(verbose = FALSE)
  if (!dcm2niix_check$available) {
    cli::cli_abort(c(
      "dcm2niix is required for DICOM conversion.",
      "i" = "Install from {.url https://github.com/rordenlab/dcm2niix}"
    ))
  }

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  compress_flag <- if (compress) "y" else "n"
  args <- c("-z", compress_flag, "-o", shQuote(output_dir), shQuote(dicom_dir))

  if (verbose) cli::cli_inform("Converting: {.path {dicom_dir}}")

  exit_code <- system2("dcm2niix", args = args, stdout = TRUE, stderr = TRUE)

  ext <- if (compress) "\\.nii\\.gz$" else "\\.nii$"
  outputs <- list.files(output_dir, pattern = ext, full.names = TRUE)

  if (verbose) {
    cli::cli_alert_success(
      "Converted {length(outputs)} file{?s} to {.path {output_dir}}"
    )
  }

  outputs
}

#' Batch Convert DICOM to NIfTI
#'
#' Iterates over a registry and converts all sessions from DICOM to NIfTI.
#'
#' @param registry Data frame with `pat_id` and `session` columns.
#' @param dicom_root Character. Root DICOM directory.
#' @param nifti_root Character. Root NIfTI output directory.
#' @param compress Logical. Gzip output. Default `TRUE`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Tibble with columns: `pat_id`, `session`, `status`, `n_files`.
#' @export
#' @examples
#' \dontrun{
#' convert_batch(registry, "data/raw/dicom", "data/nifti")
#' }
convert_batch <- function(registry,
                          dicom_root,
                          nifti_root,
                          compress = TRUE,
                          verbose = TRUE) {
  rlang::check_required(registry)
  rlang::check_required(dicom_root)
  rlang::check_required(nifti_root)

  required_cols <- c("pat_id", "session")
  missing_cols <- setdiff(required_cols, names(registry))
  if (length(missing_cols) > 0) {
    cli::cli_abort("Registry missing columns: {.field {missing_cols}}")
  }

  results <- vector("list", nrow(registry))

  for (i in seq_len(nrow(registry))) {
    pid <- registry$pat_id[i]
    ses <- registry$session[i]

    dicom_dir <- file.path(dicom_root, pid, ses)
    nifti_dir <- file.path(nifti_root, pid, ses)

    status <- "success"
    n_files <- 0L

    tryCatch(
      {
        outputs <- convert_dcm2niix(
          dicom_dir, nifti_dir,
          compress = compress, verbose = verbose
        )
        n_files <- length(outputs)
      },
      error = function(e) {
        status <<- "error"
        if (verbose) {
          cli::cli_warn("Conversion failed for {pid}/{ses}: {conditionMessage(e)}")
        }
      }
    )

    results[[i]] <- tibble::tibble(
      pat_id = pid,
      session = ses,
      status = status,
      n_files = n_files
    )
  }

  result_df <- dplyr::bind_rows(results)

  if (verbose) {
    n_ok <- sum(result_df$status == "success")
    n_err <- sum(result_df$status == "error")
    cli::cli_inform("Batch conversion: {n_ok} succeeded, {n_err} failed.")
  }

  result_df
}
