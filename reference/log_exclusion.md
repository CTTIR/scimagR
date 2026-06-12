# Log an Exclusion Step

Records before/after row counts and reason for an exclusion step. Useful
for building a CONSORT-style exclusion flow.

## Usage

``` r
log_exclusion(step, n_before, n_after, reason = "")
```

## Arguments

- step:

  Character. Name of the exclusion step.

- n_before:

  Integer. Row count before filtering.

- n_after:

  Integer. Row count after filtering.

- reason:

  Character. Reason for exclusion.

## Value

A 1-row tibble with columns: `step`, `n_before`, `n_after`,
`n_excluded`, `reason`.

## Examples

``` r
log_exclusion("Artifact filter", 100, 85, "artifact_grade > 2")
#> # A tibble: 1 × 5
#>   step            n_before n_after n_excluded reason            
#>   <chr>              <int>   <int>      <int> <chr>             
#> 1 Artifact filter      100      85         15 artifact_grade > 2
```
