#' Filter to Evaluable Imaging Sessions
#'
#' Filters a dataset to sessions that meet artifact grade and modality
#' criteria for analysis.
#'
#' @param df Data frame with `artifact_grade` and `modality` columns.
#' @param max_artifact Integer. Maximum artifact grade to include. Default `2`.
#' @param modalities Character vector. Modalities to include.
#'   Default `c("MRT", "CT+MRT")`.
#' @param verbose Logical. Print exclusion summary. Default `TRUE`.
#' @return Filtered data frame.
#' @export
#' @examples
#' \dontrun{
#' evaluable <- filter_evaluable(registry, max_artifact = 2)
#' }
filter_evaluable <- function(df,
                             max_artifact = 2,
                             modalities = c("MRT", "CT+MRT"),
                             verbose = TRUE) {
  rlang::check_required(df)
  df <- tibble::as_tibble(df)

  n_before <- nrow(df)

  if ("artifact_grade" %in% names(df)) {
    df <- dplyr::filter(
      df,
      is.na(.data$artifact_grade) | .data$artifact_grade <= max_artifact
    )
  }

  if ("modality" %in% names(df)) {
    df <- dplyr::filter(df, .data$modality %in% modalities)
  }

  n_after <- nrow(df)

  if (verbose) {
    cli::cli_inform(
      "Filtered: {n_before} -> {n_after} ({n_before - n_after} excluded)"
    )
  }

  df
}

#' Log an Exclusion Step
#'
#' Records before/after row counts and reason for an exclusion step.
#' Useful for building a CONSORT-style exclusion flow.
#'
#' @param step Character. Name of the exclusion step.
#' @param n_before Integer. Row count before filtering.
#' @param n_after Integer. Row count after filtering.
#' @param reason Character. Reason for exclusion.
#' @return A 1-row tibble with columns: `step`, `n_before`, `n_after`,
#'   `n_excluded`, `reason`.
#' @export
#' @examples
#' log_exclusion("Artifact filter", 100, 85, "artifact_grade > 2")
log_exclusion <- function(step, n_before, n_after, reason = "") {
  rlang::check_required(step)
  rlang::check_required(n_before)
  rlang::check_required(n_after)

  tibble::tibble(
    step = step,
    n_before = as.integer(n_before),
    n_after = as.integer(n_after),
    n_excluded = as.integer(n_before - n_after),
    reason = reason
  )
}
