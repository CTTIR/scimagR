# Tests for parameter extraction wrappers (sct-analyze.R)

test_that("sct_analyze_lesion errors on a missing lesion segmentation", {
  dir <- withr::local_tempdir()
  sc <- file.path(dir, "sc.nii.gz"); file.create(sc)
  expect_error(
    sct_analyze_lesion(file.path(dir, "nope.nii.gz"), sc, verbose = FALSE),
    "Lesion segmentation not found"
  )
})

test_that("sct_analyze_lesion errors on a missing SC segmentation", {
  dir <- withr::local_tempdir()
  les <- file.path(dir, "lesion.nii.gz"); file.create(les)
  expect_error(
    sct_analyze_lesion(les, file.path(dir, "nope.nii.gz"), verbose = FALSE),
    "SC segmentation not found"
  )
})

test_that("sct_analyze_lesion returns an analysis CSV path on success", {
  dir <- withr::local_tempdir()
  les <- file.path(dir, "sub-01_lesion_seg.nii.gz"); file.create(les)
  sc <- file.path(dir, "sub-01_seg.nii.gz"); file.create(sc)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L)
  )
  res <- sct_analyze_lesion(les, sc, verbose = FALSE)
  expect_equal(basename(res), "sub-01_lesion_seg_analysis.csv")
})

test_that("sct_analyze_lesion returns NA when the run fails", {
  dir <- withr::local_tempdir()
  les <- file.path(dir, "lesion.nii.gz"); file.create(les)
  sc <- file.path(dir, "sc.nii.gz"); file.create(sc)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 1L)
  )
  expect_true(is.na(sct_analyze_lesion(les, sc, verbose = FALSE)))
})

test_that("sct_analyze_lesion honours an explicit output_dir", {
  dir <- withr::local_tempdir()
  les <- file.path(dir, "sub-01_lesion_seg.nii.gz"); file.create(les)
  sc <- file.path(dir, "sub-01_seg.nii.gz"); file.create(sc)
  outdir <- file.path(dir, "out")
  dir.create(outdir)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L)
  )
  res <- sct_analyze_lesion(les, sc, output_dir = outdir, verbose = FALSE)
  expect_equal(normalizePath(dirname(res)), normalizePath(outdir))
})

test_that("sct_process_segmentation errors on a missing SC segmentation", {
  dir <- withr::local_tempdir()
  vert <- file.path(dir, "vert.nii.gz"); file.create(vert)
  expect_error(
    sct_process_segmentation(file.path(dir, "nope.nii.gz"), vert, verbose = FALSE),
    "SC segmentation not found"
  )
})

test_that("sct_process_segmentation errors on missing vertebral labels", {
  dir <- withr::local_tempdir()
  sc <- file.path(dir, "sc.nii.gz"); file.create(sc)
  expect_error(
    sct_process_segmentation(sc, file.path(dir, "nope.nii.gz"), verbose = FALSE),
    "Vertebral labels not found"
  )
})

test_that("sct_process_segmentation returns a CSA CSV path on success", {
  dir <- withr::local_tempdir()
  sc <- file.path(dir, "sub-01_seg.nii.gz"); file.create(sc)
  vert <- file.path(dir, "sub-01_labels-disc.nii.gz"); file.create(vert)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L)
  )
  res <- sct_process_segmentation(sc, vert, verbose = FALSE)
  expect_equal(basename(res), "sub-01_seg_csa.csv")
})

test_that("sct_process_segmentation adds -perslice flag and returns NA on failure", {
  dir <- withr::local_tempdir()
  sc <- file.path(dir, "sub-01_seg.nii.gz"); file.create(sc)
  vert <- file.path(dir, "sub-01_labels-disc.nii.gz"); file.create(vert)
  seen_args <- NULL
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) {
      seen_args <<- args; list(exit_code = 1L)
    }
  )
  res <- sct_process_segmentation(sc, vert, perslice = TRUE, verbose = FALSE)
  expect_true(is.na(res))
  expect_true("-perslice" %in% seen_args)
})
