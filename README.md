# scimagR <picture class="cttir-readme-logo"><source class="cttir-logo-dark-source" media="(prefers-color-scheme: dark)" srcset="man/figures/logo-with-name-dark.png" /><img src="man/figures/logo-with-name.png" align="right" alt="scimagR hex logo" width="120" height="139" /></picture>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21889958.svg)](https://doi.org/10.5281/zenodo.21889958)

<!-- badges: start -->
[![R-CMD-check](https://github.com/CTTIR/scimagR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CTTIR/scimagR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/CTTIR/scimagR/actions/workflows/pkgdown.yaml/badge.svg)](https://cttir.github.io/scimagR/)
[![Codecov test coverage](https://codecov.io/gh/CTTIR/scimagR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/CTTIR/scimagR?branch=main)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

An end-to-end R pipeline for longitudinal MRI and CT analysis in spinal cord
injury (SCI) research. Provides R wrappers for the Spinal Cord Toolbox (SCT),
DICOM tools, SCI-specific clinical metrics, and pipeline orchestration with
built-in quality control.

## Installation

Install from GitHub:

```r
# install.packages("pak")
pak::pak("cttir/scimagR")
```

## Prerequisites

scimagR requires the following external tools:

| Tool | Version | Purpose |
|------|---------|---------|
| [Spinal Cord Toolbox](https://spinalcordtoolbox.com) | >= 6.4 | Segmentation, labeling, parameter extraction |
| [dcm2niix](https://github.com/rordenlab/dcm2niix) | any | DICOM to NIfTI conversion |
| Python 3 + pydicom | any | DICOM metadata extraction & anonymization |

Verify installation:

```r
library(scimagR)
check_sct()
check_dcm2niix()
check_pydicom()
```

## Quick Start

```r
library(scimagR)

# 1. Create a new project
sci_create_project(
  "~/projects/my-sci-study",
  title = "Cervical SCI Longitudinal MRI",
  author = "Your Name"
)

# 2. Place DICOMs in data/raw/dicom/, fill registry CSVs

# 3. Run the pipeline
sci_run_pipeline("~/projects/my-sci-study")
```

## Modules

| Module | Key Functions | Description |
|--------|---------------|-------------|
| **SCT Interface** | `sct_segment_sc()`, `sct_segment_lesion()`, `sct_label_vertebrae()` | R wrappers for all SCT CLI commands |
| **DICOM Tools** | `extract_dicom_metadata()`, `anonymize_dicom()`, `convert_dcm2niix()` | Metadata extraction, anonymization, conversion |
| **SCI Metrics** | `compute_mscc()`, `compute_compression_ratio()`, `classify_phase()` | Domain-specific clinical measures |
| **Registry** | `create_registry()`, `validate_registry()`, `coverage_matrix()` | Structured time-point tracking |
| **QC System** | `filter_evaluable()`, `log_exclusion()`, `integrity_summary()` | Artifact grading and exclusion tracking |
| **Visualization** | `theme_sci()`, `scale_colour_phase()`, `plot_violin_box()` | Publication-ready figures |
| **Pipeline** | `sci_run_pipeline()`, `sci_pipeline_status()` | Orchestration with resume support |
| **Scaffold** | `sci_create_project()` | Workflowr project setup |

## Citation

If you use scimagR in your research, please cite:

```
Heller R (2026). scimagR: Spinal Cord Injury Imaging Pipeline for MRI and
CT Analysis in R. R package version 0.1.0.
https://github.com/cttir/scimagR
```

## License

MIT

## Use of LLM tools

Where applicable, LLM tools were used for narrowly defined, non-authorial tasks:
copyediting, prose refinement, Markdown/LaTeX formatting, boilerplate scaffolding
(such as CI configurations and build scripts), and code refactoring. Tools included
[Chat AI](https://kisski.gwdg.de/leistungen/2-02-llm-service/), the KISSKI
(GWDG) service, and self-hosted **Mistral Small (24B, Apache-2.0)** served through
a local **vLLM architecture** on an Ubuntu Linux workstation with Intel
processors and NVIDIA GPUs. The self-hosted model ran locally, with no data sent
to third parties.

All scientific claims, methodological choices, analyses, interpretations and
conclusions remain the authors' own. Where applicable, LLM-generated material
must be reviewed and revised before inclusion, and references must be verified
against their DOI, arXiv ID or ISBN.

Local software setup: vLLM with Python/PyTorch, plus R and RStudio.

## Branding

Editable R artwork and regeneration instructions are in [tools/branding](https://github.com/CTTIR/scimagR/blob/main/tools/branding/README.md).
