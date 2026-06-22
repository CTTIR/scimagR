# Tests for DICOM metadata extraction (dicom-metadata.R)

test_that("extract_dicom_metadata errors when the DICOM dir is missing", {
  expect_error(
    extract_dicom_metadata(file.path(tempdir(), "no-dicom-xyz"),
                           file.path(tempdir(), "m.csv")),
    "DICOM directory not found"
  )
})

test_that("extract_dicom_metadata errors when pydicom is unavailable", {
  dir <- withr::local_tempdir()
  local_mocked_bindings(
    check_pydicom = function(...) list(available = FALSE, version = NA, path = NA)
  )
  expect_error(extract_dicom_metadata(dir, file.path(dir, "m.csv")),
               "pydicom is required")
})

test_that("extract_dicom_metadata creates the output dir and returns the csv path", {
  din <- withr::local_tempdir()
  out <- file.path(withr::local_tempdir(), "meta", "dicom.csv")
  local_mocked_bindings(
    check_pydicom = function(...) list(available = TRUE, version = "2", path = "py")
  )
  testthat::local_mocked_bindings(system2 = function(...) 0L, .package = "base")
  res <- expect_invisible(extract_dicom_metadata(din, out))
  expect_equal(res, out)
  expect_true(dir.exists(dirname(out)))
})

test_that("extract_dicom_metadata aborts on a non-zero exit code", {
  din <- withr::local_tempdir()
  out <- file.path(din, "dicom.csv")
  local_mocked_bindings(
    check_pydicom = function(...) list(available = TRUE, version = "2", path = "py")
  )
  testthat::local_mocked_bindings(system2 = function(...) 7L, .package = "base")
  expect_error(extract_dicom_metadata(din, out), "exit code")
})
