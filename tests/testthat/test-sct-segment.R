# Tests for SC / lesion segmentation wrappers (sct-segment.R)

make_nii <- function(name = "sub-01.nii.gz") {
  dir <- withr::local_tempdir(.local_envir = parent.frame())
  path <- file.path(dir, name)
  file.create(path)
  path
}

test_that("sct_segment_sc errors on a missing input file", {
  expect_error(sct_segment_sc(file.path(tempdir(), "no-such.nii.gz"),
                              verbose = FALSE),
               "Input file not found")
})

test_that("sct_segment_sc validates input is a length-1 character", {
  expect_error(sct_segment_sc(c("a", "b"), verbose = FALSE))
})

test_that("sct_segment_sc is idempotent when output already exists", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  out <- file.path(dir, "sub-01_seg.nii.gz")
  file.create(out)
  res <- sct_segment_sc(input, verbose = FALSE)
  expect_equal(normalizePath(res), normalizePath(out))
})

test_that("sct_segment_sc returns the output path on a successful run", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L)
  )
  res <- sct_segment_sc(input, verbose = FALSE)
  expect_equal(basename(res), "sub-01_seg.nii.gz")
})

test_that("sct_segment_sc returns NA when the SCT run fails", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 1L)
  )
  expect_true(is.na(sct_segment_sc(input, verbose = FALSE)))
})

test_that("sct_segment_sc triggers QC generation when qc_dir is supplied", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  qc_called <- 0L
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L),
    sct_generate_qc = function(...) { qc_called <<- qc_called + 1L; invisible(0L) }
  )
  sct_segment_sc(input, qc_dir = file.path(dir, "qc"), verbose = FALSE)
  expect_equal(qc_called, 1L)
})

test_that("sct_segment_sc honours an explicit output path", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  custom <- file.path(dir, "custom_seg.nii.gz")
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L)
  )
  res <- sct_segment_sc(input, output = custom, verbose = FALSE)
  expect_equal(res, custom)
})

test_that("sct_segment_lesion errors on a missing input file", {
  expect_error(sct_segment_lesion(file.path(tempdir(), "no-such.nii.gz"),
                                  verbose = FALSE),
               "Input file not found")
})

test_that("sct_segment_lesion is idempotent when output exists", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  out <- file.path(dir, "sub-01_lesion_seg.nii.gz")
  file.create(out)
  expect_equal(normalizePath(sct_segment_lesion(input, verbose = FALSE)),
               normalizePath(out))
})

test_that("sct_segment_lesion returns NA when the SCT run fails", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 2L)
  )
  expect_true(is.na(sct_segment_lesion(input, verbose = FALSE)))
})

test_that("sct_segment_lesion returns the lesion output path on success", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L)
  )
  res <- sct_segment_lesion(input, verbose = FALSE)
  expect_equal(basename(res), "sub-01_lesion_seg.nii.gz")
})

test_that("sct_segment_lesion generates lesion QC with the right process", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz")
  file.create(input)
  seen_process <- NULL
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L),
    sct_generate_qc = function(input, segmentation, qc_dir, process = "sct_deepseg", ...) {
      seen_process <<- process; invisible(0L)
    }
  )
  sct_segment_lesion(input, qc_dir = file.path(dir, "qc"), verbose = FALSE)
  expect_equal(seen_process, "sct_deepseg_lesion")
})
