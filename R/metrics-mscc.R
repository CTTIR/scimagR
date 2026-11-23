#' Compute Maximum Spinal Cord Compression (MSCC)
#'
#' Calculates MSCC as defined by Fehlings et al. (1999):
#' \deqn{MSCC = (1 - d_i / ((d_a + d_b) / 2)) \times 100}
#'
#' All arguments are vectorised, so the function can be used inside
#' [dplyr::mutate()] on registry columns. An argument of length 1 is
#' recycled to the length of the others; any other mismatch of lengths is
#' an error.
#'
#' @param di Numeric. Sagittal AP diameter at injury level (mm).
#' @param da Numeric. Sagittal AP diameter one level above (mm).
#' @param db Numeric. Sagittal AP diameter one level below (mm).
#' @return Numeric vector of MSCC percentages. An element is `NA` if any of
#'   its inputs is `NA` or if its reference diameter (`(da + db) / 2`) is
#'   <= 0.
#' @references Fehlings MG, Rao SC, Tator CH, et al. (1999). The optimal
#'   radiologic method for assessing spinal canal compromise and cord
#'   compression in patients with cervical spinal cord injury. Part II:
#'   Results of a multicenter study. *Spine* 24(6):605--613
#'   (MSCC definition in the Methods). \doi{10.1097/00007632-199903150-00023}
#' @export
#' @examples
#' compute_mscc(di = 5.2, da = 8.1, db = 8.5)
#' compute_mscc(di = 0, da = 8, db = 8) # 100% compression
#'
#' # Vectorised: one value per measurement
#' compute_mscc(di = c(5.2, 6.0, NA), da = c(8.1, 8.0, 8.2), db = 8.4)
compute_mscc <- function(di, da, db) {
  check_metric_inputs(di = di, da = da, db = db)

  ref <- (da + db) / 2
  out <- (1 - di / ref) * 100
  na_if_nonpositive(out, ref)
}

# Abort unless every argument is numeric (or all-NA logical) and the
# lengths can be recycled: each argument has length 1 or the common length
# (0 if any argument is empty), as in the tidyverse recycling rules.
check_metric_inputs <- function(..., call = rlang::caller_env()) {
  args <- list(...)
  ok <- vapply(
    args,
    function(x) is.numeric(x) || (is.logical(x) && all(is.na(x))),
    logical(1)
  )
  if (!all(ok)) {
    cli::cli_abort(
      "{.arg {names(args)[!ok]}} must be numeric.",
      class = "scimagR_error_input",
      call = call
    )
  }
  sizes <- lengths(args)
  common <- if (any(sizes == 0L)) 0L else max(sizes)
  bad <- !(sizes == 1L | sizes == common)
  if (any(bad)) {
    lens <- paste0(names(args), " = ", sizes, collapse = ", ")
    cli::cli_abort(
      c(
        "The inputs must have length 1 or a common length.",
        "i" = "Lengths: {lens}."
      ),
      class = "scimagR_error_input",
      call = call
    )
  }
  invisible(TRUE)
}

# Set `out` to NA where the reference (recycled to the length of `out`) is
# <= 0, and return it as double.
na_if_nonpositive <- function(out, ref) {
  out <- as.double(out)
  if (length(out) > 0L) {
    out[rep_len(!is.na(ref) & ref <= 0, length(out))] <- NA_real_
  }
  out
}
