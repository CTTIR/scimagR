# Tests for internal SCT helpers (sct-utils.R)

test_that("sct_find_executable returns empty string for unknown command", {
  withr::local_envvar(SCT_DIR = "")
  expect_identical(sct_find_executable("definitely_not_a_real_cmd_xyz"), "")
})

test_that("sct_find_executable prefers SCT_DIR/bin when the file exists", {
  sct_dir <- withr::local_tempdir()
  bin <- file.path(sct_dir, "bin")
  dir.create(bin, recursive = TRUE)
  fake <- file.path(bin, "sct_fake")
  file.create(fake)
  withr::local_envvar(SCT_DIR = sct_dir)
  expect_equal(sct_find_executable("sct_fake"), fake)
})

test_that("sct_find_executable falls back to Sys.which when SCT_DIR misses", {
  sct_dir <- withr::local_tempdir() # has no bin/cmd
  withr::local_envvar(SCT_DIR = sct_dir)
  # Unknown command -> Sys.which returns "" -> unname("") == ""
  expect_identical(sct_find_executable("still_not_real_cmd"), "")
})

test_that("sct_run aborts when the executable cannot be found", {
  local_mocked_bindings(sct_find_executable = function(cmd) "")
  expect_error(sct_run("sct_deepseg", verbose = FALSE), "Cannot find")
})

test_that("sct_run captures a successful run via a stub executable", {
  # Mock the resolver to point at a tiny shell-agnostic R script runner is
  # hard cross-platform; instead mock the resolver and rely on system2 of a
  # known always-present command. We mock to an echo-like call.
  fake_exe <- normalizePath(Sys.which("Rscript")[[1]], winslash = "/", mustWork = FALSE)
  skip_if(!nzchar(fake_exe), "Rscript not resolvable")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  res <- sct_run("sct_version", args = c("-e", shQuote("cat('hi')")),
                 verbose = FALSE)
  expect_type(res, "list")
  expect_named(res, c("exit_code", "stdout", "stderr", "cmd"))
  expect_equal(res$exit_code, 0L)
})

test_that("sct_run warns and reports a non-zero exit code", {
  fake_exe <- normalizePath(Sys.which("Rscript")[[1]], winslash = "/", mustWork = FALSE)
  skip_if(!nzchar(fake_exe), "Rscript not resolvable")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  expect_warning(
    res <- sct_run("sct_version", args = c("-e", shQuote("quit(status=3)")),
                   verbose = FALSE),
    "failed"
  )
  expect_true(res$exit_code != 0L)
})

test_that("sct_run prints the command when verbose", {
  fake_exe <- normalizePath(Sys.which("Rscript")[[1]], winslash = "/", mustWork = FALSE)
  skip_if(!nzchar(fake_exe), "Rscript not resolvable")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  expect_message(
    sct_run("sct_version", args = c("-e", shQuote("cat(1)")), verbose = TRUE),
    "Running"
  )
})
