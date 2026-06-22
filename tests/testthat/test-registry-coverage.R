# Tests for coverage matrix plotting (registry-coverage.R)
# coverage_matrix() itself is covered in test-registry.R; here we cover
# plot_coverage() and the error branch of coverage_matrix().

reg <- tibble::tibble(
  pat_id = c("A", "A", "B", "B"),
  session = c("s1", "s2", "s1", "s2"),
  modality = c("MRT", "CT", "MRT", "CT+MRT"),
  artifact_grade = c(0, 1, 2, 0)
)

test_that("coverage_matrix errors when required columns are missing", {
  expect_error(coverage_matrix(data.frame(pat_id = "A")), "missing columns")
})

test_that("plot_coverage builds a tile plot", {
  p <- plot_coverage(reg)
  expect_s3_class(p, "ggplot")
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_true("GeomTile" %in% geoms)
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("plot_coverage overlays artifact grade text when present", {
  p <- plot_coverage(reg)
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_true("GeomText" %in% geoms)
})

test_that("plot_coverage omits the text layer when artifact_grade is absent", {
  p <- plot_coverage(reg[, c("pat_id", "session", "modality")])
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_false("GeomText" %in% geoms)
})

test_that("plot_coverage errors when required columns are missing", {
  expect_error(plot_coverage(data.frame(pat_id = "A")), "missing columns")
})
