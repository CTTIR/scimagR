# Tests for parameter extraction wrappers (sct-analyze.R)

test_that("sct_analyze_lesion errors on a missing lesion segmentation", {
  dir <- withr::local_tempdir()
  sc <- touch(file.path(dir, "sc.nii.gz"))
  expect_error(
    sct_analyze_lesion(file.path(dir, "nope.nii.gz"), sc, verbose = FALSE),
    "Lesion segmentation not found"
  )
})

test_that("sct_analyze_lesion errors on a missing SC segmentation", {
  dir <- withr::local_tempdir()
  les <- touch(file.path(dir, "lesion.nii.gz"))
  expect_error(
    sct_analyze_lesion(les, file.path(dir, "nope.nii.gz"), verbose = FALSE),
    "SC segmentation not found"
  )
})

test_that("sct_analyze_lesion returns the spreadsheet SCT writes", {
  dir <- withr::local_tempdir()
  les <- touch(file.path(dir, "sub-01_lesion_seg.nii.gz"))
  sc <- touch(file.path(dir, "sub-01_sc_seg.nii.gz"))
  local_fake_sct()
  res <- sct_analyze_lesion(les, sc, verbose = FALSE)
  expect_equal(basename(res), "sub-01_lesion_seg_analysis.xlsx")
  expect_true(file.exists(res))
})

test_that("sct_analyze_lesion finds the .xls file of SCT 6", {
  dir <- withr::local_tempdir()
  les <- touch(file.path(dir, "sub-01_lesion_seg.nii.gz"))
  sc <- touch(file.path(dir, "sub-01_sc_seg.nii.gz"))
  local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) {
      touch(file.path(dir, "sub-01_lesion_seg_analysis.xls"))
      list(exit_code = 0L)
    }
  )
  res <- sct_analyze_lesion(les, sc, verbose = FALSE)
  expect_equal(basename(res), "sub-01_lesion_seg_analysis.xls")
})

test_that("sct_analyze_lesion warns and returns NA without a spreadsheet", {
  dir <- withr::local_tempdir()
  les <- touch(file.path(dir, "sub-01_lesion_seg.nii.gz"))
  sc <- touch(file.path(dir, "sub-01_sc_seg.nii.gz"))
  local_fake_sct(write = FALSE)
  expect_warning(res <- sct_analyze_lesion(les, sc, verbose = FALSE),
                 "did not write")
  expect_true(is.na(res))
})

test_that("sct_analyze_lesion returns NA when the run fails", {
  dir <- withr::local_tempdir()
  les <- touch(file.path(dir, "lesion.nii.gz"))
  sc <- touch(file.path(dir, "sc.nii.gz"))
  local_fake_sct(exit_code = 1L)
  expect_true(is.na(sct_analyze_lesion(les, sc, verbose = FALSE)))
})

test_that("sct_analyze_lesion honours an explicit output_dir", {
  dir <- withr::local_tempdir()
  les <- touch(file.path(dir, "sub-01_lesion_seg.nii.gz"))
  sc <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  outdir <- file.path(dir, "out")
  dir.create(outdir)
  local_fake_sct()
  expect_message(res <- sct_analyze_lesion(les, sc, output_dir = outdir),
                 "Lesion analysis saved")
  expect_equal(normalizePath(dirname(res)), normalizePath(outdir))
})

test_that("sct_process_segmentation errors on a missing SC segmentation", {
  dir <- withr::local_tempdir()
  vert <- touch(file.path(dir, "vert.nii.gz"))
  expect_error(
    sct_process_segmentation(file.path(dir, "nope.nii.gz"), vert,
                             verbose = FALSE),
    "SC segmentation not found"
  )
})

test_that("sct_process_segmentation errors on missing vertebral labels", {
  dir <- withr::local_tempdir()
  sc <- touch(file.path(dir, "sc.nii.gz"))
  expect_error(
    sct_process_segmentation(sc, file.path(dir, "nope.nii.gz"),
                             verbose = FALSE),
    "Vertebral labels not found"
  )
})

test_that("sct_process_segmentation returns a CSA CSV path on success", {
  dir <- withr::local_tempdir()
  sc <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  vert <- touch(file.path(dir, "sub-01_seg_labeled.nii.gz"))
  rec <- local_fake_sct()
  expect_message(res <- sct_process_segmentation(sc, vert), "CSA metrics saved")
  expect_equal(basename(res), "sub-01_seg_csa.csv")
  args <- rec$calls[[1]]$args
  expect_equal(arg_value(args, "-vertfile"), vert)
  expect_false(any(c("-vert", "-perlevel", "-perslice") %in% args))
})

test_that("sct_process_segmentation adds -perslice flag and returns NA on failure", {
  dir <- withr::local_tempdir()
  sc <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  vert <- touch(file.path(dir, "sub-01_seg_labeled.nii.gz"))
  rec <- local_fake_sct(exit_code = 1L)
  res <- sct_process_segmentation(sc, vert, perslice = TRUE, verbose = FALSE)
  expect_true(is.na(res))
  expect_true("-perslice" %in% rec$calls[[1]]$args)
})

test_that("sct_process_segmentation passes vertebral levels and perlevel", {
  dir <- withr::local_tempdir()
  sc <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  vert <- touch(file.path(dir, "sub-01_seg_labeled.nii.gz"))
  rec <- local_fake_sct()
  sct_process_segmentation(sc, vert, vert = 2:7, perlevel = TRUE,
                           verbose = FALSE)
  args <- rec$calls[[1]]$args
  expect_equal(arg_value(args, "-vert"), "2:7")
  expect_equal(arg_value(args, "-perlevel"), "1")
})

test_that("sct_process_segmentation requires vert for perlevel", {
  dir <- withr::local_tempdir()
  sc <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  vert <- touch(file.path(dir, "sub-01_seg_labeled.nii.gz"))
  expect_error(sct_process_segmentation(sc, vert, perlevel = TRUE),
               class = "scimagR_error_input")
})

test_that("sct_process_segmentation warns and returns NA without a CSV", {
  dir <- withr::local_tempdir()
  sc <- touch(file.path(dir, "sub-01_seg.nii.gz"))
  vert <- touch(file.path(dir, "sub-01_seg_labeled.nii.gz"))
  local_fake_sct(write = FALSE)
  expect_warning(res <- sct_process_segmentation(sc, vert, verbose = FALSE),
                 "did not write")
  expect_true(is.na(res))
})

test_that("format_vert_levels writes SCT level syntax", {
  expect_equal(format_vert_levels(2:7), "2:7")
  expect_equal(format_vert_levels(c(2, 4, 5)), "2,4,5")
  expect_equal(format_vert_levels(3), "3")
  expect_equal(format_vert_levels("2:7"), "2:7")
  expect_error(format_vert_levels(2.5), class = "scimagR_error_input")
  expect_error(format_vert_levels(c(1, NA)), class = "scimagR_error_input")
})
