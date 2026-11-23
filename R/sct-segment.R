#' Segment Spinal Cord
#'
#' Runs the contrast-agnostic spinal cord segmentation model of the Spinal
#' Cord Toolbox (Bédard et al. 2025) through `sct_deepseg`. The wrapper
#' uses the task syntax of the installed SCT version
#' (`sct_deepseg spinalcord` from SCT 7.0, `sct_deepseg -task
#' seg_sc_contrast_agnostic` before).
#'
#' @param input Character. Path to NIfTI file (.nii.gz).
#' @param output Character. Path for output segmentation. Auto-generated if
#'   `NULL`: `<input>_seg.nii.gz` in `output_dir`.
#' @param output_dir Character. Directory for output. Alternative to `output`.
#'   Defaults to the directory of `input`.
#' @param overwrite Logical. Re-run if output exists? Default `FALSE`
#'   (idempotent).
#' @param verbose Logical. Print progress. Default `TRUE`.
#' @param qc_dir Character. If provided, `sct_deepseg` also writes its HTML
#'   QC report to this directory.
#' @return Character. Path to output segmentation file, or `NA` on failure
#'   (non-zero exit status, or no output file written).
#' @references Bédard S, Karthik EN, Tsagkas C, et al. (2025). Towards
#'   contrast-agnostic soft segmentation of the spinal cord. *Medical Image
#'   Analysis* 101:103473. \doi{10.1016/j.media.2025.103473}
#' @export
#' @examples
#' # Without the Spinal Cord Toolbox: an existing output is returned as is,
#' # so finished sessions are skipped (here with an empty placeholder file).
#' dir <- file.path(tempdir(), "sct-seg-example")
#' dir.create(dir, showWarnings = FALSE)
#' t2w <- file.path(dir, "sub-01_T2w.nii.gz")
#' file.create(t2w, file.path(dir, "sub-01_T2w_seg.nii.gz"))
#' sct_segment_sc(t2w)
#' unlink(dir, recursive = TRUE)
#'
#' \donttest{
#' # With SCT installed: segment the PAM50 T2w template shipped with SCT.
#' # This runs a deep-learning model and can take several minutes.
#' sct <- check_sct(verbose = FALSE)
#' if (sct$available && interactive()) {
#'   pam50_t2 <- file.path(dirname(dirname(sct$path)), "data", "PAM50",
#'                         "template", "PAM50_t2.nii.gz")
#'   if (file.exists(pam50_t2)) {
#'     sct_segment_sc(pam50_t2, output_dir = tempdir())
#'   }
#' }
#' }
sct_segment_sc <- function(input,
                           output = NULL,
                           output_dir = NULL,
                           overwrite = FALSE,
                           verbose = TRUE,
                           qc_dir = NULL) {
  rlang::check_required(input)
  check_single_path(input)

  if (!file.exists(input)) {
    cli::cli_abort("Input file not found: {.path {input}}")
  }

  if (is.null(output)) {
    dir_out <- output_dir %||% dirname(input)
    output <- file.path(dir_out, paste0(nii_stem(basename(input)), "_seg.nii.gz"))
  }

  if (file.exists(output) && !overwrite) {
    if (verbose) cli::cli_alert_info("Output exists, skipping: {.path {output}}")
    return(output)
  }

  args <- c(
    sct_deepseg_task_args("spinalcord"),
    "-i", input,
    "-o", output
  )
  if (!is.null(qc_dir)) {
    args <- c(args, "-qc", qc_dir)
  }

  result <- sct_run("sct_deepseg", args = args, verbose = verbose)

  if (result$exit_code != 0L || !sct_output_exists(output, "sct_deepseg")) {
    return(NA_character_)
  }

  if (verbose) cli::cli_alert_success("SC segmentation saved: {.path {output}}")
  output
}

