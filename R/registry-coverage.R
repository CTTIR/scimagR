#' Create a Modality Coverage Matrix
#'
#' Shows which patients have which modalities at which timepoints.
#'
#' @param registry Data frame. Validated registry with `pat_id`, `session`,
#'   `modality`, and optionally `artifact_grade` columns.
#' @return Tibble in wide format with one row per patient and one column
#'   per session containing the modality.
#' @export
#' @examples
#' \dontrun{
#' reg <- validate_registry("imaging_registry.csv", strict = FALSE)
#' cm <- coverage_matrix(reg)
#' }
coverage_matrix <- function(registry) {
  rlang::check_required(registry)
  registry <- tibble::as_tibble(registry)

  required_cols <- c("pat_id", "session", "modality")
  missing_cols <- setdiff(required_cols, names(registry))
  if (length(missing_cols) > 0) {
    cli::cli_abort("Registry missing columns: {.field {missing_cols}}")
  }

  registry |>
    dplyr::select(dplyr::all_of(c("pat_id", "session", "modality"))) |>
    tidyr::pivot_wider(
      names_from = "session",
      values_from = "modality",
      values_fill = NA_character_
    )
}

#' Plot Modality Coverage Matrix
#'
#' Creates a tile plot showing modality coverage per patient and session,
#' with optional artifact grade overlay.
#'
#' @param registry Data frame. Validated registry.
#' @return A ggplot2 object.
#' @export
#' @examples
#' \dontrun{
#' plot_coverage(registry)
#' }
plot_coverage <- function(registry) {
  rlang::check_required(registry)
  registry <- tibble::as_tibble(registry)

  required_cols <- c("pat_id", "session", "modality")
  missing_cols <- setdiff(required_cols, names(registry))
  if (length(missing_cols) > 0) {
    cli::cli_abort("Registry missing columns: {.field {missing_cols}}")
  }

  p <- ggplot2::ggplot(
    registry,
    ggplot2::aes(x = .data$session, y = .data$pat_id, fill = .data$modality)
  ) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.5) +
    scale_fill_modality() +
    ggplot2::labs(x = "Session", y = "Patient", fill = "Modality") +
    theme_sci()

  if ("artifact_grade" %in% names(registry)) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = .data$artifact_grade),
      size = 3, colour = "grey20"
    )
  }

  p
}
