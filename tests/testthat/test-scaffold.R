# Tests for sci_create_project

test_that("sci_create_project creates expected structure", {
  tmp <- withr::local_tempdir()
  proj <- file.path(tmp, "test-project")
  sci_create_project(proj, title = "Test", author = "Test Author", open = FALSE)

  expect_true(dir.exists(file.path(proj, "analysis")))
  expect_true(dir.exists(file.path(proj, "code")))
  expect_true(dir.exists(file.path(proj, "data", "raw", "dicom")))
  expect_true(dir.exists(file.path(proj, "data", "nifti")))
  expect_true(dir.exists(file.path(proj, "data", "metadata")))
  expect_true(dir.exists(file.path(proj, "data", "segmentations")))
  expect_true(dir.exists(file.path(proj, "data", "parameters")))
  expect_true(dir.exists(file.path(proj, "data", "qc")))
  expect_true(dir.exists(file.path(proj, "results", "figures")))
  expect_true(dir.exists(file.path(proj, "results", "tables")))
  expect_true(dir.exists(file.path(proj, "results", "models")))
  expect_true(dir.exists(file.path(proj, "manuscript")))
  expect_true(dir.exists(file.path(proj, "scripts")))
})

test_that("sci_create_project creates config file", {
  tmp <- withr::local_tempdir()
  proj <- file.path(tmp, "test-project2")
  sci_create_project(proj, title = "Test2", author = "Author2", open = FALSE)

  config <- file.path(proj, "code", "00-config.R")
  expect_true(file.exists(config))

  content <- readLines(config)
  expect_true(any(grepl("library\\(scimagR\\)", content)))
  expect_true(any(grepl("Author2", content)))
})

test_that("sci_create_project creates Rmd templates", {
  tmp <- withr::local_tempdir()
  proj <- file.path(tmp, "test-project3")
  sci_create_project(proj, title = "Test3", author = "Author3", open = FALSE)

  expect_true(file.exists(file.path(proj, "analysis", "index.Rmd")))
  expect_true(file.exists(file.path(proj, "analysis", "00-orchestrate.Rmd")))
  expect_true(file.exists(file.path(proj, "analysis", "01-data.Rmd")))
  expect_true(file.exists(file.path(proj, "analysis", "09-report.Rmd")))
})

test_that("sci_create_project creates CSV templates", {
  tmp <- withr::local_tempdir()
  proj <- file.path(tmp, "test-project4")
  sci_create_project(proj, title = "Test4", author = "Author4", open = FALSE)

  expect_true(file.exists(file.path(proj, "data", "metadata", "imaging_registry.csv")))
  expect_true(file.exists(file.path(proj, "data", "metadata", "clinical_data.csv")))
  expect_true(file.exists(file.path(proj, "data", "metadata", "qc_segmentation_log.csv")))
})

test_that("sci_create_project errors on existing directory", {
  tmp <- withr::local_tempdir()
  proj <- file.path(tmp, "existing")
  dir.create(proj)
  expect_error(
    sci_create_project(proj, title = "Test", author = "Test", open = FALSE),
    "already exists"
  )
})

test_that("sci_create_project creates gitignore", {
  tmp <- withr::local_tempdir()
  proj <- file.path(tmp, "test-project5")
  sci_create_project(proj, title = "Test5", author = "Author5", open = FALSE)

  gitignore <- file.path(proj, ".gitignore")
  expect_true(file.exists(gitignore))
  content <- readLines(gitignore)
  expect_true(any(grepl("\\.nii\\.gz", content)))
})
