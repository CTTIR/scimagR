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
