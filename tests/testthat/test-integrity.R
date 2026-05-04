# Tests for integrity_summary

test_that("integrity_summary returns df invisibly", {
  df <- data.frame(a = 1:3, b = c(NA, 2, 3))
  result <- integrity_summary(df)
  expect_equal(nrow(result), 3)
})

test_that("integrity_summary detects NAs", {
  df <- data.frame(a = c(1, NA, 3), b = c(NA, NA, 3))
  expect_message(integrity_summary(df), "a:")
})

test_that("integrity_summary detects duplicates", {
  df <- data.frame(id = c("A", "A", "B"), val = 1:3)
  expect_message(integrity_summary(df, id_cols = "id"), "duplicate")
})

test_that("integrity_summary reports no duplicates", {
  df <- data.frame(id = c("A", "B", "C"), val = 1:3)
  expect_message(integrity_summary(df, id_cols = "id"), "No duplicates")
})
