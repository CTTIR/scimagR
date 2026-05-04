# Tests for QC functions

test_that("create_qc_log returns empty tibble with correct columns", {
  qc <- create_qc_log()
  expect_equal(nrow(qc), 0)
  expect_true(all(c("pat_id", "session", "rater", "date", "seg_type", "quality", "notes") %in% names(qc)))
})

test_that("update_qc_log appends entries", {
  qc <- create_qc_log()
  entry <- tibble::tibble(
    pat_id = "SCI001", session = "ses-01", rater = "RH",
    date = Sys.Date(), seg_type = "sc", quality = "good", notes = ""
  )
  updated <- update_qc_log(qc, entry)
  expect_equal(nrow(updated), 1)
  expect_equal(updated$pat_id, "SCI001")
})

test_that("validate_qc_log detects missing columns", {
  bad_df <- data.frame(pat_id = "A")
  expect_error(validate_qc_log(bad_df), "missing columns")
})

test_that("validate_qc_log warns on invalid quality values", {
  qc <- data.frame(
    pat_id = "A", session = "s1",
    seg_type = "sc", quality = "excellent"
  )
  expect_warning(validate_qc_log(qc), "Invalid quality")
})

test_that("filter_evaluable filters by artifact grade", {
  df <- data.frame(
    artifact_grade = c(0, 1, 2, 3, 4),
    modality = rep("MRT", 5)
  )
  result <- filter_evaluable(df, max_artifact = 2, verbose = FALSE)
  expect_equal(nrow(result), 3)
})

test_that("filter_evaluable filters by modality", {
  df <- data.frame(
    artifact_grade = rep(0, 3),
    modality = c("MRT", "CT", "CT+MRT")
  )
  result <- filter_evaluable(df, modalities = c("MRT", "CT+MRT"), verbose = FALSE)
  expect_equal(nrow(result), 2)
})

test_that("log_exclusion returns correct structure", {
  entry <- log_exclusion("Test filter", 100, 85, "testing")
  expect_equal(entry$n_excluded, 15L)
  expect_equal(entry$step, "Test filter")
  expect_equal(nrow(entry), 1)
})
