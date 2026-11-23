#' Classify SCI Phase Based on Days Post Trauma
#'
#' Classification based on established SCI literature
#' (Grassner et al. 2025, Freund et al. 2019):
#' - <= 1 day: hyperacute
#' - 2--14 days: acute
#' - 15--90 days: subacute
#' - 91--365 days: intermediate
#' - more than 365 days: chronic
#'
#' @param days Numeric vector. Days since trauma. Negative values (an
#'   imaging date before the trauma date) give `NA` with a warning.
#' @return Ordered factor with 5 levels: hyperacute < acute < subacute <
#'   intermediate < chronic.
#' @export
#' @examples
#' classify_phase(c(0, 5, 30, 200, 400))
classify_phase <- function(days) {
  check_metric_inputs(days = days)

  negative <- !is.na(days) & days < 0
  if (any(negative)) {
    cli::cli_warn(
      "Negative days since trauma are set to NA: {days[negative]}"
    )
    days[negative] <- NA
  }

  levels <- c("hyperacute", "acute", "subacute", "intermediate", "chronic")

  phase <- dplyr::case_when(
    is.na(days)  ~ NA_character_,
    days <= 1    ~ "hyperacute",
    days <= 14   ~ "acute",
    days <= 90   ~ "subacute",
    days <= 365  ~ "intermediate",
    TRUE         ~ "chronic"
  )

  factor(phase, levels = levels, ordered = TRUE)
}

#' Classify MRI Artefact Grade
#'
#' Maps integer grades 0--4 to an ordered factor:
#' - 0: none
#' - 1: mild
#' - 2: moderate
#' - 3: severe
#' - 4: non-evaluable
#'
#' @param grade Integer vector (0--4). Values outside this range, and values
#'   that are not whole numbers, produce `NA` with a warning.
#' @return Ordered factor with 5 levels: none < mild < moderate < severe <
#'   non-evaluable.
#' @export
#' @examples
#' classify_artifact(c(0, 1, 2, 3, 4))
classify_artifact <- function(grade) {
  check_metric_inputs(grade = grade)

  levels <- c("none", "mild", "moderate", "severe", "non-evaluable")
  labels_map <- stats::setNames(levels, as.character(0:4))

  out_of_range <- !is.na(grade) & (grade < 0 | grade > 4)
  if (any(out_of_range)) {
    cli::cli_warn(
      "Artefact grades outside 0-4 will be set to NA: {grade[out_of_range]}"
    )
  }
  fractional <- !is.na(grade) & !out_of_range & grade != round(grade)
  if (any(fractional)) {
    cli::cli_warn(
      "Artefact grades must be whole numbers; set to NA: {grade[fractional]}"
    )
  }
  out_of_range <- out_of_range | fractional

  result <- labels_map[as.character(grade)]
  result[out_of_range] <- NA_character_

  factor(result, levels = levels, ordered = TRUE)
}
