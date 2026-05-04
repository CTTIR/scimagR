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
#' @param args Character vector. Arguments to pass.
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
