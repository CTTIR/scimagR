# Tests for vertebral labeling wrapper (sct-label.R)

test_that("sct_label_vertebrae errors on a missing input", {
  dir <- withr::local_tempdir()
  seg <- file.path(dir, "seg.nii.gz"); file.create(seg)
  expect_error(
    sct_label_vertebrae(file.path(dir, "nope.nii.gz"), seg, verbose = FALSE),
    "Input file not found"
  )
})

test_that("sct_label_vertebrae errors on a missing segmentation", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "t2.nii.gz"); file.create(input)
  expect_error(
    sct_label_vertebrae(input, file.path(dir, "nope.nii.gz"), verbose = FALSE),
    "Segmentation file not found"
  )
})

test_that("sct_label_vertebrae validates argument types", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "t2.nii.gz"); file.create(input)
  seg <- file.path(dir, "seg.nii.gz"); file.create(seg)
  expect_error(sct_label_vertebrae(c(input, input), seg, verbose = FALSE))
})

test_that("sct_label_vertebrae is idempotent when output exists", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz"); file.create(input)
  seg <- file.path(dir, "sub-01_seg.nii.gz"); file.create(seg)
  out <- file.path(dir, "sub-01_labels-disc.nii.gz"); file.create(out)
  expect_equal(normalizePath(sct_label_vertebrae(input, seg, verbose = FALSE)),
               normalizePath(out))
})

test_that("sct_label_vertebrae returns the labels path on success", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz"); file.create(input)
  seg <- file.path(dir, "sub-01_seg.nii.gz"); file.create(seg)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 0L)
  )
  res <- sct_label_vertebrae(input, seg, verbose = FALSE)
  expect_equal(basename(res), "sub-01_labels-disc.nii.gz")
})

test_that("sct_label_vertebrae returns NA when the run fails", {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "sub-01.nii.gz"); file.create(input)
  seg <- file.path(dir, "sub-01_seg.nii.gz"); file.create(seg)
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) list(exit_code = 5L)
  )
  expect_true(is.na(sct_label_vertebrae(input, seg, verbose = FALSE)))
})
