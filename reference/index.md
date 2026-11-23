# Package index

## Spinal Cord Toolbox

Wrappers for SCT command-line tools (needs SCT 6.4 or later).

- [`check_sct()`](https://cttir.github.io/scimagR/reference/check_sct.md)
  : Check Spinal Cord Toolbox Availability
- [`sct_segment_sc()`](https://cttir.github.io/scimagR/reference/sct_segment_sc.md)
  : Segment Spinal Cord
- [`sct_segment_lesion()`](https://cttir.github.io/scimagR/reference/sct_segment_lesion.md)
  : Segment SCI Lesion
- [`sct_label_vertebrae()`](https://cttir.github.io/scimagR/reference/sct_label_vertebrae.md)
  : Label Vertebral Levels
- [`sct_analyze_lesion()`](https://cttir.github.io/scimagR/reference/sct_analyze_lesion.md)
  : Extract Lesion Parameters
- [`sct_process_segmentation()`](https://cttir.github.io/scimagR/reference/sct_process_segmentation.md)
  : Extract Morphometric Parameters
- [`sct_generate_qc()`](https://cttir.github.io/scimagR/reference/sct_generate_qc.md)
  : Generate SCT Quality Control Report

## DICOM tools

Metadata extraction, anonymisation and NIfTI conversion (needs ‘pydicom’
or ‘dcm2niix’).

- [`check_pydicom()`](https://cttir.github.io/scimagR/reference/check_pydicom.md)
  : Check pydicom Availability
- [`check_dcm2niix()`](https://cttir.github.io/scimagR/reference/check_dcm2niix.md)
  : Check dcm2niix Availability
- [`extract_dicom_metadata()`](https://cttir.github.io/scimagR/reference/extract_dicom_metadata.md)
  : Extract DICOM Header Metadata
- [`anonymize_dicom()`](https://cttir.github.io/scimagR/reference/anonymize_dicom.md)
  : Anonymise DICOM Files
- [`convert_dcm2niix()`](https://cttir.github.io/scimagR/reference/convert_dcm2niix.md)
  : Convert DICOM to NIfTI
- [`convert_batch()`](https://cttir.github.io/scimagR/reference/convert_batch.md)
  : Batch Convert DICOM to NIfTI

## SCI metrics

- [`compute_mscc()`](https://cttir.github.io/scimagR/reference/compute_mscc.md)
  : Compute Maximum Spinal Cord Compression (MSCC)
- [`compute_compression_ratio()`](https://cttir.github.io/scimagR/reference/compute_compression_ratio.md)
  : Compute Spinal Cord Compression Ratio
- [`compute_csa_ratio()`](https://cttir.github.io/scimagR/reference/compute_csa_ratio.md)
  : Compute Cross-Sectional Area Ratio
- [`classify_phase()`](https://cttir.github.io/scimagR/reference/classify_phase.md)
  : Classify SCI Phase Based on Days Post Trauma
- [`classify_artifact()`](https://cttir.github.io/scimagR/reference/classify_artifact.md)
  : Classify MRI Artefact Grade

## Imaging registry

- [`create_registry()`](https://cttir.github.io/scimagR/reference/create_registry.md)
  : Create an Imaging Registry from DICOM Metadata
- [`validate_registry()`](https://cttir.github.io/scimagR/reference/validate_registry.md)
  : Validate an Imaging Registry
- [`coverage_matrix()`](https://cttir.github.io/scimagR/reference/coverage_matrix.md)
  : Create a Modality Coverage Matrix
- [`plot_coverage()`](https://cttir.github.io/scimagR/reference/plot_coverage.md)
  : Plot Modality Coverage Matrix

## Quality control

- [`create_qc_log()`](https://cttir.github.io/scimagR/reference/create_qc_log.md)
  : Create a QC Segmentation Log
- [`update_qc_log()`](https://cttir.github.io/scimagR/reference/update_qc_log.md)
  : Update a QC Log
- [`validate_qc_log()`](https://cttir.github.io/scimagR/reference/validate_qc_log.md)
  : Validate a QC Log
- [`filter_evaluable()`](https://cttir.github.io/scimagR/reference/filter_evaluable.md)
  : Filter to Evaluable Imaging Sessions
- [`log_exclusion()`](https://cttir.github.io/scimagR/reference/log_exclusion.md)
  : Log an Exclusion Step
- [`integrity_summary()`](https://cttir.github.io/scimagR/reference/integrity_summary.md)
  : Print Data Integrity Summary

## Plots, theme and palettes

- [`theme_sci()`](https://cttir.github.io/scimagR/reference/theme_sci.md)
  : SCI Publication Theme
- [`plot_violin_box()`](https://cttir.github.io/scimagR/reference/plot_violin_box.md)
  : Violin + Box Plot
- [`plot_spaghetti()`](https://cttir.github.io/scimagR/reference/plot_spaghetti.md)
  : Spaghetti Plot
- [`plot_forest()`](https://cttir.github.io/scimagR/reference/plot_forest.md)
  : Forest Plot
- [`scale_colour_phase()`](https://cttir.github.io/scimagR/reference/scale_phase.md)
  [`scale_fill_phase()`](https://cttir.github.io/scimagR/reference/scale_phase.md)
  : Colour and Fill Scales for SCI Phases
- [`scale_colour_artifact()`](https://cttir.github.io/scimagR/reference/scale_artifact.md)
  [`scale_fill_artifact()`](https://cttir.github.io/scimagR/reference/scale_artifact.md)
  : Colour and Fill Scales for Artefact Grades
- [`scale_colour_modality()`](https://cttir.github.io/scimagR/reference/scale_modality.md)
  [`scale_fill_modality()`](https://cttir.github.io/scimagR/reference/scale_modality.md)
  : Colour and Fill Scales for Imaging Modalities
- [`pal_phase`](https://cttir.github.io/scimagR/reference/pal_phase.md)
  : SCI Phase Colour Palette
- [`pal_artifact`](https://cttir.github.io/scimagR/reference/pal_artifact.md)
  : Artefact Grade Colour Palette
- [`pal_modality`](https://cttir.github.io/scimagR/reference/pal_modality.md)
  : Modality Colour Palette

## Projects, pipeline and export

- [`sci_create_project()`](https://cttir.github.io/scimagR/reference/sci_create_project.md)
  : Create a New SCI MRI/CT Analysis Project
- [`sci_run_pipeline()`](https://cttir.github.io/scimagR/reference/sci_run_pipeline.md)
  : Plan the SCI Analysis Pipeline
- [`sci_pipeline_status()`](https://cttir.github.io/scimagR/reference/sci_pipeline_status.md)
  : Get Pipeline Status
- [`save_fig()`](https://cttir.github.io/scimagR/reference/save_fig.md)
  : Save Figure with Standard Conventions
- [`save_table()`](https://cttir.github.io/scimagR/reference/save_table.md)
  : Save Table as Excel
- [`save_rds()`](https://cttir.github.io/scimagR/reference/save_rds.md)
  : Save R Object as RDS
