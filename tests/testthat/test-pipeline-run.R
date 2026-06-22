# Tests for pipeline orchestration (pipeline-run.R)

make_project <- function(envir = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = envir)
  proj <- file.path(dir, "proj")
  dir.create(file.path(proj, "code"), recursive = TRUE)
  writeLines("# config", file.path(proj, "code", "00-config.R"))
  proj
}

test_that("sci_run_pipeline errors when project dir is missing", {
  expect_error(sci_run_pipeline(file.path(tempdir(), "no-proj-xyz")),
               "Project directory not found")
})

test_that("sci_run_pipeline errors when config file is absent", {
  dir <- withr::local_tempdir()
  proj <- file.path(dir, "proj"); dir.create(proj)
  expect_error(sci_run_pipeline(proj), "Config file not found")
})

test_that("sci_run_pipeline marks requested steps complete", {
  proj <- make_project()
  res <- sci_run_pipeline(proj, steps = c(1, 3, 4), verbose = FALSE)
  expect_equal(nrow(res), 3)
  expect_true(all(res$status == "complete"))
  expect_named(res, c("step", "name", "status", "message"))
})

test_that("sci_run_pipeline skips step 2 when anonymize is FALSE", {
  proj <- make_project()
  res <- sci_run_pipeline(proj, steps = 2, verbose = FALSE)
  expect_equal(res$status, "skipped")
  expect_equal(res$message, "anonymize = FALSE")
})

test_that("sci_run_pipeline runs step 2 when anonymize is TRUE", {
  proj <- make_project()
  res <- sci_run_pipeline(proj, steps = 2, anonymize = TRUE, verbose = FALSE)
  expect_equal(res$status, "complete")
})

test_that("sci_run_pipeline warns on and skips invalid step numbers", {
  proj <- make_project()
  res <- NULL
  warns <- character()
  withCallingHandlers(
    res <- sci_run_pipeline(proj, steps = c(0, 9), verbose = FALSE),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  expect_true(any(grepl("invalid step", warns)))
  expect_equal(nrow(res), 0)
})

test_that("sci_run_pipeline emits a QC pause after step 5 when verbose", {
  proj <- make_project()
  expect_message(
    sci_run_pipeline(proj, steps = 5, verbose = TRUE),
    "QC PAUSE"
  )
})

test_that("sci_pipeline_status returns an empty tibble before any processing", {
  proj <- make_project()
  res <- sci_pipeline_status(proj)
  expect_equal(nrow(res), 0)
  expect_named(res, c("pat_id", "session", "converted", "sc_seg",
                      "lesion_seg", "vert_labels", "qc_done", "params_extracted"))
})

test_that("sci_pipeline_status errors when the project dir is missing", {
  expect_error(sci_pipeline_status(file.path(tempdir(), "no-proj-xyz")),
               "Project directory not found")
})

test_that("sci_pipeline_status detects per-session processing artefacts", {
  proj <- make_project()
  ses <- file.path(proj, "data", "nifti", "SCI001", "ses-01")
  dir.create(ses, recursive = TRUE)
  file.create(file.path(ses, "img.nii.gz"))
  file.create(file.path(ses, "img_seg.nii.gz"))
  file.create(file.path(ses, "img_lesion_seg.nii.gz"))
  file.create(file.path(ses, "img_labels-disc.nii.gz"))
  file.create(file.path(ses, "params.csv"))
  dir.create(file.path(ses, "qc"))

  res <- sci_pipeline_status(proj)
  expect_equal(nrow(res), 1)
  expect_true(res$converted)
  expect_true(res$sc_seg)
  expect_true(res$lesion_seg)
  expect_true(res$vert_labels)
  expect_true(res$qc_done)
  expect_true(res$params_extracted)
})
