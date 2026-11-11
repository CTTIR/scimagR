# scimagR 0.2.0

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
  export and project scaffolding). Examples of the wrappers around the
  Spinal Cord Toolbox, 'dcm2niix' and 'pydicom' stay in `\dontrun{}` with
  an explanation.
* `DESCRIPTION`: title without "in R", expanded description with a
  reference for the Spinal Cord Toolbox, optional `SystemRequirements`,
  `Language`, pkgdown URL and the maintainer's ORCID.
* Documented the colour palettes' format.

# scimagR 0.1.0

* Standardize the named v5 package logo across README, documentation pages
  and available application headers, with matching light and dark artwork.


* Initial release.
* SCT interface: R wrappers for spinal cord segmentation, lesion segmentation,
  vertebral labeling, and parameter extraction.
* DICOM tools: metadata extraction, anonymization, batch NIfTI conversion.
* SCI metrics: MSCC, compression ratio, CSA ratio, phase classification,
  artifact grading.
* Registry management: creation, validation, coverage matrix visualization.
* QC system: segmentation QC logging, evaluability filtering, exclusion tracking.
* Visualization: publication-ready theme, SCI-specific palettes and scales,
  standard plot types (violin-box, spaghetti, forest).
* Pipeline orchestration: idempotent multi-step processing with resume support.
* Project scaffolding: `sci_create_project()` for workflowr-based SCI studies.
