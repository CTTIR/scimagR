#' Anonymise DICOM Files
#'
#' Replaces identifying header fields and removes private tags in every file
#' below `dicom_dir`, using the bundled Python script and 'pydicom'. Each
#' patient folder (`<dicom_dir>/<folder>/`) gets a new ID `<prefix>001`,
#' `<prefix>002`, ... in alphabetical folder order; the mapping from folder
#' name to new ID is saved to `mapping_csv`.
#'
#' @param dicom_dir Character. Root DICOM directory.
#' @param mapping_csv Character. Path for ID mapping output. **Store securely!**
#' @param prefix Character. Anonymised ID prefix. Default `"SCI"`.
#' @param python Character. Python executable. Default uses `PYTHON_BIN`
#'   environment variable or `"python3"`.
#' @return Exit code (invisible).
#' @export
#'
#' @details
#' **WARNING:** This modifies DICOM files in-place. Create a backup first.
#' The mapping CSV must NOT be stored in the project directory.
#'
#' What is changed: `PatientID` is set to the new ID; `PatientName`,
#' `PatientBirthDate`, `PatientAddress`, `PatientTelephoneNumbers`,
#' `ReferringPhysicianName`, `InstitutionName`, `InstitutionAddress`,
#' `InstitutionalDepartmentName`, `PhysiciansOfRecord`,
#' `PerformingPhysicianName` and `OperatorsName` are emptied, and all
#' private tags are removed. Everything else is kept, including dates,
#' `PatientSex`, `PatientAge`, `AccessionNumber`, UIDs and burned-in
#' annotations in the pixel data. The folder names are not changed either,
#' so rename folders that carry names or hospital numbers yourself. This is
#' a minimal de-identification, not the DICOM PS3.15 Basic Application
#' Level Confidentiality Profile; check it against your data protection
#' requirements before sharing data.
#'
#' @examples
#' \donttest{
#' # Needs Python 3 with 'pydicom'. Works on a copy of the bundled
#' # synthetic DICOM files, because the files are changed in place.
#' if (check_pydicom(verbose = FALSE)$available) {
#'   work <- file.path(tempdir(), "anon-example")
#'   dir.create(work, showWarnings = FALSE)
#'   file.copy(system.file("extdata", "dicom", package = "scimagR"), work,
#'             recursive = TRUE)
#'   mapping <- file.path(tempdir(), "secure", "id_mapping.csv")
#'   anonymize_dicom(file.path(work, "dicom"), mapping)
#'   utils::read.csv(mapping)
#'   unlink(c(work, dirname(mapping)), recursive = TRUE)
#' }
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
      "pydicom is required for DICOM anonymisation.",
      "i" = "Install with: {.code pip install pydicom}"
    ))
  }

  script <- system.file("python", "anonymize_dicom.py", package = "scimagR")
  if (!nzchar(script)) {
    cli::cli_abort(
      "Bundled Python script not found. Is scimagR installed correctly?"
    )
  }

  mapping_dir <- dirname(mapping_csv)
  if (!dir.exists(mapping_dir)) {
    dir.create(mapping_dir, recursive = TRUE)
  }

  cli::cli_alert_warning(
    "This will modify DICOM files in-place. Ensure you have a backup!"
  )

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
    cli::cli_abort("DICOM anonymisation failed with exit code {exit_code}.")
  }

  cli::cli_alert_success(
    "DICOM anonymisation complete. Mapping: {.path {mapping_csv}}"
  )
  invisible(exit_code)
}
