## Submission

This is a new submission of `scimagR` (version 0.2.0).

## Test environments

* Local: macOS (aarch64-apple-darwin), R 4.6.1, 14 November 2026:
  full `R CMD check --as-cran` on the built source tarball, including
  PDF manual compilation with TinyTeX (TeX Live 2026) and HTML manual
  validation. This supersedes the earlier local check environment.
* GitHub Actions (r-lib/actions v2, `--as-cran`):
  macos-latest (release), windows-latest (release),
  ubuntu-latest (devel, release, oldrel-1)

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  New submission

## Notes for CRAN

* The image-processing wrappers call external software that is declared in
  SystemRequirements and is optional: the Spinal Cord Toolbox, 'dcm2niix'
  and Python 3 with 'pydicom'. None of these is called during examples,
  tests or vignettes on CRAN: tests replace the external calls with mocks
  (tests that run 'pydicom' or 'dcm2niix' are skipped on CRAN), the
  vignette code that needs them is not evaluated, and the examples that
  call them are in `\donttest{}` and only run when `check_sct()`,
  `check_dcm2niix()` or `check_pydicom()` reports the tool as available
  (the slow deep-learning examples also need an interactive session).
  The wrappers also have examples that run without the tools.
  `check_pydicom()` starts a Python interpreter if one is installed, so its
  example is in `\donttest{}`.
* All other functions (metrics, registry, quality control, plotting,
  export and project scaffolding) have runnable examples that use the
  bundled synthetic registry (`inst/extdata/example_registry.csv`) or
  inline synthetic data, and write only to `tempdir()`. The DICOM examples
  use two synthetic 8 x 8 pixel DICOM slices (`inst/extdata/dicom/`,
  made by `data-raw/make_example_dicom.py`).
* The vignettes carry CRAN badges linking to
  <https://CRAN.R-project.org/package=scimagR>, which returns 404 until the
  package has been accepted; all other URLs resolve.
