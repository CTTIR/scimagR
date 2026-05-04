#' Compute Maximum Spinal Cord Compression (MSCC)
#'
#' Calculates MSCC using the formula:
#' \deqn{MSCC = (1 - d_i / ((d_a + d_b) / 2)) \times 100}
#'
#' @param di Numeric. Sagittal AP diameter at injury level (mm).
#' @param da Numeric. Sagittal AP diameter one level above (mm).
#' @param db Numeric. Sagittal AP diameter one level below (mm).
#' @return Numeric. MSCC percentage. `NA` if any input is `NA` or if the
#'   reference diameter is <= 0.
#' @export
#' @examples
#' compute_mscc(di = 5.2, da = 8.1, db = 8.5)
#' compute_mscc(di = 0, da = 8, db = 8) # 100% compression
compute_mscc <- function(di, da, db) {
  if (anyNA(c(di, da, db))) {
    return(NA_real_)
  }

  ref <- (da + db) / 2
  if (ref <= 0) {
    return(NA_real_)
  }

  (1 - di / ref) * 100
}
