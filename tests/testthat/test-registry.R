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
