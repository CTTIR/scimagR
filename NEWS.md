# scimagR 0.2.0

## Spinal Cord Toolbox wrappers

* The wrappers support SCT 7: `sct_segment_sc()` and `sct_segment_lesion()`
  read the installed version from `sct_version` and call
  `sct_deepseg spinalcord` / `sct_deepseg lesion_sci_t2` (SCT >= 7.0) or
  `sct_deepseg -task ...` (SCT 6). SCT 7 given `-task` printed a note and
  exited with status 0, so the wrappers used to report success without an
  output file.
* All wrappers now check that SCT wrote the expected file and return `NA`
  with a warning when it did not.
* The wrappers return the files SCT actually writes:
  `sct_segment_lesion()` saves the SCIsegV2 lesion mask under `output` and
  the cord mask next to it as `*_sc_seg.nii.gz` (SCT appends `_lesion_seg`
  and `_sc_seg` to the name given with `-o`); `sct_label_vertebrae()`
  returns `<segmentation>_labeled.nii.gz`, the vertebral level file that
  `sct_process_segmentation()` needs (it used to return a
  `*_labels-disc.nii.gz` path that SCT never writes);
  `sct_analyze_lesion()` returns the `*_analysis.xlsx` (SCT 7) or
  `*_analysis.xls` (SCT 6) spreadsheet instead of a non-existent CSV.
* `sct_segment_sc()` and `sct_segment_lesion()` pass `qc_dir` to
  `sct_deepseg -qc`. `sct_generate_qc()` defaults to the valid `sct_qc`
  process `"sct_deepseg_sc"` (the former default `"sct_deepseg"` is mapped
  to it) and gains `lesion` and `plane` for lesion reports.
* `sct_process_segmentation()` gains `vert` and `perlevel` to aggregate
  per vertebral level; its documentation now says that by default SCT
  averages over all slices.
* Arguments passed to SCT are shell-quoted, so paths with spaces work.

## Pipeline, DICOM and registry

* `sci_run_pipeline()` is documented as a planner: it runs no tool and
  reports every step as pending. `sci_pipeline_status()` recognises the
  SCT output names, no longer counts a lesion mask as a cord segmentation,
  and always returns its documented columns.
* `extract_dicom_metadata()` takes `pat_id` from the folder name, as
  documented, and no longer exports the `PatientID` header, which could
  hold a hospital number and broke the paths `convert_batch()` builds.
* `create_registry()` recodes the DICOM modality `"MR"` to `"MRT"`, so
  registries built from extracted metadata pass `validate_registry()`, and
  warns about patients without a trauma date.
* `create_registry()` matches trauma and surgery dates to patients by ID
  text. A numeric `pat_id` (e.g. from folders named `1`, `2`, ...) used to
  pick the dates by position, so patients could silently get another
  patient's trauma date, days since trauma and phase. `create_registry()`
  and `validate_registry()` read `pat_id` and `session` from a CSV as text.
* `convert_dcm2niix()` raises an error when 'dcm2niix' fails.
* `anonymize_dicom()` documents exactly which tags it changes and that it
  is not a full DICOM PS3.15 de-identification.
* Two synthetic DICOM slices (`inst/extdata/dicom/`, made by
  `data-raw/make_example_dicom.py`) let the DICOM examples and tests run
  where 'pydicom' or 'dcm2niix' is installed.

## Metrics and plots

* `compute_mscc()`, `compute_compression_ratio()` and `compute_csa_ratio()`
  are vectorised (they failed on vectors, e.g. inside `dplyr::mutate()`)
  and cite their definitions (Fehlings et al. 1999; Ogino et al. 1983).
* `classify_phase()` returns `NA` with a warning for negative days, and
  `classify_artifact()` for grades that are not whole numbers.
* The phase, artefact and modality scales list legend entries in palette
  order; `plot_coverage()` explains the grade numbers in a caption;
  `plot_forest()` no longer uses the deprecated `geom_errorbarh()`.

## Documentation

* Examples no longer use `\dontrun{}`: each wrapper has an example that
  runs without the external tool, and the tool calls are in `\donttest{}`
  behind `check_sct()`, `check_dcm2niix()` or `check_pydicom()`.
* The getting-started and pipeline vignettes run their tool-free code on
  synthetic data; the SCT vignette describes the output files.
* British English throughout; citation metadata name the author R. Heller;
  grouped pkgdown reference index.

## Other changes

* `sci_run_pipeline()` no longer reports steps as complete without running
  them. It returns the step plan with status `"pending"` and the function
  that performs each step; the vignettes and README describe it that way.
* Prepared the package for a first CRAN submission.
* `theme_sci()` now defaults to `base_family = ""` (the device's sans-serif
  font). The previous default `"Arial"` made every plot fail on the base
  `pdf()` device; pass `base_family = "Arial"` to keep the old look on
  devices that can use system fonts.
* Examples now run on bundled or synthetic data for all functions that do not
  need external software (registry, coverage, quality control, plotting,
  export and project scaffolding).
* `DESCRIPTION`: title without "in R", expanded description with a
  reference for the Spinal Cord Toolbox, optional `SystemRequirements`,
  `Language`, pkgdown URL and the maintainer's ORCID.
* Documented the colour palettes' format.

# scimagR 0.1.0

* Standardise the named v5 package logo across README, documentation pages
  and available application headers, with matching light and dark artwork.


* Initial release.
* SCT interface: R wrappers for spinal cord segmentation, lesion segmentation,
  vertebral labelling, and parameter extraction.
* DICOM tools: metadata extraction, anonymisation, batch NIfTI conversion.
* SCI metrics: MSCC, compression ratio, CSA ratio, phase classification,
  artefact grading.
* Registry management: creation, validation, coverage matrix visualisation.
* QC system: segmentation QC logging, evaluability filtering, exclusion tracking.
* Visualisation: publication-ready theme, SCI-specific palettes and scales,
  standard plot types (violin-box, spaghetti, forest).
* Pipeline orchestration: idempotent multi-step processing with resume support.
* Project scaffolding: `sci_create_project()` for workflowr-based SCI studies.
