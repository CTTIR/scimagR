# Tests for vertebral labelling wrapper (sct-label.R)

test_that("sct_label_vertebrae errors on a missing input", {
  dir <- withr::local_tempdir()
  seg <- touch(file.path(dir, "seg.nii.gz"))
  expect_error(
    sct_label_vertebrae(file.path(dir, "nope.nii.gz"), seg, verbose = FALSE),
    "Input file not found"
  )
})

test_that("sct_label_vertebrae errors on a missing segmentation", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "t2.nii.gz"))
  expect_error(
    sct_label_vertebrae(input, file.path(dir, "nope.nii.gz"), verbose = FALSE),
    "Segmentation file not found"
  )
})

test_that("sct_label_vertebrae validates argument types", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "t2.nii.gz"))
  seg <- touch(file.path(dir, "seg.nii.gz"))
  expect_error(sct_label_vertebrae(c(input, input), seg, verbose = FALSE),
               class = "scimagR_error_input")
})

test_that("sct_label_vertebrae is idempotent when output exists", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  seg <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  out <- touch(file.path(dir, "sub-01_seg_labeled.nii.gz"))
  rec <- local_fake_sct()
  expect_equal(normalizePath(sct_label_vertebrae(input, seg, verbose = FALSE)),
               normalizePath(out))
  expect_length(rec$calls, 0)
})

test_that("sct_label_vertebrae returns the file SCT writes", {
  # sct_label_vertebrae names its outputs after the segmentation:
  # <seg>_labeled.nii.gz and <seg>_labeled_discs.nii.gz.
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  seg <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  rec <- local_fake_sct()
  res <- sct_label_vertebrae(input, seg, verbose = FALSE)
  expect_equal(basename(res), "sub-01_seg_labeled.nii.gz")
  expect_true(file.exists(res))
  expect_equal(arg_value(rec$calls[[1]]$args, "-c"), "t2")
})

test_that("sct_label_vertebrae writes to output_dir", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  seg <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  out_dir <- file.path(dir, "labels")
  local_fake_sct()
  res <- sct_label_vertebrae(input, seg, output_dir = out_dir, verbose = FALSE)
  expect_equal(res, file.path(out_dir, "sub-01_seg_labeled.nii.gz"))
})

test_that("sct_label_vertebrae returns NA when the run fails", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  seg <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  local_fake_sct(exit_code = 5L)
  expect_true(is.na(sct_label_vertebrae(input, seg, verbose = FALSE)))
})

test_that("sct_label_vertebrae warns and returns NA without output", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  seg <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  local_fake_sct(write = FALSE)
  expect_warning(res <- sct_label_vertebrae(input, seg, verbose = FALSE),
                 "did not write")
  expect_true(is.na(res))
})

test_that("sct_label_vertebrae reports success when verbose", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  seg <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  local_fake_sct()
  expect_message(sct_label_vertebrae(input, seg), "Vertebral labels saved")
  expect_message(sct_label_vertebrae(input, seg), "Output exists")
})
