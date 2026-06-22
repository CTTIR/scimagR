# Tests for DICOM anonymization (dicom-anonymize.R)

test_that("anonymize_dicom errors when the DICOM dir is missing", {
  expect_error(
    anonymize_dicom(file.path(tempdir(), "no-dicom-xyz"),
                    file.path(tempdir(), "map.csv")),
    "DICOM directory not found"
  )
})

test_that("anonymize_dicom errors when pydicom is unavailable", {
  dir <- withr::local_tempdir()
  local_mocked_bindings(
    check_pydicom = function(...) list(available = FALSE, version = NA, path = NA)
  )
  expect_error(anonymize_dicom(dir, file.path(dir, "map.csv")),
               "pydicom is required")
})

test_that("anonymize_dicom warns about in-place modification and returns exit code", {
  din <- withr::local_tempdir()
  mapping <- file.path(withr::local_tempdir(), "secure", "map.csv")
  local_mocked_bindings(
    check_pydicom = function(...) list(available = TRUE, version = "2", path = "py")
  )
  testthat::local_mocked_bindings(system2 = function(...) 0L, .package = "base")
  res <- expect_message(
    anonymize_dicom(din, mapping),
    "modify DICOM files in-place"
  )
  expect_true(dir.exists(dirname(mapping)))
})

test_that("anonymize_dicom aborts on a non-zero exit code", {
  din <- withr::local_tempdir()
  mapping <- file.path(din, "map.csv")
  local_mocked_bindings(
    check_pydicom = function(...) list(available = TRUE, version = "2", path = "py")
  )
  testthat::local_mocked_bindings(system2 = function(...) 4L, .package = "base")
  suppressMessages(
    expect_error(anonymize_dicom(din, mapping), "exit code")
  )
})

test_that("anonymize_dicom returns the exit code invisibly on success", {
  din <- withr::local_tempdir()
  mapping <- file.path(din, "map.csv")
  local_mocked_bindings(
    check_pydicom = function(...) list(available = TRUE, version = "2", path = "py")
  )
  testthat::local_mocked_bindings(system2 = function(...) 0L, .package = "base")
  res <- suppressMessages(expect_invisible(anonymize_dicom(din, mapping)))
  expect_equal(res, 0L)
})
