# Classify SCI Phase Based on Days Post Trauma

Classification based on established SCI literature (Grassner et al.
2025, Freund et al. 2019):

- \<= 1 day: hyperacute

- 2–14 days: acute

- 15–90 days: subacute

- 91–365 days: intermediate

- more than 365 days: chronic

## Usage

``` r
classify_phase(days)
```

## Arguments

- days:

  Numeric vector. Days since trauma.

## Value

Ordered factor with 5 levels: hyperacute \< acute \< subacute \<
intermediate \< chronic.

## Examples

``` r
classify_phase(c(0, 5, 30, 200, 400))
#> [1] hyperacute   acute        subacute     intermediate chronic     
#> Levels: hyperacute < acute < subacute < intermediate < chronic
```
