#' Extract Lesion Parameters
#'
#' Runs `sct_analyze_lesion` to compute lesion volume, length, maximum axial
#' damage ratio and tissue bridge measurements. SCT writes the results to a
#' spreadsheet named after the lesion mask: `<lesion_seg>_analysis.xlsx`
#' (SCT 7.0 and later) or `<lesion_seg>_analysis.xls` (earlier versions).
#'
#' @param lesion_seg Character. Path to lesion segmentation NIfTI.
#' @param sc_seg Character. Path to spinal cord segmentation NIfTI.
#' @param output_dir Character. Directory for the output files. Defaults to
#'   the directory of `lesion_seg`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Character. Path to the analysis spreadsheet written by SCT, or
#'   `NA` on failure (non-zero exit status, or no spreadsheet written).
#' @export
#' @examples
#' # Inputs are checked before SCT is called:
#' try(sct_analyze_lesion("missing_lesion_seg.nii.gz", "missing_seg.nii.gz"))
#'
#' \donttest{
#' # With SCT installed: analyse your own lesion and cord masks, for example
#' # those written by sct_segment_lesion().
#' lesion <- "sub-01_T2w_lesion_seg.nii.gz"
#' cord <- "sub-01_T2w_sc_seg.nii.gz"
#' if (check_sct(verbose = FALSE)$available &&
#'     file.exists(lesion) && file.exists(cord)) {
#'   sct_analyze_lesion(lesion, cord, output_dir = tempdir())
#' }
#' }
sct_analyze_lesion <- function(lesion_seg,
                               sc_seg,
                               output_dir = NULL,
                               verbose = TRUE) {
  rlang::check_required(lesion_seg)
  rlang::check_required(sc_seg)

  if (!file.exists(lesion_seg)) {
    cli::cli_abort("Lesion segmentation not found: {.path {lesion_seg}}")
  }
  if (!file.exists(sc_seg)) {
    cli::cli_abort("SC segmentation not found: {.path {sc_seg}}")
  }

  dir_out <- output_dir %||% dirname(lesion_seg)

  args <- c(
    "-m", lesion_seg,
    "-s", sc_seg,
    "-ofolder", dir_out
  )

  result <- sct_run("sct_analyze_lesion", args = args, verbose = verbose)

  if (result$exit_code != 0L) {
    return(NA_character_)
  }

  base <- file.path(dir_out, paste0(nii_stem(basename(lesion_seg)), "_analysis"))
  candidates <- paste0(base, c(".xlsx", ".xls"))
  found <- candidates[file.exists(candidates)]
  if (length(found) == 0L) {
    sct_output_exists(candidates[[1L]], "sct_analyze_lesion")
    return(NA_character_)
  }
  output <- found[[1L]]

  if (verbose) cli::cli_alert_success("Lesion analysis saved: {.path {output}}")
  output
}

