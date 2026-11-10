## Submission

This is a new submission of `scimagR` (version 0.2.0).

## Test environments

* local macOS (aarch64), R 4.6.1:
  `R CMD check --as-cran --no-manual` (the PDF manual was built locally
  with TinyTeX (TeX Live 2026) via `R CMD Rd2pdf` without errors; the check
  run itself used `--no-manual`)
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
  tests or vignettes on CRAN: tests replace the external calls with mocks,
  the vignettes are not evaluated, and the examples of the wrappers are in
  `\dontrun{}` with a comment explaining that they need the external tools
  and imaging data that cannot be shipped. `check_pydicom()` starts a
  Python interpreter if one is installed, so its example is in
  `\donttest{}`.
* All other functions (metrics, registry, quality control, plotting,
  export and project scaffolding) have runnable examples that use the
  bundled synthetic registry (`inst/extdata/example_registry.csv`) or
  inline synthetic data, and write only to `tempdir()`.
* The vignettes carry CRAN badges linking to
  <https://CRAN.R-project.org/package=scimagR>, which returns 404 until the
  package has been accepted; all other URLs resolve.
