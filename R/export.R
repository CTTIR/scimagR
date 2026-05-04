#' Save Figure with Standard Conventions
#'
#' Saves a ggplot2 plot at publication-ready resolution with white background.
#'
#' @param plot A ggplot2 object.
#' @param filename Character. Output filename (e.g., `"fig1_mscc.png"`).
#' @param path Character. Output directory.
#' @param width Numeric. Figure width in inches. Default `7`.
#' @param height Numeric. Figure height in inches. Default `5`.
#' @param dpi Integer. Resolution. Default `600`.
#' @return Character. Full path to saved file (invisible).
#' @export
#' @examples
#' \dontrun{
#' p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
#' save_fig(p, "test_plot.png", tempdir())
#' }
save_fig <- function(plot, filename, path, width = 7, height = 5, dpi = 600) {
  rlang::check_required(plot)
  rlang::check_required(filename)
  rlang::check_required(path)

  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  full_path <- file.path(path, filename)

  ggplot2::ggsave(
    filename = full_path,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white"
  )

  cli::cli_alert_success("Figure saved: {.path {full_path}}")
  invisible(full_path)
}

#' Save Table as Excel
#'
#' Saves a data frame as .xlsx via writexl.
#'
#' @param df A data frame.
#' @param filename Character. Output filename (e.g., `"table1.xlsx"`).
#' @param path Character. Output directory.
#' @return Character. Full path to saved file (invisible).
#' @export
#' @examples
#' \dontrun{
#' save_table(mtcars, "cars.xlsx", tempdir())
#' }
save_table <- function(df, filename, path) {
  rlang::check_required(df)
  rlang::check_required(filename)
  rlang::check_required(path)

  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  full_path <- file.path(path, filename)
  writexl::write_xlsx(df, full_path)

  cli::cli_alert_success("Table saved: {.path {full_path}}")
  invisible(full_path)
}

#' Save R Object as RDS
#'
#' Saves any R object as .rds with a confirmation message.
#'
#' @param obj Any R object.
#' @param filename Character. Output filename (e.g., `"model_fit.rds"`).
#' @param path Character. Output directory.
#' @return Character. Full path to saved file (invisible).
#' @export
#' @examples
#' \dontrun{
#' save_rds(mtcars, "cars.rds", tempdir())
#' }
save_rds <- function(obj, filename, path) {
  rlang::check_required(filename)
  rlang::check_required(path)

  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  full_path <- file.path(path, filename)
  saveRDS(obj, full_path)

  cli::cli_alert_success("RDS saved: {.path {full_path}}")
  invisible(full_path)
}
