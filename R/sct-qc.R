#' Generate SCT Quality Control Report
#'
#' Creates an HTML QC report with `sct_qc`, overlaying a segmentation on the
#' original image.
#'
#' For a lesion report (`process = "sct_deepseg_lesion"`), `segmentation`
#' is the spinal cord mask and `lesion` the lesion mask; `sct_qc` then also
#' needs the `plane` of the report.
#'
#' @param input Character. Path to original NIfTI image.
#' @param segmentation Character. Path to segmentation overlay (the spinal
#'   cord mask for a lesion report).
#' @param qc_dir Character. Directory for QC HTML output.
#' @param process Character. The `sct_qc -p` process the report is made
#'   for, e.g. `"sct_deepseg_sc"` (default), `"sct_deepseg_lesion"` or
#'   `"sct_label_vertebrae"`. The former default `"sct_deepseg"`, which
#'   `sct_qc` does not accept, is treated as `"sct_deepseg_sc"`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @param lesion Character. Path to the lesion mask. Required when
#'   `process = "sct_deepseg_lesion"`, ignored otherwise. Default `NULL`.
#' @param plane Character. `"sagittal"` (default) or `"axial"`; the plane of
#'   a lesion report.
#' @return Exit code (invisible).
#' @export
#' @examples
#' # Inputs are checked before SCT is called:
#' try(sct_generate_qc("missing_T2w.nii.gz", "missing_seg.nii.gz",
#'                     file.path(tempdir(), "qc")))
#'
#' \donttest{
#' # With SCT installed: QC report of the PAM50 template cord mask.
#' sct <- check_sct(verbose = FALSE)
#' if (sct$available) {
#'   pam50 <- file.path(dirname(dirname(sct$path)), "data", "PAM50",
#'                      "template")
#'   t2w <- file.path(pam50, "PAM50_t2.nii.gz")
#'   seg <- file.path(pam50, "PAM50_cord.nii.gz")
#'   if (file.exists(t2w) && file.exists(seg)) {
#'     sct_generate_qc(t2w, seg, qc_dir = file.path(tempdir(), "qc"))
#'   }
#' }
#' }
sct_generate_qc <- function(input,
                            segmentation,
                            qc_dir,
                            process = "sct_deepseg_sc",
                            verbose = TRUE,
                            lesion = NULL,
                            plane = c("sagittal", "axial")) {
  rlang::check_required(input)
  rlang::check_required(segmentation)
  rlang::check_required(qc_dir)
  plane <- rlang::arg_match(plane)

  if (!file.exists(input)) {
    cli::cli_abort("Input file not found: {.path {input}}")
  }
  if (!file.exists(segmentation)) {
    cli::cli_abort("Segmentation file not found: {.path {segmentation}}")
  }

  if (identical(process, "sct_deepseg")) {
    process <- "sct_deepseg_sc"
  }

  lesion_args <- character()
  if (identical(process, "sct_deepseg_lesion")) {
    if (is.null(lesion)) {
      cli::cli_abort(c(
        "A lesion QC report needs the lesion mask in {.arg lesion}.",
        "i" = "Pass the spinal cord mask as {.arg segmentation}."
      ), class = "scimagR_error_input")
    }
    if (!file.exists(lesion)) {
      cli::cli_abort("Lesion file not found: {.path {lesion}}")
    }
    lesion_args <- c("-d", lesion, "-plane", plane)
  }

  if (!dir.exists(qc_dir)) {
    dir.create(qc_dir, recursive = TRUE)
  }

  args <- c(
    "-i", input,
    "-s", segmentation,
    lesion_args,
    "-p", process,
    "-qc", qc_dir
  )

  result <- sct_run("sct_qc", args = args, verbose = verbose)

  if (verbose && result$exit_code == 0L) {
    cli::cli_alert_success("QC report generated in {.path {qc_dir}}")
  }

  invisible(result$exit_code)
}
