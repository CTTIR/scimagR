# Tests for save_* export helpers (export.R)

test_that("save_table writes an xlsx file and returns its path invisibly", {
  dir <- withr::local_tempdir()
  path <- expect_invisible(save_table(data.frame(a = 1:3, b = letters[1:3]),
                                      "tab.xlsx", dir))
  expect_true(file.exists(path))
  expect_equal(basename(path), "tab.xlsx")
})

test_that("save_table creates the output directory if absent", {
  dir <- withr::local_tempdir()
  nested <- file.path(dir, "deep", "nested")
  path <- save_table(data.frame(x = 1), "t.xlsx", nested)
  expect_true(dir.exists(nested))
  expect_true(file.exists(path))
})

test_that("save_rds round-trips an arbitrary object", {
  dir <- withr::local_tempdir()
  obj <- list(a = 1:5, b = "hello")
  path <- save_rds(obj, "obj.rds", dir)
  expect_true(file.exists(path))
  expect_equal(readRDS(path), obj)
})

test_that("save_rds creates the output directory if absent", {
  dir <- withr::local_tempdir()
  nested <- file.path(dir, "new")
  path <- save_rds(1:3, "o.rds", nested)
  expect_true(dir.exists(nested))
})

test_that("save_fig saves a ggplot at the requested filename", {
  dir <- withr::local_tempdir()
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
  path <- expect_invisible(
    suppressMessages(save_fig(p, "fig.png", dir, width = 4, height = 3, dpi = 72))
  )
  expect_true(file.exists(path))
  expect_equal(basename(path), "fig.png")
})

test_that("save_fig creates the output directory if absent", {
  dir <- withr::local_tempdir()
  nested <- file.path(dir, "figs")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
  path <- suppressMessages(save_fig(p, "f.png", nested, width = 3, height = 3, dpi = 72))
  expect_true(dir.exists(nested))
  expect_true(file.exists(path))
})
