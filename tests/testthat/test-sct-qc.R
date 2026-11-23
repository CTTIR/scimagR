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

test_that("sct_generate_qc defaults to a process sct_qc accepts", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "t2.nii.gz"))
  seg <- touch(file.path(dir, "seg.nii.gz"))
  rec <- local_fake_sct()
  sct_generate_qc(input, seg, file.path(dir, "qc"), verbose = FALSE)
  expect_equal(arg_value(rec$calls[[1]]$args, "-p"), "sct_deepseg_sc")
  # The former default "sct_deepseg" is not an sct_qc process.
  sct_generate_qc(input, seg, file.path(dir, "qc"), process = "sct_deepseg",
                  verbose = FALSE)
  expect_equal(arg_value(rec$calls[[2]]$args, "-p"), "sct_deepseg_sc")
})

test_that("sct_generate_qc builds a lesion report with -d and -plane", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "t2.nii.gz"))
  seg <- touch(file.path(dir, "t2_sc_seg.nii.gz"))
  les <- touch(file.path(dir, "t2_lesion_seg.nii.gz"))
  rec <- local_fake_sct()
  sct_generate_qc(input, seg, file.path(dir, "qc"),
                  process = "sct_deepseg_lesion", lesion = les,
                  plane = "axial", verbose = FALSE)
  args <- rec$calls[[1]]$args
  expect_equal(arg_value(args, "-s"), seg)
  expect_equal(arg_value(args, "-d"), les)
  expect_equal(arg_value(args, "-plane"), "axial")
})

test_that("sct_generate_qc requires the lesion mask for a lesion report", {
  dir <- withr::local_tempdir()
  input <- touch(file.path(dir, "t2.nii.gz"))
  seg <- touch(file.path(dir, "seg.nii.gz"))
  expect_error(
    sct_generate_qc(input, seg, file.path(dir, "qc"),
                    process = "sct_deepseg_lesion", verbose = FALSE),
    class = "scimagR_error_input"
  )
  expect_error(
    sct_generate_qc(input, seg, file.path(dir, "qc"),
                    process = "sct_deepseg_lesion",
                    lesion = file.path(dir, "nope.nii.gz"), verbose = FALSE),
    "Lesion file not found"
  )
  expect_error(
    sct_generate_qc(input, seg, file.path(dir, "qc"), plane = "coronal"),
    "plane"
  )
})
