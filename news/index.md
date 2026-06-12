# Changelog

## scimagR 0.1.0

- Initial release.
- SCT interface: R wrappers for spinal cord segmentation, lesion
  segmentation, vertebral labeling, and parameter extraction.
- DICOM tools: metadata extraction, anonymization, batch NIfTI
  conversion.
- SCI metrics: MSCC, compression ratio, CSA ratio, phase classification,
  artifact grading.
- Registry management: creation, validation, coverage matrix
  visualization.
- QC system: segmentation QC logging, evaluability filtering, exclusion
  tracking.
- Visualization: publication-ready theme, SCI-specific palettes and
  scales, standard plot types (violin-box, spaghetti, forest).
- Pipeline orchestration: idempotent multi-step processing with resume
  support.
- Project scaffolding:
  [`sci_create_project()`](https://cttir.github.io/scimagR/reference/sci_create_project.md)
  for workflowr-based SCI studies.
