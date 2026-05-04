#' Segment Spinal Cord
#'
#' Runs SCT's contrast-agnostic spinal cord segmentation model.
#'
#' @param input Character. Path to NIfTI file (.nii.gz).
#' @param output Character. Path for output segmentation. Auto-generated if
#'   `NULL`.
#' @param output_dir Character. Directory for output. Alternative to `output`.
#' @param overwrite Logical. Re-run if output exists? Default `FALSE`
#'   (idempotent).
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @param qc_dir Character. If provided, auto-generate QC report.
#' @return Character. Path to output segmentation file, or `NA` on failure.
#' @export
#' @examples
#' \dontrun{
#' sct_segment_sc("sub-01_T2w.nii.gz")
#' }
sct_segment_sc <- function(input,
                           output = NULL,
                           output_dir = NULL,
                           overwrite = FALSE,
                           verbose = TRUE,
                           qc_dir = NULL) {
  rlang::check_required(input)
  stopifnot(is.character(input), length(input) == 1)

  if (!file.exists(input)) {
    cli::cli_abort("Input file not found: {.path {input}}")
  }

  if (is.null(output)) {
    dir_out <- output_dir %||% dirname(input)
    base <- sub("\\.nii(\\.gz)?$", "", basename(input))
    output <- file.path(dir_out, paste0(base, "_seg.nii.gz"))
  }

  if (file.exists(output) && !overwrite) {
    if (verbose) cli::cli_alert_info("Output exists, skipping: {.path {output}}")
    return(output)
  }

  args <- c(
    "-i", input,
    "-task", "seg_sc_contrast_agnostic",
    "-o", output
  )

  result <- sct_run("sct_deepseg", args = args, verbose = verbose)

  if (result$exit_code != 0L) {
    return(NA_character_)
  }

  if (!is.null(qc_dir)) {
    sct_generate_qc(input = input, segmentation = output, qc_dir = qc_dir)
  }

  if (verbose) cli::cli_alert_success("SC segmentation saved: {.path {output}}")
  output
}

#' Segment SCI Lesion
#'
#' Runs SCIsegV2 lesion segmentation model via SCT.
#'
#' @param input Character. Path to T2w NIfTI file (.nii.gz).
#' @param output Character. Path for output segmentation. Auto-generated if
#'   `NULL`.
#' @param output_dir Character. Directory for output. Alternative to `output`.
#' @param overwrite Logical. Re-run if output exists? Default `FALSE`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @param qc_dir Character. If provided, auto-generate QC report.
#' @return Character. Path to output lesion segmentation, or `NA` on failure.
#' @export
#' @examples
#' \dontrun{
#' sct_segment_lesion("sub-01_T2w.nii.gz")
#' }
sct_segment_lesion <- function(input,
                               output = NULL,
                               output_dir = NULL,
                               overwrite = FALSE,
                               verbose = TRUE,
                               qc_dir = NULL) {
  rlang::check_required(input)
  stopifnot(is.character(input), length(input) == 1)

  if (!file.exists(input)) {
    cli::cli_abort("Input file not found: {.path {input}}")
  }

  if (is.null(output)) {
    dir_out <- output_dir %||% dirname(input)
    base <- sub("\\.nii(\\.gz)?$", "", basename(input))
    output <- file.path(dir_out, paste0(base, "_lesion_seg.nii.gz"))
  }

  if (file.exists(output) && !overwrite) {
    if (verbose) cli::cli_alert_info("Output exists, skipping: {.path {output}}")
    return(output)
  }

  args <- c(
    "-i", input,
    "-task", "seg_sc_lesion_t2w_sci",
    "-o", output
  )

  result <- sct_run("sct_deepseg", args = args, verbose = verbose)

  if (result$exit_code != 0L) {
    return(NA_character_)
  }

  if (!is.null(qc_dir)) {
    sct_generate_qc(
      input = input, segmentation = output, qc_dir = qc_dir,
      process = "sct_deepseg_lesion"
    )
  }

  if (verbose) cli::cli_alert_success("Lesion segmentation saved: {.path {output}}")
  output
}
