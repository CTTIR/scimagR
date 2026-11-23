# Tests for colour / fill scale wrappers (viz-scales.R)

test_that("phase scales return ggplot2 scale objects", {
  sc <- scale_colour_phase()
  sf <- scale_fill_phase()
  expect_s3_class(sc, "Scale")
  expect_s3_class(sf, "Scale")
  expect_identical(sc$aesthetics, "colour")
  expect_identical(sf$aesthetics, "fill")
})

test_that("artifact scales return ggplot2 scale objects", {
  expect_s3_class(scale_colour_artifact(), "Scale")
  expect_s3_class(scale_fill_artifact(), "Scale")
})

test_that("modality scales return ggplot2 scale objects", {
  expect_s3_class(scale_colour_modality(), "Scale")
  expect_s3_class(scale_fill_modality(), "Scale")
})

test_that("phase scale uses the pal_phase palette values", {
  sf <- scale_fill_phase()
  expect_equal(unname(sf$palette(0)[1:5]), unname(pal_phase))
})

test_that("extra arguments pass through to the manual scale", {
  sf <- scale_fill_phase(name = "Injury phase", na.value = "grey")
  expect_equal(sf$name, "Injury phase")
  expect_equal(sf$na.value, "grey")
})

test_that("legends follow the palette order, not the alphabet", {
  df <- data.frame(grade = c("severe", "mild", "none"), n = 1:3)
  p <- ggplot2::ggplot(df, ggplot2::aes(grade, n, fill = grade)) +
    ggplot2::geom_col() +
    scale_fill_artifact()
  b <- ggplot2::ggplot_build(p)
  expect_equal(as.character(b$plot$scales$get_scales("fill")$get_breaks()),
               c("none", "mild", "severe"))
  expect_equal(scale_colour_phase()$breaks, names(pal_phase))
  expect_equal(scale_fill_modality()$breaks, names(pal_modality))
})

test_that("a caller-supplied breaks argument still works", {
  sf <- scale_fill_phase(breaks = c("chronic", "acute"))
  expect_equal(sf$breaks, c("chronic", "acute"))
})
