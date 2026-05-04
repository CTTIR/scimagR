#' Anonymize DICOM Files
#'
#' Replaces identifying header fields (PatientName, PatientID,
#' PatientBirthDate, etc.) and removes private tags. Saves an ID mapping
#' CSV to a user-specified secure location.
#'
#' @param dicom_dir Character. Root DICOM directory.
#' @param mapping_csv Character. Path for ID mapping output. **Store securely!**
#' @param prefix Character. Anonymized ID prefix. Default `"SCI"`.
#' @param python Character. Python executable. Default `"python3"`.
#' @return Exit code (invisible).
#' @export
#'
#' @details
#' **WARNING:** This modifies DICOM files in-place. Create a backup first.
#' The mapping CSV must NOT be stored in the project directory.
#'
#' @examples
#' \dontrun{
#' anonymize_dicom("data/raw/dicom", "/secure/id_mapping.csv")
#' }
anonymize_dicom <- function(dicom_dir,
                            mapping_csv,
                            prefix = "SCI",
                            python = Sys.getenv("PYTHON_BIN", "python3")) {
  rlang::check_required(dicom_dir)
  rlang::check_required(mapping_csv)

  if (!dir.exists(dicom_dir)) {
    cli::cli_abort("DICOM directory not found: {.path {dicom_dir}}")
  }

  pydicom_check <- check_pydicom(python = python, verbose = FALSE)
  if (!pydicom_check$available) {
    cli::cli_abort(c(
      "pydicom is required for DICOM anonymization.",
      "i" = "Install with: {.code pip install pydicom}"
    ))
  }

  script <- system.file("python", "anonymize_dicom.py", package = "scimagR")
  if (!nzchar(script)) {
    cli::cli_abort("Bundled Python script not found. Is scimagR installed correctly?")
  }

  mapping_dir <- dirname(mapping_csv)
  if (!dir.exists(mapping_dir)) {
    dir.create(mapping_dir, recursive = TRUE)
  }

  cli::cli_alert_warning("This will modify DICOM files in-place. Ensure you have a backup!")

  exit_code <- system2(
    command = python,
    args = c(
      shQuote(script),
      shQuote(dicom_dir),
      shQuote(mapping_csv),
      shQuote(prefix)
    ),
    stdout = "", stderr = ""
  )

  if (exit_code != 0L) {
    cli::cli_abort("DICOM anonymization failed with exit code {exit_code}.")
  }

  cli::cli_alert_success("DICOM anonymization complete. Mapping: {.path {mapping_csv}}")
  invisible(exit_code)
}
