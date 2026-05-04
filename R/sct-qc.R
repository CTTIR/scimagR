#' Generate SCT Quality Control Report
#'
#' Creates an HTML QC report overlaying a segmentation on the original image.
#'
#' @param input Character. Path to original NIfTI image.
#' @param segmentation Character. Path to segmentation overlay.
#' @param qc_dir Character. Directory for QC HTML output.
#' @param process Character. SCT process name for labeling.
#'   Default `"sct_deepseg"`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Exit code (invisible).
#' @export
#' @examples
#' \dontrun{
#' sct_generate_qc("sub-01_T2w.nii.gz", "sub-01_T2w_seg.nii.gz", "qc/")
#' }
sct_generate_qc <- function(input,
                            segmentation,
                            qc_dir,
                            process = "sct_deepseg",
                            verbose = TRUE) {
  rlang::check_required(input)
  rlang::check_required(segmentation)
  rlang::check_required(qc_dir)

  if (!file.exists(input)) {
    cli::cli_abort("Input file not found: {.path {input}}")
  }
  if (!file.exists(segmentation)) {
    cli::cli_abort("Segmentation file not found: {.path {segmentation}}")
  }

  if (!dir.exists(qc_dir)) {
    dir.create(qc_dir, recursive = TRUE)
  }

  args <- c(
    "-i", input,
    "-s", segmentation,
    "-p", process,
    "-qc", qc_dir
  )

  result <- sct_run("sct_qc", args = args, verbose = verbose)

  if (verbose && result$exit_code == 0L) {
    cli::cli_alert_success("QC report generated in {.path {qc_dir}}")
  }

  invisible(result$exit_code)
}
