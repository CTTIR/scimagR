#' SCI Publication Theme
#'
#' A clean ggplot2 theme based on [ggplot2::theme_bw()], optimized for
#' publication-ready neuroimaging figures, with no minor gridlines and a
#' bottom legend.
#'
#' @param base_size Numeric. Base font size. Default `11`.
#' @param base_family Character. Base font family. Default `""`, the
#'   device's standard sans-serif font (Helvetica or Arial on most systems),
#'   which works on every graphics device. Set `"Arial"` explicitly for
#'   devices that can use installed system fonts (e.g. `ragg` or Cairo PNG);
#'   the base `pdf()` device does not know this family.
#' @return A ggplot2 theme object.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_sci()
theme_sci <- function(base_size = 11, base_family = "") {
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      strip.background = ggplot2::element_rect(fill = "grey95", colour = NA),
      strip.text = ggplot2::element_text(face = "bold"),
      plot.title = ggplot2::element_text(face = "bold", size = base_size + 2),
      plot.subtitle = ggplot2::element_text(colour = "grey40")
    )
}

#' SCI Phase Colour Palette
#'
#' Named character vector of 5 viridis-derived colours for SCI phases:
#' hyperacute, acute, subacute, intermediate, chronic.
#'
#' @format A named character vector of hexadecimal colour codes.
#' @export
#' @examples
#' pal_phase
pal_phase <- stats::setNames(
  viridisLite::viridis(5, option = "D"),
  c("hyperacute", "acute", "subacute", "intermediate", "chronic")
)

#' Artifact Grade Colour Palette
#'
#' Named character vector of 5 colours for MRI artifact grades:
#' none (green), mild (yellow), moderate (orange), severe (red),
#' non-evaluable (grey).
#'
#' @format A named character vector of hexadecimal colour codes.
#' @export
#' @examples
#' pal_artifact
pal_artifact <- c(
  "none"           = "#4CAF50",
  "mild"           = "#FFC107",
  "moderate"       = "#FF9800",
  "severe"         = "#F44336",
  "non-evaluable"  = "#9E9E9E"
)

#' Modality Colour Palette
#'
#' Named character vector of 3 colours for imaging modalities.
#'
#' @format A named character vector of hexadecimal colour codes.
#' @export
#' @examples
#' pal_modality
pal_modality <- c(
  "CT"      = "#2196F3",
  "MRT"     = "#E91E63",
  "CT+MRT"  = "#9C27B0"
)
