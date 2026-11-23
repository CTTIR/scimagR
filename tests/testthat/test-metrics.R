# Tests for metrics functions

# --- compute_mscc() ---

test_that("compute_mscc returns correct percentage", {
  # di=5, da=10, db=10 -> ref=10, MSCC = (1 - 5/10) * 100 = 50
  expect_equal(compute_mscc(5, 10, 10), 50)
})

test_that("compute_mscc handles full compression", {
  # di=0 -> MSCC = 100%
  expect_equal(compute_mscc(0, 8, 8), 100)
})

test_that("compute_mscc handles no compression", {
  # di=ref -> MSCC = 0%
  expect_equal(compute_mscc(8, 8, 8), 0)
})

test_that("compute_mscc handles asymmetric references", {
  # da=8.1, db=8.5 -> ref=8.3, di=5.2
  # MSCC = (1 - 5.2/8.3) * 100 ≈ 37.35
  result <- compute_mscc(5.2, 8.1, 8.5)
  expect_equal(round(result, 2), 37.35)
})

test_that("compute_mscc handles NA inputs", {
  expect_true(is.na(compute_mscc(NA, 10, 10)))
  expect_true(is.na(compute_mscc(5, NA, 10)))
  expect_true(is.na(compute_mscc(5, 10, NA)))
})

test_that("compute_mscc handles zero reference", {
  expect_true(is.na(compute_mscc(5, 0, 0)))
})

# --- compute_compression_ratio() ---

test_that("compute_compression_ratio returns correct value", {
  expect_equal(compute_compression_ratio(6, 12), 0.5)
})

test_that("compute_compression_ratio handles NA", {
  expect_true(is.na(compute_compression_ratio(NA, 12)))
  expect_true(is.na(compute_compression_ratio(6, NA)))
})

test_that("compute_compression_ratio handles zero transverse", {
  expect_true(is.na(compute_compression_ratio(6, 0)))
})

# --- compute_csa_ratio() ---

test_that("compute_csa_ratio returns correct value", {
  # csa_injury=45, ref=(70+72)/2=71, ratio=45/71
  expect_equal(round(compute_csa_ratio(45, 70, 72), 4), round(45 / 71, 4))
})

test_that("compute_csa_ratio handles NA", {
  expect_true(is.na(compute_csa_ratio(NA, 70, 72)))
  expect_true(is.na(compute_csa_ratio(45, NA, 72)))
  expect_true(is.na(compute_csa_ratio(45, 70, NA)))
})

test_that("compute_csa_ratio handles zero reference", {
  expect_true(is.na(compute_csa_ratio(45, 0, 0)))
})

# --- classify_phase() ---

test_that("classify_phase returns correct levels at boundaries", {
  result <- classify_phase(c(0, 1, 2, 14, 15, 90, 91, 365, 366))
  expect_equal(
    as.character(result),
    c("hyperacute", "hyperacute", "acute", "acute",
      "subacute", "subacute", "intermediate", "intermediate", "chronic")
  )
  expect_true(is.ordered(result))
})

test_that("classify_phase handles NA", {
  result <- classify_phase(c(5, NA, 100))
  expect_equal(as.character(result), c("acute", NA, "intermediate"))
})

test_that("classify_phase returns 5 levels", {
  result <- classify_phase(c(0, 5, 30, 200, 400))
  expect_equal(nlevels(result), 5)
})

# --- classify_artifact() ---

test_that("classify_artifact maps grades correctly", {
  result <- classify_artifact(0:4)
  expect_equal(
    as.character(result),
    c("none", "mild", "moderate", "severe", "non-evaluable")
  )
  expect_true(is.ordered(result))
})

test_that("classify_artifact warns on out-of-range", {
  expect_warning(classify_artifact(c(0, 5, -1)), "outside 0-4")
})

test_that("classify_artifact handles NA", {
  result <- classify_artifact(c(0, NA, 2))
  expect_equal(as.character(result), c("none", NA, "moderate"))
})

# --- vectorisation (regression: scalar-only `if` failed on vectors) ---

test_that("metric functions are vectorised with element-wise NA handling", {
  expect_equal(compute_mscc(c(5, 0, NA, 4), c(10, 8, 8, 0), c(10, 8, 8, 0)),
               c(50, 100, NA, NA))
  expect_equal(compute_compression_ratio(c(6, 6, NA), c(12, 0, 10)),
               c(0.5, NA, NA))
  expect_equal(compute_csa_ratio(c(45, 60), c(70, 0), c(72, 0)),
               c(45 / 71, NA))
  # recycling of scalar references
  expect_equal(compute_mscc(c(4, 6), 8, 8), c(50, 25))
  expect_equal(compute_mscc(numeric(), 8, 8), numeric())
})

test_that("metric functions work inside dplyr::mutate()", {
  df <- data.frame(di = c(5, 6), da = c(8, 8), db = c(8, 9))
  out <- dplyr::mutate(df, mscc = compute_mscc(di, da, db))
  expect_equal(out$mscc, (1 - df$di / ((df$da + df$db) / 2)) * 100)
})

test_that("metric functions reject non-numeric input", {
  expect_error(compute_mscc("5", 8, 8), class = "scimagR_error_input")
  expect_error(compute_compression_ratio(6, "12"),
               class = "scimagR_error_input")
  expect_error(compute_csa_ratio(45, 70, list(72)),
               class = "scimagR_error_input")
  expect_true(is.na(compute_mscc(NA, NA, NA)))
})

test_that("classify_phase sets negative days to NA with a warning", {
  expect_warning(res <- classify_phase(c(-3, 0, 20)), "Negative days")
  expect_equal(as.character(res), c(NA, "hyperacute", "subacute"))
  expect_error(classify_phase("5"), class = "scimagR_error_input")
  expect_equal(as.character(classify_phase(NA)), NA_character_)
})

test_that("classify_artifact rejects fractional grades and non-numeric input", {
  expect_warning(res <- classify_artifact(c(1, 1.5, 2)), "whole numbers")
  expect_equal(as.character(res), c("mild", NA, "moderate"))
  expect_error(classify_artifact("2"), class = "scimagR_error_input")
})

test_that("metric functions reject lengths that cannot be recycled", {
  # Regression: base recycling paired a length-4 vector with a length-2
  # vector without any warning, silently mixing up measurements.
  expect_error(compute_mscc(c(4, 5, 6, 7), c(8, 9), 8),
               class = "scimagR_error_input")
  expect_error(compute_mscc(c(1, 2, 3), c(8, 8), 8),
               class = "scimagR_error_input")
  expect_error(compute_compression_ratio(c(6, 7, 8, 9), c(12, 11)),
               class = "scimagR_error_input")
  expect_error(compute_csa_ratio(numeric(), c(70, 71), 72),
               class = "scimagR_error_input")
  # Length-1 arguments are still recycled
  expect_equal(compute_mscc(c(4, 6), 8, c(8, 8)), c(50, 25))
  expect_equal(compute_csa_ratio(c(35, 70), 70, 70), c(0.5, 1))
  expect_equal(compute_compression_ratio(numeric(), 12), numeric())
})
