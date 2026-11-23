# Tests for SC / lesion segmentation wrappers (sct-segment.R)

test_that("sct_segment_sc errors on a missing input file", {
  expect_error(sct_segment_sc(file.path(tempdir(), "no-such.nii.gz"),
                              verbose = FALSE),
               "Input file not found")
})

test_that("sct_segment_sc validates input is a length-1 character", {
  expect_error(sct_segment_sc(c("a", "b"), verbose = FALSE),
               class = "scimagR_error_input")
  expect_error(sct_segment_sc(1, verbose = FALSE),
               class = "scimagR_error_input")
})

test_that("sct_segment_sc is idempotent when output already exists", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  out <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  rec <- local_fake_sct()
  res <- sct_segment_sc(input, verbose = FALSE)
  expect_equal(normalizePath(res), normalizePath(out))
  expect_length(rec$calls, 0)
})

test_that("sct_segment_sc returns the output path on a successful run", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  local_fake_sct()
  res <- sct_segment_sc(input, verbose = FALSE)
  expect_equal(basename(res), "sub-01_seg.nii.gz")
  expect_true(file.exists(res))
})

test_that("sct_segment_sc uses the SCT 7 task syntax", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  rec <- local_fake_sct(major = 7L)
  sct_segment_sc(input, verbose = FALSE)
  args <- rec$calls[[1]]$args
  expect_equal(rec$calls[[1]]$cmd, "sct_deepseg")
  expect_equal(args[[1]], "spinalcord")
  expect_false("-task" %in% args)
})

test_that("sct_segment_sc uses -task with SCT 6", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  rec <- local_fake_sct(major = 6L)
  sct_segment_sc(input, verbose = FALSE)
  expect_equal(arg_value(rec$calls[[1]]$args, "-task"),
               "seg_sc_contrast_agnostic")
})

test_that("sct_segment_sc returns NA when the SCT run fails", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  local_fake_sct(exit_code = 1L)
  expect_true(is.na(sct_segment_sc(input, verbose = FALSE)))
})

test_that("sct_segment_sc warns and returns NA when SCT writes no output", {
  # SCT 7 given the old `-task` syntax prints a note and exits with status 0.
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  local_fake_sct(write = FALSE)
  expect_warning(res <- sct_segment_sc(input, verbose = FALSE),
                 "did not write")
  expect_true(is.na(res))
})

test_that("sct_segment_sc passes qc_dir to sct_deepseg", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  rec <- local_fake_sct()
  sct_segment_sc(input, qc_dir = file.path(dir, "qc"), verbose = FALSE)
  expect_length(rec$calls, 1)
  expect_equal(arg_value(rec$calls[[1]]$args, "-qc"), file.path(dir, "qc"))
})

test_that("sct_segment_sc honours an explicit output path", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  custom <- file.path(dir, "custom_seg.nii.gz")
  local_fake_sct()
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
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  out <- touch(file.path(dir, "sub-01_lesion_seg.nii.gz"))
  expect_equal(normalizePath(sct_segment_lesion(input, verbose = FALSE)),
               normalizePath(out))
})

test_that("sct_segment_lesion returns NA when the SCT run fails", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  local_fake_sct(exit_code = 2L)
  expect_true(is.na(sct_segment_lesion(input, verbose = FALSE)))
})

test_that("sct_segment_lesion saves the lesion and cord masks of SCIsegV2", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  rec <- local_fake_sct()
  res <- sct_segment_lesion(input, verbose = FALSE)
  expect_equal(basename(res), "sub-01_lesion_seg.nii.gz")
  expect_true(file.exists(res))
  expect_true(file.exists(file.path(dir, "sub-01_sc_seg.nii.gz")))
  args <- rec$calls[[1]]$args
  expect_equal(args[[1]], "lesion_sci_t2")
  # -o never points at the input image
  expect_false(identical(normalizePath(arg_value(args, "-o"), mustWork = FALSE),
                         normalizePath(input)))
})

test_that("sct_segment_lesion uses -task with SCT 6", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  rec <- local_fake_sct(major = 6L)
  res <- sct_segment_lesion(input, verbose = FALSE)
  expect_equal(arg_value(rec$calls[[1]]$args, "-task"), "seg_sc_lesion_t2w_sci")
  expect_true(file.exists(res))
})

test_that("sct_segment_lesion honours a custom output path", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  custom <- file.path(dir, "out", "lesion.nii.gz")
  local_fake_sct()
  res <- sct_segment_lesion(input, output = custom, verbose = FALSE)
  expect_equal(res, custom)
  expect_true(file.exists(custom))
  expect_true(file.exists(file.path(dir, "out", "lesion_sc_seg.nii.gz")))
})

test_that("sct_segment_lesion returns NA when the mask cannot be saved", {
  # Regression: a failed copy to `output` was ignored and the path of a
  # file that does not exist was returned as a success.
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  blocker <- touch(file.path(dir, "not-a-folder"))
  local_fake_sct()
  expect_warning(
    res <- sct_segment_lesion(input,
                              output = file.path(blocker, "lesion.nii.gz"),
                              verbose = FALSE),
    "Could not save the lesion mask"
  )
  expect_true(is.na(res))
})

test_that("sct_segment_lesion warns and returns NA without a lesion mask", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  local_fake_sct(write = FALSE)
  expect_warning(res <- sct_segment_lesion(input, verbose = FALSE),
                 "did not write")
  expect_true(is.na(res))
})

test_that("sct_segment_lesion passes qc_dir to sct_deepseg", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  rec <- local_fake_sct()
  sct_segment_lesion(input, qc_dir = file.path(dir, "qc"), verbose = FALSE)
  expect_equal(arg_value(rec$calls[[1]]$args, "-qc"), file.path(dir, "qc"))
})

test_that("sct_segment_* report success when verbose", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "sub-01.nii.gz"))
  local_fake_sct()
  expect_message(sct_segment_sc(input), "SC segmentation saved")
  expect_message(sct_segment_lesion(input), "Lesion segmentation saved")
  expect_message(sct_segment_sc(input), "Output exists")
})
