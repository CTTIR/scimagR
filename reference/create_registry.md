# Create an Imaging Registry from DICOM Metadata

Takes raw DICOM metadata (from
[`extract_dicom_metadata()`](https://cttir.github.io/scimagR/reference/extract_dicom_metadata.md)),
restructures it into a proper imaging registry with computed fields
(days_post_trauma, phase classification), and optionally saves to CSV.

## Usage

``` r
create_registry(dicom_meta, trauma_dates, op_dates = NULL, output_csv = NULL)
```

## Arguments

- dicom_meta:

  Data frame or character path to DICOM metadata CSV.

- trauma_dates:

  Named vector: names = pat_id, values = trauma date (Date or character
  coercible to Date).

- op_dates:

  Named vector: names = pat_id, values = OP date. Optional.

- output_csv:

  Character. Path to save registry. Optional.

## Value

Tibble with registry columns.

## Examples

``` r
# Metadata as returned by extract_dicom_metadata() (synthetic values).
meta <- data.frame(
  pat_id = c("SCI001", "SCI001", "SCI002"),
  session = c("ses-01", "ses-02", "ses-01"),
  study_date = c("2024-01-20", "2024-03-15", "2024-02-25"),
  modality = c("MRT", "MRT", "CT"),
  series_description = c("T2w_sag", "T2w_sag", "CT_cervical"),
  field_strength = c(3, 3, NA)
)
trauma <- c(SCI001 = "2024-01-15", SCI002 = "2024-02-20")
reg <- create_registry(meta, trauma)
reg
#> # A tibble: 3 × 9
#>   pat_id session study_date modality series_description field_strength
#>   <chr>  <chr>   <date>     <chr>    <chr>                       <dbl>
#> 1 SCI001 ses-01  2024-01-20 MRT      T2w_sag                         3
#> 2 SCI001 ses-02  2024-03-15 MRT      T2w_sag                         3
#> 3 SCI002 ses-01  2024-02-25 CT       CT_cervical                    NA
#> # ℹ 3 more variables: trauma_date <date>, days_post_trauma <int>, phase <ord>
```
