#' Find SCT Executable Path
#'
#' Resolves the path to an SCT executable, checking `SCT_DIR` environment
#' variable first, then falling back to `Sys.which()`.
#'
#' @param cmd Character. The SCT command name (e.g., "sct_deepseg").
#' @return Character. Full path to the executable, or empty string if not found.
#' @keywords internal
sct_find_executable <- function(cmd) {
  sct_dir <- Sys.getenv("SCT_DIR", unset = "")
  if (nzchar(sct_dir)) {
    candidate <- file.path(sct_dir, "bin", cmd)
    if (file.exists(candidate)) {
      return(candidate)
    }
  }
  path <- Sys.which(cmd)
  unname(path)
}

#' Run an SCT Command
#'
#' Internal helper that executes an SCT command via `system2()`, captures
#' output, and returns a structured result list.
#'
#' @param cmd Character. Full SCT command name (e.g., "sct_deepseg").
#' @param args Character vector. Arguments to pass; each one is quoted with
#'   [shQuote()] before the command is run.
#' @param error_msg Character. Message on failure.
#' @param verbose Logical. Print command before running.
#' @return Named list with components: `exit_code`, `stdout`, `stderr`, `cmd`.
#' @keywords internal
sct_run <- function(cmd, args = character(), error_msg = NULL, verbose = TRUE) {
  exe <- sct_find_executable(cmd)
  if (!nzchar(exe)) {
    cli::cli_abort(c(
      "Cannot find {.cmd {cmd}} on PATH.",
      "i" = "Set the {.envvar SCT_DIR} environment variable or add SCT to your PATH.",
      "i" = "Install SCT from {.url https://spinalcordtoolbox.com}."
    ))
  }

  # Quote every argument so that paths with spaces reach SCT intact.
  args <- vapply(as.character(args), shQuote, character(1), USE.NAMES = FALSE)
  full_cmd <- paste(c(exe, args), collapse = " ")
  if (verbose) {
    cli::cli_inform("Running: {.code {full_cmd}}")
  }

  result <- tryCatch(
    {
      stdout_file <- tempfile("sct_stdout_")
      stderr_file <- tempfile("sct_stderr_")
      on.exit(unlink(c(stdout_file, stderr_file)), add = TRUE)

      exit_code <- system2(
        command = exe,
        args = args,
        stdout = stdout_file,
        stderr = stderr_file
      )

      list(
        exit_code = exit_code,
        stdout = readLines(stdout_file, warn = FALSE),
        stderr = readLines(stderr_file, warn = FALSE),
        cmd = full_cmd
      )
    },
    error = function(e) {
      list(
        exit_code = -1L,
        stdout = character(),
        stderr = conditionMessage(e),
        cmd = full_cmd
      )
    }
  )

  if (result$exit_code != 0L) {
    msg <- error_msg %||% glue::glue("Command failed: {cmd}")
    cli::cli_warn(c(
      msg,
      "x" = "Exit code: {result$exit_code}",
      "i" = "stderr: {paste(utils::tail(result$stderr, 5), collapse = '\\n')}"
    ))
  }

  result
}

# Cache of SCT major versions, keyed by the path of `sct_version`.
.sct_cache <- new.env(parent = emptyenv())

#' Major Version of the Installed SCT
#'
#' Runs `sct_version` once per executable path and caches the result.
#'
#' @return Integer major version (e.g. `7L`), or `NA_integer_` when SCT is
#'   not installed or reports no version number (git installations print
#'   `git-<branch>-<commit>`).
#' @keywords internal
#' @noRd
sct_major_version <- function() {
  exe <- sct_find_executable("sct_version")
  if (!nzchar(exe)) {
    return(NA_integer_)
  }
  cached <- .sct_cache[[exe]]
  if (!is.null(cached)) {
    return(cached)
  }
  out <- suppressWarnings(tryCatch(
    system2(exe, stdout = TRUE, stderr = TRUE),
    error = function(e) character()
  ))
  major <- parse_sct_major(out)
  assign(exe, major, envir = .sct_cache)
  major
}

# Parse the major version from `sct_version` output such as "6.4" or "7.3".
parse_sct_major <- function(x) {
  hit <- regmatches(x, regexpr("^[[:space:]]*[0-9]+\\.[0-9]+", x))
  if (length(hit) == 0L) {
    return(NA_integer_)
  }
  as.integer(sub("\\..*$", "", trimws(hit[[1L]])))
}

#' Task Arguments for `sct_deepseg`
#'
#' SCT 7.0 replaced `sct_deepseg -task <name>` with a positional task name
#' and renamed the tasks; SCT 7 prints a deprecation note and exits with
#' status 0 when it is given `-task`. This helper returns the arguments for
#' the installed version, using the SCT 7 form when the version is unknown.
#'
#' @param task Character. SCT 7 task name: `"spinalcord"` or
#'   `"lesion_sci_t2"`.
#' @param major Integer. SCT major version.
#' @return Character vector of arguments to put before the other options.
#' @keywords internal
#' @noRd
sct_deepseg_task_args <- function(task, major = sct_major_version()) {
  legacy <- c(
    spinalcord = "seg_sc_contrast_agnostic",
    lesion_sci_t2 = "seg_sc_lesion_t2w_sci"
  )
  if (!is.na(major) && major < 7L) {
    c("-task", legacy[[task]])
  } else {
    task
  }
}

# Strip a NIfTI extension (.nii or .nii.gz) from a file name.
nii_stem <- function(path) {
  sub("\\.nii(\\.gz)?$", "", path)
}

# NIfTI extension of a file name (".nii.gz", ".nii" or "").
nii_ext <- function(path) {
  ifelse(grepl("\\.nii\\.gz$", path), ".nii.gz",
    ifelse(grepl("\\.nii$", path), ".nii", "")
  )
}

# Warn and return FALSE when SCT exited with status 0 but did not write the
# file a wrapper expects.
sct_output_exists <- function(path, cmd) {
  if (file.exists(path)) {
    return(TRUE)
  }
  cli::cli_warn(c(
    "{.cmd {cmd}} finished but did not write {.path {path}}.",
    "i" = "Check the SCT version and the messages printed by {.cmd {cmd}}."
  ))
  FALSE
}
