#' Violin + Box Plot
#'
#' Creates a violin plot with embedded boxplot (no outlier points) and
#' jittered individual data points. Uses viridis palette by default.
#'
#' @param df Data frame.
#' @param x Character. Column name for x-axis (categorical).
#' @param y Character. Column name for y-axis (numeric).
#' @param fill Character. Column name for fill aesthetic. Default same as `x`.
#' @param title Character. Plot title. Default `NULL`.
#' @param ylab Character. Y-axis label. Default same as `y`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' \dontrun{
#' plot_violin_box(df, x = "phase", y = "mscc", fill = "phase")
#' }
plot_violin_box <- function(df, x, y, fill = x, title = NULL, ylab = y) {
  rlang::check_required(df)
  rlang::check_required(x)
  rlang::check_required(y)

  ggplot2::ggplot(df, ggplot2::aes(
    x = .data[[x]], y = .data[[y]], fill = .data[[fill]]
  )) +
    ggplot2::geom_violin(alpha = 0.6, colour = NA) +
    ggplot2::geom_boxplot(
      width = 0.15, fill = "white", alpha = 0.8,
      outlier.shape = NA
    ) +
    ggplot2::geom_jitter(width = 0.1, alpha = 0.4, size = 1.5) +
    ggplot2::scale_fill_viridis_d() +
    ggplot2::labs(title = title, y = ylab) +
    theme_sci() +
    ggplot2::theme(legend.position = "none")
}

#' Spaghetti Plot
#'
#' Shows individual patient trajectories over time with an optional
#' group-level smoother.
#'
#' @param df Data frame.
#' @param x Character. Column name for x-axis (numeric, e.g., days).
#' @param y Character. Column name for y-axis (numeric).
#' @param group Character. Column name for grouping (e.g., `"pat_id"`).
#' @param colour Character. Column name for colour aesthetic. Default `NULL`.
#' @param smoother Logical. Add group-level LOESS smoother. Default `TRUE`.
#' @param title Character. Plot title. Default `NULL`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' \dontrun{
#' plot_spaghetti(df, x = "days_post_trauma", y = "csa",
#'                group = "pat_id", colour = "phase")
#' }
plot_spaghetti <- function(df, x, y, group, colour = NULL,
                           smoother = TRUE, title = NULL) {
  rlang::check_required(df)
  rlang::check_required(x)
  rlang::check_required(y)
  rlang::check_required(group)

  aes_args <- list(
    x = rlang::sym(x),
    y = rlang::sym(y),
    group = rlang::sym(group)
  )
  if (!is.null(colour)) {
    aes_args$colour <- rlang::sym(colour)
  }

  p <- ggplot2::ggplot(df, do.call(ggplot2::aes, aes_args)) +
    ggplot2::geom_line(alpha = 0.4) +
    ggplot2::geom_point(alpha = 0.6, size = 2) +
    ggplot2::labs(title = title) +
    theme_sci()

  if (smoother) {
    p <- p + ggplot2::geom_smooth(
      ggplot2::aes(group = NULL),
      method = "loess", formula = y ~ x,
      se = TRUE, alpha = 0.2, linewidth = 1.2
    )
  }

  p
}

#' Forest Plot
#'
#' Creates a forest plot for comparing model estimates with confidence
#' intervals. Useful for sensitivity analysis comparisons.
#'
#' @param estimates_df Data frame with columns: `model`, `estimate`,
#'   `ci_lower`, `ci_upper`.
#' @param xlab Character. X-axis label. Default `"Estimate"`.
#' @param title Character. Plot title. Default `NULL`.
#' @param vline Numeric. Position of reference line. Default `0`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' \dontrun{
#' est <- data.frame(
#'   model = c("Full", "Sensitivity 1", "Sensitivity 2"),
#'   estimate = c(-2.1, -1.9, -2.3),
#'   ci_lower = c(-3.5, -3.4, -3.8),
#'   ci_upper = c(-0.7, -0.4, -0.8)
#' )
#' plot_forest(est)
#' }
plot_forest <- function(estimates_df, xlab = "Estimate", title = NULL,
                        vline = 0) {
  rlang::check_required(estimates_df)

  required_cols <- c("model", "estimate", "ci_lower", "ci_upper")
  missing_cols <- setdiff(required_cols, names(estimates_df))
  if (length(missing_cols) > 0) {
    cli::cli_abort("estimates_df missing columns: {.field {missing_cols}}")
  }

  estimates_df$model <- factor(
    estimates_df$model,
    levels = rev(estimates_df$model)
  )

  ggplot2::ggplot(estimates_df, ggplot2::aes(
    x = .data$estimate, y = .data$model,
    xmin = .data$ci_lower, xmax = .data$ci_upper
  )) +
    ggplot2::geom_vline(
      xintercept = vline, linetype = "dashed", colour = "grey50"
    ) +
    ggplot2::geom_errorbarh(height = 0.2) +
    ggplot2::geom_point(size = 3) +
    ggplot2::labs(x = xlab, y = NULL, title = title) +
    theme_sci()
}