#' Segment SCI Lesion
#'
#' Runs the SCIsegV2 lesion segmentation model (Karthik et al. 2025) through
#' `sct_deepseg` (`sct_deepseg lesion_sci_t2` from SCT 7.0, `sct_deepseg
#' -task seg_sc_lesion_t2w_sci` before). The model segments both the lesion
#' and the spinal cord: the lesion mask is written to `output`, the cord
#' mask next to it with the suffix `_sc_seg` (for the default output
#' `<input>_lesion_seg.nii.gz` this is `<input>_sc_seg.nii.gz`).
#'
#' @inheritParams sct_segment_sc
#' @param input Character. Path to T2w NIfTI file (.nii.gz).
#' @param output Character. Path for output lesion segmentation.
#'   Auto-generated if `NULL`: `<input>_lesion_seg.nii.gz` in `output_dir`.
#' @return Character. Path to output lesion segmentation, or `NA` on failure
#'   (non-zero exit status, or no lesion mask written).
#' @references Karthik EN, Valošek J, Farner L, et al. (2025). SCIsegV2: A
#'   universal tool for segmentation of intramedullary lesions in spinal cord
#'   injury. In *Applications of Medical Artificial Intelligence* (AMAI 2024),
#'   Lecture Notes in Computer Science, pp. 198--209.
#'   \doi{10.1007/978-3-031-82007-6_19}
#' @export
#' @examples
#' # Without the Spinal Cord Toolbox: an existing lesion mask is returned as
#' # is (here an empty placeholder file).
#' dir <- file.path(tempdir(), "sct-lesion-example")
#' dir.create(dir, showWarnings = FALSE)
#' t2w <- file.path(dir, "sub-01_T2w.nii.gz")
#' file.create(t2w, file.path(dir, "sub-01_T2w_lesion_seg.nii.gz"))
#' sct_segment_lesion(t2w)
#' unlink(dir, recursive = TRUE)
#'
#' \donttest{
#' # With SCT installed: run SCIsegV2 on your own T2-weighted image.
#' # This runs a deep-learning model and can take several minutes.
#' t2w <- "sub-01_T2w.nii.gz"
#' if (check_sct(verbose = FALSE)$available && file.exists(t2w)) {
#'   sct_segment_lesion(t2w, output_dir = tempdir())
#' }
#' }
sct_segment_lesion <- function(input,
                               output = NULL,
                               output_dir = NULL,
                               overwrite = FALSE,
                               verbose = TRUE,
                               qc_dir = NULL) {
  rlang::check_required(input)
  check_single_path(input)

  if (!file.exists(input)) {
    cli::cli_abort("Input file not found: {.path {input}}")
  }

  if (is.null(output)) {
    dir_out <- output_dir %||% dirname(input)
    output <- file.path(
      dir_out, paste0(nii_stem(basename(input)), "_lesion_seg.nii.gz")
    )
  }

  if (file.exists(output) && !overwrite) {
    if (verbose) cli::cli_alert_info("Output exists, skipping: {.path {output}}")
    return(output)
  }

  # The multiclass model appends "_lesion_seg" and "_sc_seg" to the name
  # given with -o. Let SCT write into a scratch folder, then copy the masks
  # to their final names, so that -o never points at the input image.
  ext <- nii_ext(output)
  if (!nzchar(ext)) ext <- ".nii.gz"
  scratch <- tempfile("sct_lesion_")
  dir.create(scratch)
  on.exit(unlink(scratch, recursive = TRUE), add = TRUE)
  stem <- file.path(scratch, nii_stem(basename(input)))

  args <- c(
    sct_deepseg_task_args("lesion_sci_t2"),
    "-i", input,
    "-o", paste0(stem, ext)
  )
  if (!is.null(qc_dir)) {
    args <- c(args, "-qc", qc_dir)
  }

  result <- sct_run("sct_deepseg", args = args, verbose = verbose)

  lesion_tmp <- paste0(stem, "_lesion_seg", ext)
  if (result$exit_code != 0L || !sct_output_exists(lesion_tmp, "sct_deepseg")) {
    return(NA_character_)
  }

  dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
  file.copy(lesion_tmp, output, overwrite = TRUE)
  sc_tmp <- paste0(stem, "_sc_seg", ext)
  if (file.exists(sc_tmp)) {
    sc_out <- paste0(sub("_lesion_seg$", "", nii_stem(output)), "_sc_seg", ext)
    file.copy(sc_tmp, sc_out, overwrite = TRUE)
  }

  if (verbose) cli::cli_alert_success("Lesion segmentation saved: {.path {output}}")
  output
}

# Abort unless `x` is a single character string (a file path).
check_single_path <- function(x, arg = rlang::caller_arg(x),
                              call = rlang::caller_env()) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be a single file path (a character string).",
      class = "scimagR_error_input",
      call = call
    )
  }
  invisible(TRUE)
}
