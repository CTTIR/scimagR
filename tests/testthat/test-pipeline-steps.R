# Tests for internal pipeline step wrappers (pipeline-steps.R)

test_that("pipeline_step_extract_metadata delegates and returns 'complete'", {
  seen <- NULL
  local_mocked_bindings(
    extract_dicom_metadata = function(dicom_dir, output_csv, python) {
      seen <<- list(dicom_dir, output_csv, python); invisible(output_csv)
    }
  )
  cfg <- list(dicom_root = "d", dicom_metadata_csv = "m.csv", python = "py")
  expect_equal(pipeline_step_extract_metadata(cfg), "complete")
  expect_equal(seen[[1]], "d")
})

test_that("pipeline_step_anonymize delegates with the default prefix", {
  seen_prefix <- NULL
  local_mocked_bindings(
    anonymize_dicom = function(dicom_dir, mapping_csv, prefix, python) {
      seen_prefix <<- prefix; invisible(0L)
    }
  )
  cfg <- list(dicom_root = "d", mapping_csv = "map.csv", python = "py")
  expect_equal(pipeline_step_anonymize(cfg), "complete")
  expect_equal(seen_prefix, "SCI")
})

test_that("pipeline_step_convert delegates to convert_batch", {
  called <- FALSE
  local_mocked_bindings(
    convert_batch = function(registry, dicom_root, nifti_root, verbose) {
      called <<- TRUE; tibble::tibble()
    }
  )
  cfg <- list(dicom_root = "d", nifti_root = "n")
  expect_equal(pipeline_step_convert(cfg, data.frame()), "complete")
  expect_true(called)
})

test_that("pipeline_step_segment_sc forwards to sct_segment_sc", {
  local_mocked_bindings(
    sct_segment_sc = function(input, ...) paste0(input, "_seg")
  )
  expect_equal(pipeline_step_segment_sc("x.nii.gz"), "x.nii.gz_seg")
})

test_that("pipeline_step_segment_lesion forwards to sct_segment_lesion", {
  local_mocked_bindings(
    sct_segment_lesion = function(input, ...) paste0(input, "_lesion")
  )
  expect_equal(pipeline_step_segment_lesion("x.nii.gz"), "x.nii.gz_lesion")
})

test_that("pipeline_step_label_vertebrae forwards to sct_label_vertebrae", {
  local_mocked_bindings(
    sct_label_vertebrae = function(input, segmentation, ...) "labels.nii.gz"
  )
  expect_equal(pipeline_step_label_vertebrae("x.nii.gz", "x_seg.nii.gz"),
               "labels.nii.gz")
})

test_that("pipeline_step_extract_params returns both output csv paths", {
  local_mocked_bindings(
    sct_analyze_lesion = function(...) "lesion.csv",
    sct_process_segmentation = function(...) "csa.csv"
  )
  res <- pipeline_step_extract_params("les", "sc", "vert")
  expect_equal(res$lesion_csv, "lesion.csv")
  expect_equal(res$csa_csv, "csa.csv")
})
