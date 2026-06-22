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

# --- verbose + available-branch coverage ---

test_that("check_sct reports success when a version is resolvable", {
  fake_exe <- normalizePath(Sys.which("Rscript")[[1]], winslash = "/",
                            mustWork = FALSE)
  skip_if(!nzchar(fake_exe), "Rscript not resolvable")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  res <- check_sct(verbose = FALSE)
  expect_true(res$available)
  expect_false(is.na(res$version))
  expect_equal(res$path, fake_exe)
})

test_that("check_sct prints a danger message when SCT is missing", {
  local_mocked_bindings(sct_find_executable = function(cmd) "")
  expect_message(check_sct(verbose = TRUE), "not found")
})

test_that("check_sct prints success message when verbose and available", {
  fake_exe <- normalizePath(Sys.which("Rscript")[[1]], winslash = "/",
                            mustWork = FALSE)
  skip_if(!nzchar(fake_exe), "Rscript not resolvable")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  expect_message(check_sct(verbose = TRUE), "SCT found")
})

test_that("check_dcm2niix prints a danger message when missing", {
  testthat::local_mocked_bindings(
    Sys.which = function(...) c(dcm2niix = ""), .package = "base"
  )
  expect_message(check_dcm2niix(verbose = TRUE), "not found")
})

test_that("check_pydicom prints a danger message when missing", {
  testthat::local_mocked_bindings(
    Sys.which = function(...) "", .package = "base"
  )
  expect_message(check_pydicom(verbose = TRUE), "not found")
})

test_that("check_pydicom reports success when pydicom version is returned", {
  fake_exe <- normalizePath(Sys.which("Rscript")[[1]], winslash = "/",
                            mustWork = FALSE)
  skip_if(!nzchar(fake_exe), "Rscript not resolvable")
  testthat::local_mocked_bindings(
    Sys.which = function(...) fake_exe, .package = "base"
  )
  testthat::local_mocked_bindings(
    system2 = function(...) "2.4.0", .package = "base"
  )
  res <- check_pydicom(verbose = FALSE)
  expect_true(res$available)
  expect_equal(res$version, "2.4.0")
})

test_that("check_pydicom marks unavailable when python errors out", {
  fake_exe <- normalizePath(Sys.which("Rscript")[[1]], winslash = "/",
                            mustWork = FALSE)
  skip_if(!nzchar(fake_exe), "Rscript not resolvable")
  testthat::local_mocked_bindings(
    Sys.which = function(...) fake_exe, .package = "base"
  )
  testthat::local_mocked_bindings(
    system2 = function(...) "Traceback (most recent call last):",
    .package = "base"
  )
  res <- check_pydicom(verbose = FALSE)
  expect_false(res$available)
})
