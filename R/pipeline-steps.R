#' Pipeline Step Definitions
#'
#' Internal functions defining each pipeline step. Each step function
#' accepts a project configuration list and returns a status string.
#'
#' @name pipeline-steps
#' @keywords internal
NULL

#' @keywords internal
pipeline_step_extract_metadata <- function(config, verbose = TRUE) {
  extract_dicom_metadata(
    dicom_dir = config$dicom_root,
    output_csv = config$dicom_metadata_csv,
    python = config$python
  )
  "complete"
}

#' @keywords internal
pipeline_step_anonymize <- function(config, verbose = TRUE) {
  anonymize_dicom(
    dicom_dir = config$dicom_root,
    mapping_csv = config$mapping_csv,
    prefix = config$id_prefix %||% "SCI",
    python = config$python
  )
  "complete"
}

#' @keywords internal
pipeline_step_convert <- function(config, registry, verbose = TRUE) {
  convert_batch(
    registry = registry,
    dicom_root = config$dicom_root,
    nifti_root = config$nifti_root,
    verbose = verbose
  )
  "complete"
}

#' @keywords internal
pipeline_step_segment_sc <- function(nifti_path, output_dir = NULL,
                                     qc_dir = NULL, overwrite = FALSE,
                                     verbose = TRUE) {
  sct_segment_sc(
    input = nifti_path,
    output_dir = output_dir,
    overwrite = overwrite,
    verbose = verbose,
    qc_dir = qc_dir
  )
}

#' @keywords internal
pipeline_step_segment_lesion <- function(nifti_path, output_dir = NULL,
                                         qc_dir = NULL, overwrite = FALSE,
                                         verbose = TRUE) {
  sct_segment_lesion(
    input = nifti_path,
    output_dir = output_dir,
    overwrite = overwrite,
    verbose = verbose,
    qc_dir = qc_dir
  )
}

#' @keywords internal
pipeline_step_label_vertebrae <- function(nifti_path, sc_seg_path,
                                          output_dir = NULL,
                                          overwrite = FALSE,
                                          verbose = TRUE) {
  sct_label_vertebrae(
    input = nifti_path,
    segmentation = sc_seg_path,
    output_dir = output_dir,
    overwrite = overwrite,
    verbose = verbose
  )
}

#' @keywords internal
pipeline_step_extract_params <- function(lesion_seg, sc_seg, vert_labels,
                                         output_dir = NULL,
                                         verbose = TRUE) {
  lesion_csv <- sct_analyze_lesion(
    lesion_seg = lesion_seg,
    sc_seg = sc_seg,
    output_dir = output_dir,
    verbose = verbose
  )

  csa_csv <- sct_process_segmentation(
    sc_seg = sc_seg,
    vert_labels = vert_labels,
    output_dir = output_dir,
    verbose = verbose
  )

  list(lesion_csv = lesion_csv, csa_csv = csa_csv)
}
