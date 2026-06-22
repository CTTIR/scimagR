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
