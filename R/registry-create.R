#' Create an Imaging Registry from DICOM Metadata
#'
#' Takes raw DICOM metadata (from [extract_dicom_metadata()]), restructures
#' it into a proper imaging registry with computed fields (days_post_trauma,
#' phase classification), and optionally saves to CSV.
#'
#' @param dicom_meta Data frame or character path to DICOM metadata CSV.
#' @param trauma_dates Named vector: names = pat_id, values = trauma date
#'   (Date or character coercible to Date).
#' @param op_dates Named vector: names = pat_id, values = OP date. Optional.
#' @param output_csv Character. Path to save registry. Optional.
#' @return Tibble with registry columns.
#' @export
#' @examples
#' \dontrun{
#' meta <- read.csv("dicom_metadata.csv")
#' trauma <- c(SCI001 = "2024-01-15", SCI002 = "2024-02-20")
#' reg <- create_registry(meta, trauma)
#' }
create_registry <- function(dicom_meta,
                            trauma_dates,
                            op_dates = NULL,
                            output_csv = NULL) {
  rlang::check_required(dicom_meta)
  rlang::check_required(trauma_dates)

  if (is.character(dicom_meta) && length(dicom_meta) == 1) {
    dicom_meta <- readr::read_csv(dicom_meta, show_col_types = FALSE)
  }
  dicom_meta <- tibble::as_tibble(dicom_meta)

  required_cols <- c("pat_id", "session", "study_date", "modality")
  missing_cols <- setdiff(required_cols, names(dicom_meta))
  if (length(missing_cols) > 0) {
    cli::cli_abort("DICOM metadata missing columns: {.field {missing_cols}}")
  }

  trauma_dates <- as.Date(trauma_dates)

  registry <- dicom_meta |>
    dplyr::mutate(
      study_date = as.Date(.data$study_date),
      trauma_date = trauma_dates[.data$pat_id],
      days_post_trauma = as.integer(
        difftime(.data$study_date, .data$trauma_date, units = "days")
      ),
      phase = classify_phase(.data$days_post_trauma)
    )

  if (!is.null(op_dates)) {
    op_dates <- as.Date(op_dates)
    registry <- registry |>
      dplyr::mutate(
        op_date = op_dates[.data$pat_id],
        days_post_op = as.integer(
          difftime(.data$study_date, .data$op_date, units = "days")
        )
      )
  }

  if (!is.null(output_csv)) {
    output_dir <- dirname(output_csv)
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }
    readr::write_csv(registry, output_csv)
    cli::cli_alert_success("Registry saved: {.path {output_csv}}")
  }

  registry
}

#' Validate an Imaging Registry
#'
#' Checks: required columns present, no duplicate pat_id x session,
#' dates are valid, days_post_trauma >= 0, artifact_grade in 0--4,
#' modality in allowed values.
#'
#' @param registry Data frame or character path to CSV.
#' @param strict Logical. Stop on errors (`TRUE`) or warn (`FALSE`).
#'   Default `TRUE`.
#' @return Invisibly returns the validated registry tibble.
#' @export
#' @examples
#' \dontrun{
#' validate_registry("data/metadata/imaging_registry.csv")
#' }
validate_registry <- function(registry, strict = TRUE) {
  if (is.character(registry) && length(registry) == 1) {
    registry <- readr::read_csv(registry, show_col_types = FALSE)
  }
  registry <- tibble::as_tibble(registry)

  issues <- character()

  required_cols <- c("pat_id", "session", "study_date", "modality")
  missing_cols <- setdiff(required_cols, names(registry))
  if (length(missing_cols) > 0) {
    issues <- c(issues, glue::glue("Missing required columns: {paste(missing_cols, collapse = ', ')}"))
  }

  if (all(c("pat_id", "session") %in% names(registry))) {
    dups <- registry |>
      dplyr::count(.data$pat_id, .data$session) |>
      dplyr::filter(.data$n > 1)
    if (nrow(dups) > 0) {
      dup_str <- paste(
        glue::glue("{dups$pat_id}/{dups$session}"),
        collapse = ", "
      )
      issues <- c(issues, glue::glue("Duplicate pat_id x session: {dup_str}"))
    }
  }

  if ("days_post_trauma" %in% names(registry)) {
    neg <- !is.na(registry$days_post_trauma) & registry$days_post_trauma < 0
    if (any(neg)) {
      issues <- c(issues, glue::glue("{sum(neg)} records have negative days_post_trauma"))
    }
  }

  if ("artifact_grade" %in% names(registry)) {
    invalid <- !is.na(registry$artifact_grade) &
      (registry$artifact_grade < 0 | registry$artifact_grade > 4)
    if (any(invalid)) {
      issues <- c(issues, glue::glue("{sum(invalid)} records have artifact_grade outside 0-4"))
    }
  }

  allowed_modalities <- c("CT", "MRT", "CT+MRT")
  if ("modality" %in% names(registry)) {
    bad_mod <- !is.na(registry$modality) &
      !registry$modality %in% allowed_modalities
    if (any(bad_mod)) {
      bad_vals <- unique(registry$modality[bad_mod])
      issues <- c(
        issues,
        glue::glue(
          "Invalid modality values: {paste(bad_vals, collapse = ', ')}. ",
          "Allowed: {paste(allowed_modalities, collapse = ', ')}"
        )
      )
    }
  }

  if (length(issues) > 0) {
    report_fn <- if (strict) cli::cli_abort else cli::cli_warn
    report_fn(c(
      "Registry validation failed:",
      stats::setNames(issues, rep("x", length(issues)))
    ))
  } else {
    cli::cli_alert_success("Registry validation passed.")
  }

  invisible(registry)
}
