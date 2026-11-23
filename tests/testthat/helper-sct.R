# Helpers for the SCT wrapper tests. SCT itself is never called: `sct_run()`
# is replaced by a stub that records its arguments and creates the files the
# real SCT command would write (see the SCT sources of versions 6.4 and 7.3).

# Value following a flag in an argument vector.
arg_value <- function(args, flag) {
  i <- match(flag, args)
  if (is.na(i)) NA_character_ else args[[i + 1L]]
}

# Files written by the SCT commands the package wraps, for the given args.
sct_outputs <- function(cmd, args) {
  stem <- function(x) sub("\\.nii(\\.gz)?$", "", x)
  ext <- function(x) regmatches(x, regexpr("\\.nii(\\.gz)?$", x))
  switch(cmd,
    sct_deepseg = {
      o <- arg_value(args, "-o")
      if (any(args %in% c("lesion_sci_t2", "seg_sc_lesion_t2w_sci"))) {
        paste0(stem(o), c("_lesion_seg", "_sc_seg"), ext(o))
      } else {
        o
      }
    },
    sct_label_vertebrae = {
      s <- arg_value(args, "-s")
      file.path(
        arg_value(args, "-ofolder"),
        paste0(stem(basename(s)), c("_labeled", "_labeled_discs"), ext(s))
      )
    },
    sct_analyze_lesion = {
      m <- arg_value(args, "-m")
      file.path(
        arg_value(args, "-ofolder"),
        paste0(stem(basename(m)), "_analysis.xlsx")
      )
    },
    sct_process_segmentation = arg_value(args, "-o"),
    character()
  )
}

# Replace sct_run() (and the SCT version lookup) for the calling test.
# Returns an environment whose `calls` holds list(cmd, args) per call.
local_fake_sct <- function(exit_code = 0L, write = TRUE, major = 7L,
                           env = parent.frame()) {
  rec <- new.env()
  rec$calls <- list()
  testthat::local_mocked_bindings(
    sct_run = function(cmd, args = character(), ...) {
      rec$calls[[length(rec$calls) + 1L]] <- list(cmd = cmd, args = args)
      if (exit_code == 0L && write) {
        for (f in sct_outputs(cmd, args)) {
          dir.create(dirname(f), recursive = TRUE, showWarnings = FALSE)
          file.create(f)
        }
      }
      list(exit_code = exit_code, stdout = character(), stderr = character(),
           cmd = cmd)
    },
    sct_major_version = function() major,
    .env = env
  )
  rec
}

# Create empty placeholder files and return their paths.
touch <- function(...) {
  paths <- c(...)
  for (p in paths) {
    dir.create(dirname(p), recursive = TRUE, showWarnings = FALSE)
    file.create(p)
  }
  invisible(paths)
}
