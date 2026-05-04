#' Print Data Integrity Summary
#'
#' Reports dimensions, missing values per column, and duplicate count for
#' a data frame. Returns the data frame invisibly for piping.
#'
#' @param df Data frame to summarize.
#' @param id_cols Character vector. Columns to check for duplicates.
#'   Default `NULL` (skip duplicate check).
#' @return Invisibly returns `df`.
#' @export
#' @examples
#' \dontrun{
#' registry |> integrity_summary(id_cols = c("pat_id", "session"))
#' }
integrity_summary <- function(df, id_cols = NULL) {
  rlang::check_required(df)
  df <- tibble::as_tibble(df)

  cli::cli_h2("Data Integrity Summary")
  cli::cli_inform("Dimensions: {nrow(df)} rows x {ncol(df)} columns")

  na_counts <- vapply(df, function(x) sum(is.na(x)), integer(1))
  has_na <- na_counts[na_counts > 0]

  if (length(has_na) > 0) {
    cli::cli_h3("Missing Values")
    for (col_name in names(has_na)) {
      pct <- round(has_na[[col_name]] / nrow(df) * 100, 1)
      cli::cli_inform("  {col_name}: {has_na[[col_name]]} ({pct}%)")
    }
  } else {
    cli::cli_alert_success("No missing values.")
  }

  if (!is.null(id_cols)) {
    missing_id_cols <- setdiff(id_cols, names(df))
    if (length(missing_id_cols) > 0) {
      cli::cli_warn("ID columns not found: {.field {missing_id_cols}}")
    } else {
      dups <- df |>
        dplyr::count(dplyr::across(dplyr::all_of(id_cols))) |>
        dplyr::filter(.data$n > 1)
      if (nrow(dups) > 0) {
        cli::cli_alert_warning("{nrow(dups)} duplicate combination{?s} found.")
      } else {
        cli::cli_alert_success("No duplicates on {paste(id_cols, collapse = ' x ')}.")
      }
    }
  }

  invisible(df)
}
