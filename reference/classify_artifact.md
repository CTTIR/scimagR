# Classify MRI Artifact Grade

Maps integer grades 0–4 to an ordered factor:

- 0: none

- 1: mild

- 2: moderate

- 3: severe

- 4: non-evaluable

## Usage

``` r
classify_artifact(grade)
```

## Arguments

- grade:

  Integer vector (0–4). Values outside this range produce `NA` with a
  warning.

## Value

Ordered factor with 5 levels: none \< mild \< moderate \< severe \<
non-evaluable.

## Examples

``` r
classify_artifact(c(0, 1, 2, 3, 4))
#>             0             1             2             3             4 
#>          none          mild      moderate        severe non-evaluable 
#> Levels: none < mild < moderate < severe < non-evaluable
```
