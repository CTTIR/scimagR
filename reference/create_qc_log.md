# Create a QC Segmentation Log

Creates an empty QC log tibble or reads an existing one from CSV.

## Usage

``` r
create_qc_log(path = NULL)
```

## Arguments

- path:

  Character. Optional path to existing QC log CSV.

## Value

Tibble with QC log columns: `pat_id`, `session`, `rater`, `date`,
`seg_type`, `quality`, `notes`.

## Examples

``` r
qc <- create_qc_log()
```
