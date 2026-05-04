#' Label Vertebral Levels
#'
#' Runs SCT's vertebral labeling on a spinal cord segmentation.
#'
#' @param input Character. Path to T2w NIfTI file.
#' @param segmentation Character. Path to spinal cord segmentation.
#' @param contrast Character. MRI contrast type. Default `"t2"`.
#' @param output_dir Character. Directory for output labels. Defaults to
#'   the directory of `input`.
#' @param overwrite Logical. Re-run if output exists? Default `FALSE`.
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @return Character. Path to vertebral label NIfTI, or `NA` on failure.
#' @export
#' @examples
#' \dontrun{
#' sct_label_vertebrae("sub-01_T2w.nii.gz", "sub-01_T2w_seg.nii.gz")
#' }
sct_label_vertebrae <- function(input,
                                segmentation,
                                contrast = "t2",
                                output_dir = NULL,
                                overwrite = FALSE,
                                verbose = TRUE) {
  rlang::check_required(input)
  rlang::check_required(segmentation)
  stopifnot(
    is.character(input), length(input) == 1,
    is.character(segmentation), length(segmentation) == 1
  )

  if (!file.exists(input)) {
    cli::cli_abort("Input file not found: {.path {input}}")
  }
  if (!file.exists(segmentation)) {
    cli::cli_abort("Segmentation file not found: {.path {segmentation}}")
  }

  dir_out <- output_dir %||% dirname(input)
  base <- sub("\\.nii(\\.gz)?$", "", basename(input))
  output <- file.path(dir_out, paste0(base, "_labels-disc.nii.gz"))

  if (file.exists(output) && !overwrite) {
    if (verbose) cli::cli_alert_info("Output exists, skipping: {.path {output}}")
    return(output)
  }

  args <- c(
    "-i", input,
    "-s", segmentation,
    "-c", contrast,
    "-ofolder", dir_out
  )

  result <- sct_run("sct_label_vertebrae", args = args, verbose = verbose)

  if (result$exit_code != 0L) {
    return(NA_character_)
  }

  if (verbose) cli::cli_alert_success("Vertebral labels saved: {.path {output}}")
  output
}
