# Tests for registry functions

test_that("validate_registry detects missing columns", {
  bad_df <- data.frame(pat_id = "A", session = "s1")
  expect_error(validate_registry(bad_df), "Missing required")
})

test_that("validate_registry detects duplicate sessions", {
  dup_df <- data.frame(
    pat_id = c("A", "A"),
    session = c("s1", "s1"),
    study_date = c("2024-01-01", "2024-01-01"),
    modality = c("MRT", "MRT")
  )
  expect_error(validate_registry(dup_df), "Duplicate")
})

test_that("validate_registry detects negative days_post_trauma", {
  bad_df <- data.frame(
    pat_id = "A",
    session = "s1",
    study_date = "2024-01-01",
    modality = "MRT",
    days_post_trauma = -5
  )
  expect_error(validate_registry(bad_df), "negative")
})

test_that("validate_registry detects invalid artifact grades", {
  bad_df <- data.frame(
    pat_id = "A",
    session = "s1",
    study_date = "2024-01-01",
    modality = "MRT",
    artifact_grade = 7
  )
  expect_error(validate_registry(bad_df), "artifact_grade")
})

test_that("validate_registry detects invalid modality", {
  bad_df <- data.frame(
    pat_id = "A",
    session = "s1",
    study_date = "2024-01-01",
    modality = "PET"
  )
  expect_error(validate_registry(bad_df), "Invalid modality")
})

test_that("validate_registry passes on valid data", {
  good_df <- data.frame(
    pat_id = c("A", "B"),
    session = c("s1", "s1"),
    study_date = c("2024-01-01", "2024-02-01"),
    modality = c("MRT", "CT")
  )
  expect_invisible(validate_registry(good_df))
})

test_that("create_registry computes days_post_trauma correctly", {
  meta <- data.frame(
    pat_id = c("SCI001", "SCI001"),
    session = c("ses-01", "ses-02"),
    study_date = c("2024-01-20", "2024-03-15"),
    modality = c("MRT", "MRT"),
    stringsAsFactors = FALSE
  )
  trauma <- c(SCI001 = "2024-01-15")

  result <- create_registry(meta, trauma)
  expect_equal(result$days_post_trauma, c(5L, 60L))
  expect_true(all(c("phase", "trauma_date") %in% names(result)))
})

test_that("coverage_matrix produces wide format", {
  reg <- data.frame(
    pat_id = c("A", "A", "B"),
    session = c("s1", "s2", "s1"),
    modality = c("MRT", "CT", "MRT")
  )
  cm <- coverage_matrix(reg)
  expect_equal(nrow(cm), 2)
  expect_true("s1" %in% names(cm))
  expect_true("s2" %in% names(cm))
})

# --- additional branch coverage ---

test_that("create_registry reads from a CSV path", {
  dir <- withr::local_tempdir()
  meta_csv <- file.path(dir, "meta.csv")
  readr::write_csv(data.frame(
    pat_id = "SCI001", session = "ses-01",
    study_date = "2024-01-20", modality = "MRT"
  ), meta_csv)
  reg <- create_registry(meta_csv, c(SCI001 = "2024-01-15"))
  expect_equal(reg$days_post_trauma, 5L)
})

test_that("create_registry errors on missing required columns", {
  expect_error(
    create_registry(data.frame(pat_id = "A"), c(A = "2024-01-01")),
    "missing columns"
  )
})

test_that("create_registry adds op-date fields when op_dates supplied", {
  meta <- data.frame(
    pat_id = "SCI001", session = "ses-01",
    study_date = "2024-01-25", modality = "MRT", stringsAsFactors = FALSE
  )
  reg <- create_registry(meta, c(SCI001 = "2024-01-15"),
                         op_dates = c(SCI001 = "2024-01-18"))
  expect_true(all(c("op_date", "days_post_op") %in% names(reg)))
  expect_equal(reg$days_post_op, 7L)
})

test_that("create_registry writes to output_csv when requested", {
  dir <- withr::local_tempdir()
  out <- file.path(dir, "nested", "registry.csv")
  meta <- data.frame(
    pat_id = "SCI001", session = "ses-01",
    study_date = "2024-01-20", modality = "MRT", stringsAsFactors = FALSE
  )
  reg <- create_registry(meta, c(SCI001 = "2024-01-15"), output_csv = out)
  expect_true(file.exists(out))
})

test_that("validate_registry reads from a CSV path", {
  reg_csv <- system.file("extdata", "example_registry.csv", package = "scimagR")
  expect_invisible(validate_registry(reg_csv, strict = FALSE))
})

test_that("validate_registry on the bundled fixture passes", {
  reg_csv <- system.file("extdata", "example_registry.csv", package = "scimagR")
  reg <- suppressMessages(readr::read_csv(reg_csv, show_col_types = FALSE))
  expect_message(validate_registry(reg), "validation passed")
})

test_that("validate_registry warns rather than aborts when strict = FALSE", {
  bad <- data.frame(pat_id = "A", session = "s1",
                    study_date = "2024-01-01", modality = "PET")
  expect_warning(validate_registry(bad, strict = FALSE), "Invalid modality")
})

test_that("create_registry output is stable (snapshot)", {
  meta <- data.frame(
    pat_id = c("SCI001", "SCI001"),
    session = c("ses-01", "ses-02"),
    study_date = c("2024-01-20", "2024-03-15"),
    modality = c("MRT", "MRT"),
    stringsAsFactors = FALSE
  )
  reg <- create_registry(meta, c(SCI001 = "2024-01-15"))
  expect_snapshot_value(
    list(
      days = reg$days_post_trauma,
      phase = as.character(reg$phase),
      cols = names(reg)
    ),
    style = "json2"
  )
})
