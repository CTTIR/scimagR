#' Colour and Fill Scales for SCI Phases
#'
#' Convenience wrappers around [ggplot2::scale_colour_manual()] and
#' [ggplot2::scale_fill_manual()] using [pal_phase].
#'
#' @param ... Additional arguments passed to
#'   [ggplot2::scale_colour_manual()] / [ggplot2::scale_fill_manual()].
#' @return A ggplot2 scale object.
#' @name scale_phase
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(
#'   days = c(3, 40, 150, 400),
#'   csa = c(70, 64, 60, 58),
#'   phase = c("acute", "subacute", "intermediate", "chronic")
#' )
#' ggplot(df, aes(days, csa, colour = phase)) +
#'   geom_point(size = 3) +
#'   scale_colour_phase()
scale_colour_phase <- function(...) {
  ggplot2::scale_colour_manual(values = pal_phase, ...)
}

#' @rdname scale_phase
#' @export
scale_fill_phase <- function(...) {
  ggplot2::scale_fill_manual(values = pal_phase, ...)
}

#' Colour and Fill Scales for Artifact Grades
#'
#' @param ... Additional arguments passed to
#'   [ggplot2::scale_colour_manual()] / [ggplot2::scale_fill_manual()].
#' @return A ggplot2 scale object.
#' @name scale_artifact
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(grade = c("none", "mild", "moderate", "severe"),
#'                  n = c(12, 7, 3, 1))
#' ggplot(df, aes(grade, n, fill = grade)) +
#'   geom_col() +
#'   scale_fill_artifact()
scale_colour_artifact <- function(...) {
  ggplot2::scale_colour_manual(values = pal_artifact, ...)
}

#' @rdname scale_artifact
#' @export
scale_fill_artifact <- function(...) {
  ggplot2::scale_fill_manual(values = pal_artifact, ...)
}

#' Colour and Fill Scales for Imaging Modalities
#'
#' @param ... Additional arguments passed to
#'   [ggplot2::scale_colour_manual()] / [ggplot2::scale_fill_manual()].
#' @return A ggplot2 scale object.
#' @name scale_modality
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(modality = c("CT", "MRT", "CT+MRT"), n = c(5, 14, 3))
#' ggplot(df, aes(modality, n, fill = modality)) +
#'   geom_col() +
#'   scale_fill_modality()
scale_colour_modality <- function(...) {
  ggplot2::scale_colour_manual(values = pal_modality, ...)
}

#' @rdname scale_modality
#' @export
scale_fill_modality <- function(...) {
  ggplot2::scale_fill_manual(values = pal_modality, ...)
}
