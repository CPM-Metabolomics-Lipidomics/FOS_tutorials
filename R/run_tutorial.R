#' List the FOS tutorials
#'
#' Lists the learnr tutorials included in this package.
#'
#' @return A data frame with the tutorial `name`, `title` and `description`.
#' @export
#'
#' @examples
#' list_fos_tutorials()
list_fos_tutorials <- function() {
  tutorials <- learnr::available_tutorials(package = "FOStutorials")
  as.data.frame(tutorials)[, c("name", "title", "description")]
}

#' Run a FOS tutorial
#'
#' Starts one of the learnr tutorials of the Multivariate Data Analysis class
#' in your browser (or in the RStudio viewer). Use [list_fos_tutorials()] to
#' see which tutorials are available.
#'
#' @param name Name of the tutorial, e.g. `"Iris-dataset"`, `"Food-dataset"`
#'   or `"NMR_metabolomics"`.
#' @param ... Further arguments passed on to [learnr::run_tutorial()].
#'
#' @return Called for its side effect of starting the tutorial.
#' @export
#'
#' @examples
#' \dontrun{
#' run_fos_tutorial("Iris-dataset")
#' }
run_fos_tutorial <- function(name, ...) {
  available <- learnr::available_tutorials(package = "FOStutorials")$name
  if (missing(name) || !is.character(name) || length(name) != 1 ||
      !name %in% available) {
    stop("`name` must be one of: ",
         paste0('"', available, '"', collapse = ", "),
         call. = FALSE)
  }
  learnr::run_tutorial(name, package = "FOStutorials", ...)
}
