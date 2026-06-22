# Tests for plotting helpers (viz-plots.R)

vb_df <- data.frame(
  phase = factor(rep(c("acute", "chronic"), each = 5)),
  mscc = c(10, 12, 15, 9, 11, 30, 28, 33, 31, 29)
)

test_that("plot_violin_box builds a layered ggplot", {
  p <- plot_violin_box(vb_df, x = "phase", y = "mscc")
  expect_s3_class(p, "ggplot")
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_true("GeomViolin" %in% geoms)
  expect_true("GeomBoxplot" %in% geoms)
  expect_true("GeomPoint" %in% geoms)
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("plot_violin_box applies title and ylab", {
  p <- plot_violin_box(vb_df, x = "phase", y = "mscc",
                       title = "My title", ylab = "MSCC (%)")
  expect_equal(p$labels$title, "My title")
  expect_equal(p$labels$y, "MSCC (%)")
})

sp_df <- data.frame(
  days = rep(c(5, 30, 90), 3),
  csa = c(60, 58, 55, 62, 60, 57, 59, 56, 54),
  pat_id = rep(c("A", "B", "C"), each = 3),
  phase = rep(c("acute", "subacute", "intermediate"), 3)
)

test_that("plot_spaghetti without smoother has no smooth layer", {
  p <- plot_spaghetti(sp_df, x = "days", y = "csa", group = "pat_id",
                      smoother = FALSE)
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_true("GeomLine" %in% geoms)
  expect_false("GeomSmooth" %in% geoms)
})

test_that("plot_spaghetti with smoother adds a smooth layer", {
  p <- plot_spaghetti(sp_df, x = "days", y = "csa", group = "pat_id",
                      smoother = TRUE)
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_true("GeomSmooth" %in% geoms)
})

test_that("plot_spaghetti accepts an optional colour aesthetic", {
  p <- plot_spaghetti(sp_df, x = "days", y = "csa", group = "pat_id",
                      colour = "phase", smoother = FALSE)
  expect_true("colour" %in% names(p$mapping))
})

est_df <- data.frame(
  model = c("Full", "S1", "S2"),
  estimate = c(-2.1, -1.9, -2.3),
  ci_lower = c(-3.5, -3.4, -3.8),
  ci_upper = c(-0.7, -0.4, -0.8)
)

test_that("plot_forest builds with errorbar, point and reference line", {
  p <- suppressWarnings(plot_forest(est_df))
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  # ggplot2 >= 4.0 maps geom_errorbarh() onto GeomErrorbar; accept either.
  expect_true(any(grepl("Errorbar", geoms)))
  expect_true("GeomVline" %in% geoms)
  expect_true("GeomPoint" %in% geoms)
  expect_s3_class(p, "ggplot")
  built <- suppressWarnings(ggplot2::ggplot_build(p))
  expect_s3_class(built, "ggplot_built")
})

test_that("plot_forest reverses the model factor ordering", {
  p <- suppressWarnings(plot_forest(est_df))
  expect_equal(levels(p$data$model), rev(c("Full", "S1", "S2")))
})

test_that("plot_forest errors when required columns are missing", {
  expect_error(plot_forest(data.frame(model = "A", estimate = 1)),
               "missing columns")
})

test_that("plot_forest honours xlab and vline", {
  p <- suppressWarnings(plot_forest(est_df, xlab = "Beta", vline = -1))
  expect_equal(p$labels$x, "Beta")
})
