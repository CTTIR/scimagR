# Tests for DICOM->NIfTI conversion (dicom-convert.R)

test_that("convert_dcm2niix errors when the DICOM directory is missing", {
  expect_error(
    convert_dcm2niix(file.path(tempdir(), "no-dicom-xyz"),
                     file.path(tempdir(), "out"), verbose = FALSE),
    "DICOM directory not found"
  )
})

test_that("convert_dcm2niix errors when dcm2niix is unavailable", {
  dir <- withr::local_tempdir()
  local_mocked_bindings(
    check_dcm2niix = function(...) list(available = FALSE, version = NA, path = NA)
  )
  expect_error(convert_dcm2niix(dir, file.path(dir, "out"), verbose = FALSE),
               "dcm2niix is required")
})

test_that("convert_dcm2niix creates output dir and lists produced NIfTIs", {
  din <- withr::local_tempdir()
  dout <- file.path(withr::local_tempdir(), "nifti")
  local_mocked_bindings(
    check_dcm2niix = function(...) list(available = TRUE, version = "x", path = "x")
  )
  # Simulate the converter producing a file by stubbing system2.
  testthat::local_mocked_bindings(
    system2 = function(...) {
      file.create(file.path(dout, "sub-01.nii.gz"))
      character()
    },
    .package = "base"
  )
  outputs <- convert_dcm2niix(din, dout, verbose = FALSE)
  expect_true(dir.exists(dout))
  expect_equal(basename(outputs), "sub-01.nii.gz")
})

test_that("convert_dcm2niix matches uncompressed extension when compress=FALSE", {
  din <- withr::local_tempdir()
  dout <- file.path(withr::local_tempdir(), "nifti")
  local_mocked_bindings(
    check_dcm2niix = function(...) list(available = TRUE, version = "x", path = "x")
  )
  testthat::local_mocked_bindings(
    system2 = function(...) {
      file.create(file.path(dout, "sub-01.nii"))
      character()
    },
    .package = "base"
  )
  outputs <- convert_dcm2niix(din, dout, compress = FALSE, verbose = FALSE)
  expect_equal(basename(outputs), "sub-01.nii")
})

test_that("convert_batch errors on missing required columns", {
  expect_error(
    convert_batch(data.frame(x = 1), tempdir(), tempdir(), verbose = FALSE),
    "missing columns"
  )
})

test_that("convert_batch tabulates per-session success and failure", {
  reg <- data.frame(
    pat_id = c("P1", "P2"),
    session = c("s1", "s1"),
    stringsAsFactors = FALSE
  )
  local_mocked_bindings(
    convert_dcm2niix = function(dicom_dir, output_dir, ...) {
      if (grepl("P1", dicom_dir)) c("a.nii.gz", "b.nii.gz") else stop("boom")
    }
  )
  res <- convert_batch(reg, "dicom", "nifti", verbose = FALSE)
  expect_equal(nrow(res), 2)
  expect_equal(res$status, c("success", "error"))
  expect_equal(res$n_files, c(2L, 0L))
  expect_named(res, c("pat_id", "session", "status", "n_files"))
})

test_that("convert_dcm2niix aborts when dcm2niix exits with an error", {
  din <- withr::local_tempdir()
  dout <- file.path(withr::local_tempdir(), "nifti")
  local_mocked_bindings(
    check_dcm2niix = function(...) list(available = TRUE, version = "x", path = "x")
  )
  testthat::local_mocked_bindings(
    system2 = function(...) structure("Error: no DICOM found", status = 2L),
    .package = "base"
  )
  expect_error(convert_dcm2niix(din, dout, verbose = FALSE), "exit code 2")
})

test_that("convert_dcm2niix converts the bundled synthetic DICOM", {
  skip_on_cran()
  skip_if_not(check_dcm2niix(verbose = FALSE)$available, "dcm2niix not installed")
  session <- system.file("extdata", "dicom", "SCI001", "ses-01",
                         package = "scimagR")
  dout <- file.path(withr::local_tempdir(), "nifti")
  out <- convert_dcm2niix(session, dout, verbose = FALSE)
  expect_length(out, 1)
  expect_match(basename(out), "\\.nii\\.gz$")
  expect_gt(file.size(out), 0)
})
