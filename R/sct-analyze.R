#' Extract Lesion Parameters
#'
#' Runs `sct_analyze_lesion` to compute lesion volume, length, max axial
#' damage ratio, and tissue bridge measurements.
#'
#' @param lesion_seg Character. Path to lesion segmentation NIfTI.
#' @param sc_seg Character. Path to spinal cord segmentation NIfTI.
#' @param output_dir Character. Directory for CSV output.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Character. Path to output CSV, or `NA` on failure.
#' @export
#' @examples
#' \dontrun{
#' sct_analyze_lesion("sub-01_lesion_seg.nii.gz", "sub-01_seg.nii.gz")
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

  base <- sub("\\.nii(\\.gz)?$", "", basename(lesion_seg))
  output_csv <- file.path(dir_out, paste0(base, "_analysis.csv"))

  if (verbose) cli::cli_alert_success("Lesion analysis saved: {.path {output_csv}}")
  output_csv
}

#' Extract Morphometric Parameters
#'
#' Runs `sct_process_segmentation` to compute cross-sectional area (CSA),
#' AP diameter, and transverse diameter per vertebral level.
#'
#' @param sc_seg Character. Path to spinal cord segmentation NIfTI.
#' @param vert_labels Character. Path to vertebral labels NIfTI.
#' @param output_dir Character. Directory for CSV output.
#' @param perslice Logical. Compute per-slice metrics. Default `FALSE`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Character. Path to output CSV, or `NA` on failure.
#' @export
#' @examples
#' \dontrun{
#' sct_process_segmentation("sub-01_seg.nii.gz", "sub-01_labels-disc.nii.gz")
#' }
sct_process_segmentation <- function(sc_seg,
                                     vert_labels,
                                     output_dir = NULL,
                                     perslice = FALSE,
                                     verbose = TRUE) {
  rlang::check_required(sc_seg)
  rlang::check_required(vert_labels)

  if (!file.exists(sc_seg)) {
    cli::cli_abort("SC segmentation not found: {.path {sc_seg}}")
  }
  if (!file.exists(vert_labels)) {
    cli::cli_abort("Vertebral labels not found: {.path {vert_labels}}")
  }

  dir_out <- output_dir %||% dirname(sc_seg)
  base <- sub("\\.nii(\\.gz)?$", "", basename(sc_seg))
  output_csv <- file.path(dir_out, paste0(base, "_csa.csv"))

  args <- c(
    "-i", sc_seg,
    "-vertfile", vert_labels,
    "-o", output_csv
  )

  if (perslice) {
    args <- c(args, "-perslice", "1")
  }

  result <- sct_run("sct_process_segmentation", args = args, verbose = verbose)

  if (result$exit_code != 0L) {
    return(NA_character_)
  }

  if (verbose) cli::cli_alert_success("CSA metrics saved: {.path {output_csv}}")
  output_csv
}
