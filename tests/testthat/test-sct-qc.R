# Tests for QC report generation wrapper (sct-qc.R)

test_that("sct_generate_qc errors on a missing input", {
  dir <- withr::local_tempdir()
  seg <- file.path(dir, "seg.nii.gz"); file.create(seg)
  expect_error(
    sct_generate_qc(file.path(dir, "nope.nii.gz"), seg, file.path(dir, "qc"),
                    verbose = FALSE),
    "Input file not found"
  )
})

test_that("sct_generate_qc errors on a missing segmentation", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "t2.nii.gz"); file.create(input)
  expect_error(
    sct_generate_qc(input, file.path(dir, "nope.nii.gz"), file.path(dir, "qc"),
                    verbose = FALSE),
    "Segmentation file not found"
  )
})

test_that("sct_generate_qc creates the qc directory and returns the exit code", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "t2.nii.gz"); file.create(input)
  seg <- file.path(dir, "seg.nii.gz"); file.create(seg)
  qc <- file.path(dir, "qc")
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L)
  )
  res <- expect_invisible(sct_generate_qc(input, seg, qc, verbose = FALSE))
  expect_true(dir.exists(qc))
  expect_equal(res, 0L)
})

test_that("sct_generate_qc passes the process label through to sct_run", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "t2.nii.gz"); file.create(input)
  seg <- file.path(dir, "seg.nii.gz"); file.create(seg)
  seen_args <- NULL
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) {
      seen_args <<- args; list(exit_code = 0L)
    }
  )
  sct_generate_qc(input, seg, file.path(dir, "qc"),
                  process = "my_process", verbose = FALSE)
  expect_true("my_process" %in% seen_args)
})

test_that("sct_generate_qc surfaces a non-zero exit code", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "t2.nii.gz"); file.create(input)
  seg <- file.path(dir, "seg.nii.gz"); file.create(seg)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 1L)
  )
  res <- sct_generate_qc(input, seg, file.path(dir, "qc"), verbose = FALSE)
  expect_equal(res, 1L)
})
