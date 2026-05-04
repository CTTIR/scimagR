#' Compute Spinal Cord Compression Ratio
#'
#' Calculates the ratio of anterior-posterior to transverse diameter.
#'
#' @param ap Numeric. Anterior-posterior diameter (mm).
#' @param transverse Numeric. Transverse diameter (mm).
#' @return Numeric. Compression ratio (unitless). `NA` if `transverse` <= 0
#'   or any input is `NA`.
#' @export
#' @examples
#' compute_compression_ratio(ap = 6.5, transverse = 12.0)
compute_compression_ratio <- function(ap, transverse) {
  if (anyNA(c(ap, transverse))) {
    return(NA_real_)
  }
  if (transverse <= 0) {
    return(NA_real_)
  }
  ap / transverse
}

#' Compute Cross-Sectional Area Ratio
#'
#' Calculates the ratio of CSA at the injury level to the reference CSA
#' (average of adjacent levels).
#'
#' @param csa_injury Numeric. CSA at injury level (mm^2).
#' @param csa_above Numeric. CSA one level above (mm^2).
#' @param csa_below Numeric. CSA one level below (mm^2).
#' @return Numeric. CSA ratio (unitless). `NA` if reference is <= 0 or any
#'   input is `NA`.
#' @export
#' @examples
#' compute_csa_ratio(csa_injury = 45, csa_above = 70, csa_below = 72)
compute_csa_ratio <- function(csa_injury, csa_above, csa_below) {
  if (anyNA(c(csa_injury, csa_above, csa_below))) {
    return(NA_real_)
  }
  ref <- (csa_above + csa_below) / 2
  if (ref <= 0) {
    return(NA_real_)
  }
  csa_injury / ref
}
