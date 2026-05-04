#' Check Spinal Cord Toolbox Availability
#'
#' Verifies that SCT is installed and on PATH. Returns version and path
#' information.
#'
#' @param verbose Logical. Print status message. Default `TRUE`.
#' @return Named list with components:
#'   - `available`: Logical.
#'   - `version`: Character. Version string or `NA`.
#'   - `path`: Character. Path to `sct_version` executable or `NA`.
#' @export
#' @examples
#' \dontrun{
#' check_sct()
#' }
check_sct <- function(verbose = TRUE) {
  exe <- sct_find_executable("sct_version")
  available <- nzchar(exe)

  version <- NA_character_
  if (available) {
    res <- suppressWarnings(tryCatch(
      system2(exe, stdout = TRUE, stderr = TRUE),
      error = function(e) NA_character_
    ))
    if (!anyNA(res)) {
      version <- paste(res, collapse = " ")
    }
  }

  if (verbose) {
    if (available) {
      cli::cli_alert_success("SCT found: {version} at {.path {exe}}")
    } else {
      cli::cli_alert_danger(
        "SCT not found. Install from {.url https://spinalcordtoolbox.com}."
      )
    }
  }

  list(
    available = available,
    version = version,
    path = if (available) exe else NA_character_
  )
}

#' Check dcm2niix Availability
#'
#' Verifies that dcm2niix is installed and on PATH.
#'
#' @param verbose Logical. Print status message. Default `TRUE`.
#' @return Named list with components: `available`, `version`, `path`.
#' @export
#' @examples
#' \dontrun{
#' check_dcm2niix()
#' }
check_dcm2niix <- function(verbose = TRUE) {
  exe <- unname(Sys.which("dcm2niix"))
  available <- nzchar(exe)


  version <- NA_character_
  if (available) {
    res <- suppressWarnings(tryCatch(
      system2(exe, args = "-v", stdout = TRUE, stderr = TRUE),
      error = function(e) NA_character_
    ))
    if (!anyNA(res)) {
      version <- paste(res, collapse = " ")
    }
  }

  if (verbose) {
    if (available) {
      cli::cli_alert_success("dcm2niix found: {version} at {.path {exe}}")
    } else {
      cli::cli_alert_danger(
        "dcm2niix not found. Install from {.url https://github.com/rordenlab/dcm2niix}."
      )
    }
  }

  list(
    available = available,
    version = version,
    path = if (available) exe else NA_character_
  )
}

#' Check pydicom Availability
#'
#' Verifies that Python 3 with pydicom is available.
#'
#' @param python Character. Python executable. Default uses `PYTHON_BIN`
#'   environment variable or `"python3"`.
#' @param verbose Logical. Print status message. Default `TRUE`.
#' @return Named list with components: `available`, `version`, `path`.
#' @export
#' @examples
#' \dontrun{
#' check_pydicom()
#' }
check_pydicom <- function(python = Sys.getenv("PYTHON_BIN", "python3"),
                          verbose = TRUE) {
  exe <- unname(Sys.which(python))
  available <- nzchar(exe)

  version <- NA_character_
  if (available) {
    res <- suppressWarnings(tryCatch(
      system2(
        exe,
        args = c("-c", shQuote("import pydicom; print(pydicom.__version__)")),
        stdout = TRUE, stderr = TRUE
      ),
      error = function(e) NA_character_
    ))
    if (!anyNA(res) && length(res) > 0 && !grepl("Error|Traceback", res[1])) {
      version <- res[1]
    } else {
      available <- FALSE
    }
  }

  if (verbose) {
    if (available) {
      cli::cli_alert_success("pydicom found: v{version} via {.path {exe}}")
    } else {
      cli::cli_alert_danger(
        "pydicom not found. Install with: {.code pip install pydicom}"
      )
    }
  }

  list(
    available = available,
    version = version,
    path = if (available) exe else NA_character_
  )
}
