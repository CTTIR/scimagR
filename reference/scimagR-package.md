# scimagR: Spinal Cord Injury Imaging Pipeline for MRI and CT Analysis

An end-to-end pipeline for longitudinal magnetic resonance imaging (MRI)
and computed tomography (CT) analysis in spinal cord injury (SCI)
research. Provides R wrappers for the 'Spinal Cord Toolbox' (SCT; De
Leener et al. (2017)
[doi:10.1016/j.neuroimage.2016.10.009](https://doi.org/10.1016/j.neuroimage.2016.10.009)
), including 'SCIsegV2' lesion segmentation, DICOM anonymization and
NIfTI conversion helpers built on 'pydicom' and 'dcm2niix', SCI-specific
clinical metrics (maximum spinal cord compression, compression ratio,
tissue bridge quantification), implant artifact grading, and pipeline
orchestration with built-in quality control. Integrates with 'workflowr'
for reproducible, publication-ready neuroimaging analyses. All external
tools are optional; the metrics, registry, quality-control and plotting
functions work without them.

## See also

Useful links:

- <https://github.com/CTTIR/scimagR>

- <https://cttir.github.io/scimagR/>

- Report bugs at <https://github.com/CTTIR/scimagR/issues>

## Author

**Maintainer**: R. Heller <raban.heller@uni-ulm.de>
([ORCID](https://orcid.org/0000-0001-8006-9742))

Authors:

- R. Heller <raban.heller@uni-ulm.de>
  ([ORCID](https://orcid.org/0000-0001-8006-9742))
