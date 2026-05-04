# Tests for SCT check functions (mock-based)

test_that("check_sct returns correct structure when SCT is missing", {
  withr::local_envvar(SCT_DIR = "", PATH = "")
  result <- check_sct(verbose = FALSE)
  expect_type(result, "list")
  expect_named(result, c("available", "version", "path"))
  expect_type(result$available, "logical")
})

test_that("check_dcm2niix returns correct structure", {
  result <- check_dcm2niix(verbose = FALSE)
  expect_type(result, "list")
  expect_named(result, c("available", "version", "path"))
  expect_type(result$available, "logical")
})

test_that("check_pydicom returns correct structure", {
  result <- check_pydicom(verbose = FALSE)
  expect_type(result, "list")
  expect_named(result, c("available", "version", "path"))
  expect_type(result$available, "logical")
})
