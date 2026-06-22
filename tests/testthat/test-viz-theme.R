# Tests for theme + palettes (viz-theme.R)

test_that("theme_sci returns a ggplot2 theme", {
  th <- theme_sci()
  expect_s3_class(th, "theme")
  expect_equal(th$legend.position, "bottom")
  expect_s3_class(th$panel.grid.minor, "element_blank")
})

test_that("theme_sci honours base_size and base_family", {
  th <- theme_sci(base_size = 16, base_family = "serif")
  expect_s3_class(th, "theme")
  # Title size is base_size + 2.
  expect_equal(th$plot.title$size, 18)
})

test_that("theme_sci composes onto a plot without error", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    ggplot2::geom_point() + theme_sci()
  expect_s3_class(p, "ggplot")
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("pal_phase has 5 named viridis colours", {
  expect_length(pal_phase, 5)
  expect_named(
    pal_phase,
    c("hyperacute", "acute", "subacute", "intermediate", "chronic")
  )
  expect_true(all(grepl("^#", pal_phase)))
})

test_that("pal_artifact maps grades to hex colours", {
  expect_length(pal_artifact, 5)
  expect_named(
    pal_artifact,
    c("none", "mild", "moderate", "severe", "non-evaluable")
  )
  expect_equal(unname(pal_artifact[["none"]]), "#4CAF50")
})

test_that("pal_modality has 3 named colours", {
  expect_length(pal_modality, 3)
  expect_named(pal_modality, c("CT", "MRT", "CT+MRT"))
})
