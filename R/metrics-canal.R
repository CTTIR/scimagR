#' Compute Spinal Cord Compression Ratio
#'
#' Calculates the anteroposterior compression ratio of the spinal cord, the
#' ratio of its anterior-posterior (sagittal) diameter to its transverse
#' diameter (Ogino et al. 1983). Vectorised over both arguments; an
#' argument of length 1 is recycled, other length mismatches are an error.
#'
#' @param ap Numeric. Anterior-posterior diameter (mm).
#' @param transverse Numeric. Transverse diameter (mm).
#' @return Numeric vector of compression ratios (unitless). An element is
#'   `NA` if `transverse` <= 0 or any of its inputs is `NA`.
#' @references Ogino H, Tada K, Okada K, et al. (1983). Canal diameter,
#'   anteroposterior compression ratio, and spondylotic myelopathy of the
#'   cervical spine. *Spine* 8(1):1--15. \doi{10.1097/00007632-198301000-00001}
#' @export
#' @examples
#' compute_compression_ratio(ap = 6.5, transverse = 12.0)
#' compute_compression_ratio(ap = c(6.5, 7.1), transverse = c(12.0, 11.4))
compute_compression_ratio <- function(ap, transverse) {
  check_metric_inputs(ap = ap, transverse = transverse)

  out <- ap / transverse
  na_if_nonpositive(out, transverse)
}

#' Compute Cross-Sectional Area Ratio
#'
#' Calculates the ratio of CSA at the injury level to the reference CSA
#' (average of adjacent levels). Vectorised over all arguments; an argument
#' of length 1 is recycled, other length mismatches are an error.
#'
#' @param csa_injury Numeric. CSA at injury level (mm^2).
#' @param csa_above Numeric. CSA one level above (mm^2).
#' @param csa_below Numeric. CSA one level below (mm^2).
#' @return Numeric vector of CSA ratios (unitless). An element is `NA` if
#'   its reference is <= 0 or any of its inputs is `NA`.
#' @export
#' @examples
#' compute_csa_ratio(csa_injury = 45, csa_above = 70, csa_below = 72)
#' compute_csa_ratio(csa_injury = c(45, 60), csa_above = 70, csa_below = 72)
compute_csa_ratio <- function(csa_injury, csa_above, csa_below) {
  check_metric_inputs(
    csa_injury = csa_injury, csa_above = csa_above, csa_below = csa_below
  )

  ref <- (csa_above + csa_below) / 2
  out <- csa_injury / ref
  na_if_nonpositive(out, ref)
}
