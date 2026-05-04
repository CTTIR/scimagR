#' Create a QC Segmentation Log
#'
#' Creates an empty QC log tibble or reads an existing one from CSV.
#'
#' @param path Character. Optional path to existing QC log CSV.
#' @return Tibble with QC log columns: `pat_id`, `session`, `rater`,
#'   `date`, `seg_type`, `quality`, `notes`.
#' @export
#' @examples
#' qc <- create_qc_log()
create_qc_log <- function(path = NULL) {
  if (!is.null(path) && file.exists(path)) {
    return(readr::read_csv(path, show_col_types = FALSE))
  }

  tibble::tibble(
    pat_id = character(),
    session = character(),
    rater = character(),
    date = as.Date(character()),
    seg_type = character(),
    quality = character(),
    notes = character()
  )
}

#' Update a QC Log
#'
#' Adds one or more QC entries to a QC log.
#'
#' @param qc_log Tibble. Existing QC log (from [create_qc_log()]).
#' @param entries Data frame. New entries with the same columns as `qc_log`.
#' @param output_csv Character. Optional path to save updated log.
#' @return Updated QC log tibble.
#' @export
#' @examples
#' \dontrun{
#' qc <- create_qc_log()
#' entry <- tibble::tibble(
#'   pat_id = "SCI001", session = "ses-01", rater = "RH",
#'   date = Sys.Date(), seg_type = "sc", quality = "good", notes = ""
#' )
#' qc <- update_qc_log(qc, entry)
#' }
update_qc_log <- function(qc_log, entries, output_csv = NULL) {
  rlang::check_required(qc_log)
  rlang::check_required(entries)

  updated <- dplyr::bind_rows(qc_log, entries)

  if (!is.null(output_csv)) {
    readr::write_csv(updated, output_csv)
    cli::cli_alert_success("QC log updated: {.path {output_csv}}")
  }

  updated
}

#' Validate a QC Log
#'
#' Checks required columns and valid quality values.
#'
#' @param qc_log Data frame or path to CSV.
#' @return Invisibly returns the validated QC log.
#' @export
validate_qc_log <- function(qc_log) {
  if (is.character(qc_log) && length(qc_log) == 1) {
    qc_log <- readr::read_csv(qc_log, show_col_types = FALSE)
  }
  qc_log <- tibble::as_tibble(qc_log)

  required_cols <- c("pat_id", "session", "seg_type", "quality")
  missing_cols <- setdiff(required_cols, names(qc_log))
  if (length(missing_cols) > 0) {
    cli::cli_abort("QC log missing columns: {.field {missing_cols}}")
  }

  valid_quality <- c("good", "acceptable", "poor", "failed")
  if ("quality" %in% names(qc_log)) {
    bad <- !is.na(qc_log$quality) & !qc_log$quality %in% valid_quality
    if (any(bad)) {
      cli::cli_warn(
        "Invalid quality values: {unique(qc_log$quality[bad])}. ",
        "Expected: {paste(valid_quality, collapse = ', ')}"
      )
    }
  }

  cli::cli_alert_success("QC log validation passed.")
  invisible(qc_log)
}
