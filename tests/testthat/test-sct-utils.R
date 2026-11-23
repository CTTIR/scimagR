# Tests for internal SCT helpers (sct-utils.R)

# R CMD check prepends <check dir>/R_check_bin to PATH. Its Rscript shim only
# prints "'Rscript' should not be used without a path" and exits 1, so
# Sys.which("Rscript") cannot be used to launch a nested R. Use the real binary.
real_rscript <- function() {
  exe <- if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
  normalizePath(file.path(R.home("bin"), exe), winslash = "/", mustWork = FALSE)
}

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
  fake_exe <- real_rscript()
  skip_if(!file.exists(fake_exe), "Rscript not resolvable")
  # R CMD check sets R_TESTS, which a nested Rscript inherits and then fails
  # to source, exiting 1 before it runs anything. Clear it for the subprocess.
  withr::local_envvar(R_TESTS = "")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  res <- sct_run("sct_version", args = c("-e", "cat('hi')"),
                 verbose = FALSE)
  expect_type(res, "list")
  expect_named(res, c("exit_code", "stdout", "stderr", "cmd"))
  expect_equal(res$exit_code, 0L)
})

test_that("sct_run warns and reports a non-zero exit code", {
  fake_exe <- real_rscript()
  skip_if(!file.exists(fake_exe), "Rscript not resolvable")
  # R CMD check sets R_TESTS, which a nested Rscript inherits and then fails
  # to source, exiting 1 before it runs anything. Clear it for the subprocess.
  withr::local_envvar(R_TESTS = "")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  expect_warning(
    res <- sct_run("sct_version", args = c("-e", "quit(status=3)"),
                   verbose = FALSE),
    "failed"
  )
  expect_true(res$exit_code != 0L)
})

test_that("sct_run prints the command when verbose", {
  fake_exe <- real_rscript()
  skip_if(!file.exists(fake_exe), "Rscript not resolvable")
  # R CMD check sets R_TESTS, which a nested Rscript inherits and then fails
  # to source, exiting 1 before it runs anything. Clear it for the subprocess.
  withr::local_envvar(R_TESTS = "")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  expect_message(
    sct_run("sct_version", args = c("-e", "cat(1)"), verbose = TRUE),
    "Running"
  )
})

test_that("sct_run quotes arguments so paths with spaces stay intact", {
  fake_exe <- real_rscript()
  skip_if(!file.exists(fake_exe), "Rscript not resolvable")
  withr::local_envvar(R_TESTS = "")
  local_mocked_bindings(sct_find_executable = function(cmd) fake_exe)
  dir <- withr::local_tempdir()
  spaced <- file.path(dir, "a folder", "img 1.nii.gz")
  res <- sct_run("sct_version",
                 args = c("-e", "cat(commandArgs(TRUE))", spaced),
                 verbose = FALSE)
  expect_equal(res$exit_code, 0L)
  expect_equal(res$stdout, spaced)
})

test_that("parse_sct_major reads package versions and rejects git builds", {
  expect_equal(parse_sct_major("7.3"), 7L)
  expect_equal(parse_sct_major(c("", "6.4")), 6L)
  expect_equal(parse_sct_major(" 10.0\n"), 10L)
  expect_true(is.na(parse_sct_major("git-master-abc123")))
  expect_true(is.na(parse_sct_major(character())))
})

test_that("sct_deepseg_task_args follows the SCT version", {
  expect_equal(sct_deepseg_task_args("spinalcord", major = 7L), "spinalcord")
  expect_equal(sct_deepseg_task_args("lesion_sci_t2", major = 8L),
               "lesion_sci_t2")
  expect_equal(sct_deepseg_task_args("spinalcord", major = 6L),
               c("-task", "seg_sc_contrast_agnostic"))
  expect_equal(sct_deepseg_task_args("lesion_sci_t2", major = 6L),
               c("-task", "seg_sc_lesion_t2w_sci"))
  # Unknown version (git installation): current syntax
  expect_equal(sct_deepseg_task_args("spinalcord", major = NA_integer_),
               "spinalcord")
})

test_that("sct_major_version is NA without SCT and caches per executable", {
  local_mocked_bindings(sct_find_executable = function(cmd) "")
  expect_true(is.na(sct_major_version()))

  fake_exe <- real_rscript()
  skip_if(!file.exists(fake_exe), "Rscript not resolvable")
  withr::defer(rm(list = ls(.sct_cache), envir = .sct_cache))
  local_mocked_bindings(sct_find_executable = function(cmd) "/fake/sct_version")
  assign("/fake/sct_version", 6L, envir = .sct_cache)
  expect_equal(sct_major_version(), 6L)
})

test_that("nii_stem and nii_ext split NIfTI file names", {
  expect_equal(nii_stem("a/b_seg.nii.gz"), "a/b_seg")
  expect_equal(nii_stem("b.nii"), "b")
  expect_equal(nii_ext(c("x.nii.gz", "x.nii", "x.img")), c(".nii.gz", ".nii", ""))
})

test_that("sct_major_version reads the output of sct_version", {
  skip_on_os("windows")
  dir <- withr::local_tempdir()
  exe <- file.path(dir, "sct_version")
  writeLines(c("#!/bin/sh", "echo 7.3"), exe)
  Sys.chmod(exe, "755")
  withr::defer(rm(list = ls(.sct_cache), envir = .sct_cache))
  local_mocked_bindings(sct_find_executable = function(cmd) exe)
  expect_equal(sct_major_version(), 7L)
  expect_equal(get(exe, envir = .sct_cache), 7L)
})
