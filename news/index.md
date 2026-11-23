# Changelog

## scimagR 0.2.0

### Spinal Cord Toolbox wrappers

- The wrappers support SCT 7:
  [`sct_segment_sc()`](https://cttir.github.io/scimagR/reference/sct_segment_sc.md)
  and
  [`sct_segment_lesion()`](https://cttir.github.io/scimagR/reference/sct_segment_lesion.md)
  read the installed version from `sct_version` and call
  `sct_deepseg spinalcord` / `sct_deepseg lesion_sci_t2` (SCT \>= 7.0)
  or `sct_deepseg -task ...` (SCT 6). SCT 7 given `-task` printed a note
  and exited with status 0, so the wrappers used to report success
  without an output file.
- All wrappers now check that SCT wrote the expected file and return
  `NA` with a warning when it did not.
  [`sct_segment_lesion()`](https://cttir.github.io/scimagR/reference/sct_segment_lesion.md)
  also returns `NA` with a warning when the lesion mask cannot be copied
  to `output`.
- The wrappers return the files SCT actually writes:
  [`sct_segment_lesion()`](https://cttir.github.io/scimagR/reference/sct_segment_lesion.md)
  saves the SCIsegV2 lesion mask under `output` and the cord mask next
  to it as `*_sc_seg.nii.gz` (SCT appends `_lesion_seg` and `_sc_seg` to
  the name given with `-o`);
  [`sct_label_vertebrae()`](https://cttir.github.io/scimagR/reference/sct_label_vertebrae.md)
  returns `<segmentation>_labeled.nii.gz`, the vertebral level file that
  [`sct_process_segmentation()`](https://cttir.github.io/scimagR/reference/sct_process_segmentation.md)
  needs (it used to return a `*_labels-disc.nii.gz` path that SCT never
  writes);
  [`sct_analyze_lesion()`](https://cttir.github.io/scimagR/reference/sct_analyze_lesion.md)
  returns the `*_analysis.xlsx` (SCT 6.5 and later) or `*_analysis.xls`
  (SCT 6.4) spreadsheet instead of a non-existent CSV.
- [`sct_segment_sc()`](https://cttir.github.io/scimagR/reference/sct_segment_sc.md)
  and
  [`sct_segment_lesion()`](https://cttir.github.io/scimagR/reference/sct_segment_lesion.md)
  pass `qc_dir` to `sct_deepseg -qc`.
  [`sct_generate_qc()`](https://cttir.github.io/scimagR/reference/sct_generate_qc.md)
  defaults to the valid `sct_qc` process `"sct_deepseg_sc"` (the former
  default `"sct_deepseg"` is mapped to it) and gains `lesion` and
  `plane` for lesion reports.
- [`sct_process_segmentation()`](https://cttir.github.io/scimagR/reference/sct_process_segmentation.md)
  gains `vert` and `perlevel` to aggregate per vertebral level; its
  documentation now says that by default SCT averages over all slices
  and leaves the `VertLevel` column empty.
- Arguments passed to SCT are shell-quoted, so paths with spaces work.

### Pipeline, DICOM and registry

- [`sci_run_pipeline()`](https://cttir.github.io/scimagR/reference/sci_run_pipeline.md)
  is documented as a planner: it runs no tool and reports every step as
  pending.
  [`sci_pipeline_status()`](https://cttir.github.io/scimagR/reference/sci_pipeline_status.md)
  recognises the SCT output names, no longer counts a lesion mask as a
  cord segmentation, and always returns its documented columns.
- [`extract_dicom_metadata()`](https://cttir.github.io/scimagR/reference/extract_dicom_metadata.md)
  takes `pat_id` from the folder name, as documented, and no longer
  exports the `PatientID` header, which could hold a hospital number and
  broke the paths
  [`convert_batch()`](https://cttir.github.io/scimagR/reference/convert_batch.md)
  builds.
- [`create_registry()`](https://cttir.github.io/scimagR/reference/create_registry.md)
  recodes the DICOM modality `"MR"` to `"MRT"`, so registries built from
  extracted metadata pass
  [`validate_registry()`](https://cttir.github.io/scimagR/reference/validate_registry.md),
  and warns about patients without a trauma date.
- [`create_registry()`](https://cttir.github.io/scimagR/reference/create_registry.md)
  matches trauma and surgery dates to patients by ID text. A numeric
  `pat_id` (e.g. from folders named `1`, `2`, …) used to pick the dates
  by position, so patients could silently get another patient’s trauma
  date, days since trauma and phase.
  [`create_registry()`](https://cttir.github.io/scimagR/reference/create_registry.md)
  and
  [`validate_registry()`](https://cttir.github.io/scimagR/reference/validate_registry.md)
  read `pat_id` and `session` from a CSV as text.
- [`convert_dcm2niix()`](https://cttir.github.io/scimagR/reference/convert_dcm2niix.md)
  raises an error when ‘dcm2niix’ fails.
- [`anonymize_dicom()`](https://cttir.github.io/scimagR/reference/anonymize_dicom.md)
  documents exactly which tags it changes and that it is not a full
  DICOM PS3.15 de-identification.
- Two synthetic DICOM slices (`inst/extdata/dicom/`, made by
  `data-raw/make_example_dicom.py`) let the DICOM examples and tests run
  where ‘pydicom’ or ‘dcm2niix’ is installed.

### Metrics and plots

- [`compute_mscc()`](https://cttir.github.io/scimagR/reference/compute_mscc.md),
  [`compute_compression_ratio()`](https://cttir.github.io/scimagR/reference/compute_compression_ratio.md)
  and
  [`compute_csa_ratio()`](https://cttir.github.io/scimagR/reference/compute_csa_ratio.md)
  are vectorised (they failed on vectors, e.g. inside
  [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html))
  and cite their definitions (Fehlings et al. 1999; Ogino et al. 1983).
  Arguments of length 1 are recycled; any other length mismatch is an
  error instead of being recycled silently.
- [`classify_phase()`](https://cttir.github.io/scimagR/reference/classify_phase.md)
  returns `NA` with a warning for negative days, and
  [`classify_artifact()`](https://cttir.github.io/scimagR/reference/classify_artifact.md)
  for grades that are not whole numbers.
- The phase, artefact and modality scales list legend entries in palette
  order;
  [`plot_coverage()`](https://cttir.github.io/scimagR/reference/plot_coverage.md)
  explains the grade numbers in a caption;
  [`plot_forest()`](https://cttir.github.io/scimagR/reference/plot_forest.md)
  no longer uses the deprecated
  [`geom_errorbarh()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html).

### Documentation

- Examples no longer use `\dontrun{}`: each wrapper has an example that
  runs without the external tool, and the tool calls are in
  `\donttest{}` behind
  [`check_sct()`](https://cttir.github.io/scimagR/reference/check_sct.md),
  [`check_dcm2niix()`](https://cttir.github.io/scimagR/reference/check_dcm2niix.md)
  or
  [`check_pydicom()`](https://cttir.github.io/scimagR/reference/check_pydicom.md).
- The getting-started and pipeline vignettes run their tool-free code on
  synthetic data; the SCT vignette describes the output files.
- British English throughout; citation metadata name the author R.
  Heller; grouped pkgdown reference index.

### Other changes

- [`sci_run_pipeline()`](https://cttir.github.io/scimagR/reference/sci_run_pipeline.md)
  no longer reports steps as complete without running them. It returns
  the step plan with status `"pending"` and the function that performs
  each step; the vignettes and README describe it that way.
- Prepared the package for a first CRAN submission.
- [`theme_sci()`](https://cttir.github.io/scimagR/reference/theme_sci.md)
  now defaults to `base_family = ""` (the device’s sans-serif font). The
  previous default `"Arial"` made every plot fail on the base
  [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device; pass
  `base_family = "Arial"` to keep the old look on devices that can use
  system fonts.
- Examples now run on bundled or synthetic data for all functions that
  do not need external software (registry, coverage, quality control,
  plotting, export and project scaffolding).
- `DESCRIPTION`: title without “in R”, expanded description with a
  reference for the Spinal Cord Toolbox, optional `SystemRequirements`,
  `Language`, pkgdown URL and the maintainer’s ORCID.
- Documented the colour palettes’ format.

## scimagR 0.1.0

- Standardise the named v5 package logo across README, documentation
  pages and available application headers, with matching light and dark
  artwork.

- Initial release.

- SCT interface: R wrappers for spinal cord segmentation, lesion
  segmentation, vertebral labelling, and parameter extraction.

- DICOM tools: metadata extraction, anonymisation, batch NIfTI
  conversion.

- SCI metrics: MSCC, compression ratio, CSA ratio, phase classification,
  artefact grading.

- Registry management: creation, validation, coverage matrix
  visualisation.

- QC system: segmentation QC logging, evaluability filtering, exclusion
  tracking.

- Visualisation: publication-ready theme, SCI-specific palettes and
  scales, standard plot types (violin-box, spaghetti, forest).

- Pipeline orchestration: idempotent multi-step processing with resume
  support.

- Project scaffolding:
  [`sci_create_project()`](https://cttir.github.io/scimagR/reference/sci_create_project.md)
  for workflowr-based SCI studies.
