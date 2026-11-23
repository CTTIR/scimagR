#' Extract DICOM Header Metadata
#'
#' Walks a DICOM directory tree and extracts key header fields (StudyDate,
#' Modality, SeriesDescription, MagneticFieldStrength, etc.) from the first
#' DICOM file per session, using the bundled Python script and 'pydicom'.
#'
#' The `pat_id` and `session` columns are taken from the folder names
#' (`<dicom_dir>/<pat_id>/<session>/`), so that they match the paths that
#' [convert_batch()] builds from the registry. The `PatientID` header,
#' which may hold an identifying hospital number, is not exported.
#' `modality` holds the DICOM code (`"MR"`, `"CT"`); [create_registry()]
#' maps `"MR"` to the registry code `"MRT"`.
#'
#' @param dicom_dir Character. Root DICOM directory (expects
#'   `<pat_id>/<session>/` structure).
#' @param output_csv Character. Path for output CSV.
#' @param python Character. Python executable. Default uses `PYTHON_BIN`
#'   environment variable or `"python3"`.
#' @return Character. Path to output CSV (invisible). The CSV has one row
#'   per session with the columns `pat_id`, `session`, `dcm_path`,
#'   `study_date`, `modality`, `series_description`, `field_strength`,
#'   `manufacturer`, `scanner_model`, `slice_thickness`, `pixel_spacing`,
#'   `rows`, `columns` and `institution`.
#' @export
#' @examples
#' \donttest{
#' # Needs Python 3 with 'pydicom'. The bundled DICOM files are synthetic
#' # 8 x 8 pixel slices of one made-up patient with two sessions.
#' if (check_pydicom(verbose = FALSE)$available) {
#'   dicom_root <- system.file("extdata", "dicom", package = "scimagR")
#'   csv <- extract_dicom_metadata(dicom_root,
#'                                 file.path(tempdir(), "dicom_metadata.csv"))
#'   meta <- utils::read.csv(csv)
#'   meta[, c("pat_id", "session", "study_date", "modality")]
#' }
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
