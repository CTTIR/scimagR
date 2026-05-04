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
#' \dontrun{
#' ggplot(df, aes(x, y, colour = phase)) + geom_point() + scale_colour_phase()
#' }
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
scale_colour_modality <- function(...) {
  ggplot2::scale_colour_manual(values = pal_modality, ...)
}

#' @rdname scale_modality
#' @export
scale_fill_modality <- function(...) {
  ggplot2::scale_fill_manual(values = pal_modality, ...)
}
