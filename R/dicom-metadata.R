#' Extract DICOM Header Metadata
#'
#' Walks a DICOM directory tree and extracts key header fields (StudyDate,
#' Modality, SeriesDescription, FieldStrength, etc.) from the first DICOM
#' file per session.
#'
#' @param dicom_dir Character. Root DICOM directory (expects
#'   `<pat_id>/<session>/` structure).
#' @param output_csv Character. Path for output CSV.
#' @param python Character. Python executable. Default uses `PYTHON_BIN`
#'   environment variable or `"python3"`.
#' @return Character. Path to output CSV (invisible).
#' @export
#' @examples
#' \dontrun{
#' extract_dicom_metadata("data/raw/dicom", "data/metadata/dicom_metadata.csv")
#' }
extract_dicom_metadata <- function(dicom_dir,
                                   output_csv,
                                   python = Sys.getenv("PYTHON_BIN", "python3")) {
  rlang::check_required(dicom_dir)
  rlang::check_required(output_csv)

  if (!dir.exists(dicom_dir)) {
    cli::cli_abort("DICOM directory not found: {.path {dicom_dir}}")
  }

  pydicom_check <- check_pydicom(python = python, verbose = FALSE)
  if (!pydicom_check$available) {
    cli::cli_abort(c(
      "pydicom is required for DICOM metadata extraction.",
      "i" = "Install with: {.code pip install pydicom}"
    ))
  }

  script <- system.file("python", "extract_dicom_metadata.py", package = "scimagR")
  if (!nzchar(script)) {
    cli::cli_abort("Bundled Python script not found. Is scimagR installed correctly?")
  }

  output_dir <- dirname(output_csv)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  exit_code <- system2(
    command = python,
    args = c(shQuote(script), shQuote(dicom_dir), shQuote(output_csv)),
    stdout = "", stderr = ""
  )

  if (exit_code != 0L) {
    cli::cli_abort("DICOM metadata extraction failed with exit code {exit_code}.")
  }

  cli::cli_alert_success("DICOM metadata saved: {.path {output_csv}}")
  invisible(output_csv)
}
