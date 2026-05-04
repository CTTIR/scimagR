#' SCI Publication Theme
#'
#' A clean ggplot2 theme based on [ggplot2::theme_bw()], optimized for
#' publication-ready neuroimaging figures. Uses Arial font, no minor
#' gridlines, and a bottom legend.
#'
#' @param base_size Numeric. Base font size. Default `11`.
#' @param base_family Character. Base font family. Default `"Arial"`.
#' @return A ggplot2 theme object.
#' @export
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_sci()
#' }
theme_sci <- function(base_size = 11, base_family = "Arial") {
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
#' @export
#' @examples
#' pal_modality
pal_modality <- c(
  "CT"      = "#2196F3",
  "MRT"     = "#E91E63",
  "CT+MRT"  = "#9C27B0"
)