#' Extract Morphometric Parameters
#'
#' Runs `sct_process_segmentation` to compute cross-sectional area (CSA),
#' AP diameter, transverse diameter and other shape metrics of the spinal
#' cord. By default SCT averages the metrics over all slices of the
#' segmentation (the `VertLevel` column of the CSV lists the vertebral
#' levels covered). Use `vert` to restrict the average to vertebral levels,
#' and `perlevel = TRUE` to get one row per level.
#'
#' @param sc_seg Character. Path to spinal cord segmentation NIfTI.
#' @param vert_labels Character. Path to the vertebral level file, i.e. the
#'   labelled segmentation returned by [sct_label_vertebrae()].
#' @param output_dir Character. Directory for CSV output. Defaults to the
#'   directory of `sc_seg`.
#' @param perslice Logical. Compute per-slice metrics. Default `FALSE`.
#' @param vert Vertebral levels to aggregate over, as a numeric vector
#'   (e.g. `2:7` for C2 to C7) or a character string in SCT syntax
#'   (e.g. `"2:7"`). Default `NULL` (all slices).
#' @param perlevel Logical. One row per vertebral level in `vert`. Needs
#'   `vert`. Default `FALSE`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Character. Path to output CSV (`<sc_seg>_csa.csv`), or `NA` on
#'   failure (non-zero exit status, or no CSV written).
#' @export
#' @examples
#' # Inputs are checked before SCT is called:
#' try(sct_process_segmentation("missing_seg.nii.gz", "missing_labeled.nii.gz"))
#'
#' \donttest{
#' # With SCT installed: CSA per vertebral level of the PAM50 template cord.
#' sct <- check_sct(verbose = FALSE)
#' if (sct$available) {
#'   pam50 <- file.path(dirname(dirname(sct$path)), "data", "PAM50",
#'                      "template")
#'   cord <- file.path(pam50, "PAM50_cord.nii.gz")
#'   levels <- file.path(pam50, "PAM50_levels.nii.gz")
#'   if (file.exists(cord) && file.exists(levels)) {
#'     csv <- sct_process_segmentation(cord, levels, output_dir = tempdir(),
#'                                     vert = 2:4, perlevel = TRUE)
#'     if (!is.na(csv)) utils::read.csv(csv, check.names = FALSE)
#'   }
#' }
#' }
sct_process_segmentation <- function(sc_seg,
                                     vert_labels,
                                     output_dir = NULL,
                                     perslice = FALSE,
                                     verbose = TRUE,
                                     vert = NULL,
                                     perlevel = FALSE) {
  rlang::check_required(sc_seg)
  rlang::check_required(vert_labels)

  if (!file.exists(sc_seg)) {
    cli::cli_abort("SC segmentation not found: {.path {sc_seg}}")
  }
  if (!file.exists(vert_labels)) {
    cli::cli_abort("Vertebral labels not found: {.path {vert_labels}}")
  }
  if (isTRUE(perlevel) && is.null(vert)) {
    cli::cli_abort(
      "{.code perlevel = TRUE} needs the vertebral levels in {.arg vert}.",
      class = "scimagR_error_input"
    )
  }

  dir_out <- output_dir %||% dirname(sc_seg)
  output_csv <- file.path(dir_out, paste0(nii_stem(basename(sc_seg)), "_csa.csv"))

  args <- c(
    "-i", sc_seg,
    "-vertfile", vert_labels,
    "-o", output_csv
  )

  if (!is.null(vert)) {
    args <- c(args, "-vert", format_vert_levels(vert))
  }
  if (isTRUE(perlevel)) {
    args <- c(args, "-perlevel", "1")
  }
  if (perslice) {
    args <- c(args, "-perslice", "1")
  }

  result <- sct_run("sct_process_segmentation", args = args, verbose = verbose)

  if (result$exit_code != 0L ||
      !sct_output_exists(output_csv, "sct_process_segmentation")) {
    return(NA_character_)
  }

  if (verbose) cli::cli_alert_success("CSA metrics saved: {.path {output_csv}}")
  output_csv
}

# Format vertebral levels for SCT's `-vert`: a run of consecutive integers
# becomes "a:b", other integer vectors "a,b,c"; strings pass through.
format_vert_levels <- function(vert, call = rlang::caller_env()) {
  if (is.character(vert) && length(vert) == 1L && !is.na(vert)) {
    return(vert)
  }
  if (!is.numeric(vert) || length(vert) == 0L || anyNA(vert) ||
      any(vert != round(vert))) {
    cli::cli_abort(
      "{.arg vert} must be whole numbers (e.g. {.code 2:7}) or a string such as {.str 2:7}.",
      class = "scimagR_error_input",
      call = call
    )
  }
  vert <- as.integer(vert)
  if (length(vert) > 1L && all(diff(vert) == 1L)) {
    return(paste0(vert[[1L]], ":", vert[[length(vert)]]))
  }
  paste(vert, collapse = ",")
}
