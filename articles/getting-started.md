# Getting Started with scimagR

[![R-CMD-check](https://github.com/CTTIR/scimagR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CTTIR/scimagR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/CTTIR/scimagR/actions/workflows/pkgdown.yaml/badge.svg)](https://cttir.github.io/scimagR/)
[![CRAN
status](https://www.r-pkg.org/badges/version/scimagR)](https://CRAN.R-project.org/package=scimagR)
[![Codecov test
coverage](https://codecov.io/gh/CTTIR/scimagR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/CTTIR/scimagR?branch=main)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/scimagR)](https://cran.r-project.org/package=scimagR)
[![CRAN downloads
total](https://cranlogs.r-pkg.org/badges/grand-total/scimagR)](https://cran.r-project.org/package=scimagR)
[![License:
MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

### Overview

scimagR provides an end-to-end pipeline for longitudinal MRI and CT
analysis in spinal cord injury (SCI) research. This vignette walks you
through:

1.  Installing prerequisites
2.  Creating a new project
3.  Organizing your data
4.  Running the pipeline
5.  Analyzing results

### Prerequisites

scimagR requires the following external tools:

- **Spinal Cord Toolbox (SCT)** \>= 6.4: <https://spinalcordtoolbox.com>
- **dcm2niix**: <https://github.com/rordenlab/dcm2niix>
- **Python 3** with pydicom: `pip install pydicom`

Check that all tools are available:

``` r

library(scimagR)

check_sct()
check_dcm2niix()
check_pydicom()
```

### Creating a Project

Use
[`sci_create_project()`](https://cttir.github.io/scimagR/reference/sci_create_project.md)
to scaffold a new workflowr-based analysis project:

``` r

sci_create_project(
  path = "~/projects/my-sci-study",
  title = "Cervical SCI Longitudinal MRI Analysis",
  author = "Your Name"
)
```

This creates a complete directory structure with template files,
configuration, and analysis Rmd notebooks.

### Data Organization

Place your DICOM files in `data/raw/dicom/` following this structure:

    data/raw/dicom/
    ├── SCI001/
    │   ├── ses-01/
    │   │   └── *.dcm
    │   └── ses-02/
    │       └── *.dcm
    └── SCI002/
        └── ses-01/
            └── *.dcm

Fill in the CSV templates in `data/metadata/`:

- `imaging_registry.csv`: One row per imaging session
- `clinical_data.csv`: One row per patient

### Running the Pipeline

The pipeline orchestrates all processing steps:

``` r

sci_run_pipeline("~/projects/my-sci-study", steps = 1:8)
```

Check pipeline status at any time:

``` r

sci_pipeline_status("~/projects/my-sci-study")
```

### Computing SCI Metrics

scimagR includes validated implementations of common SCI metrics:

``` r

# Maximum Spinal Cord Compression
compute_mscc(di = 5.2, da = 8.1, db = 8.5)

# Compression ratio
compute_compression_ratio(ap = 6.5, transverse = 12.0)

# Phase classification
classify_phase(c(0, 5, 30, 200, 400))
```

### Visualization

Use the built-in theme and palettes for publication-ready figures:

``` r

library(ggplot2)

ggplot(data, aes(x = phase, y = mscc, fill = phase)) +
  geom_violin() +
  scale_fill_phase() +
  theme_sci()
```

## Use of LLM tools

Portions of this package were prepared with assistance from large
language model tooling for narrowly defined, non-authorial tasks:
copyediting, prose smoothing, Markdown/LaTeX formatting, scaffolding of
boilerplate files (CI configs, build scripts), code refactoring. The
tools used were [Chat
AI](https://kisski.gwdg.de/leistungen/2-02-llm-service/), the LLM
service of KISSKI (GWDG), and a self-hosted **Mistral Small (24B,
Apache-2.0)** run locally via [Ollama](https://ollama.com/) and the
`ollamar` R package — local inference only, with no data sent to third
parties for the self-hosted model.

All scientific claims, methodological choices, analyses,
interpretations, and conclusions are the author’s own. No LLM-generated
text was incorporated without review and revision, and every reference
was verified against its DOI, arXiv ID, or ISBN.
