# The packages below are only used inside the tutorials (inst/tutorials), not
# in the R code of this package. They are listed under Imports so that
# installing FOStutorials also installs everything the tutorials need.
# Referencing them here keeps R CMD check from noting that they are unused.
# This function is never called.
ignore_unused_imports <- function() {
  circlize::colorRamp2
  ComplexHeatmap::Heatmap
  corrplot::corrplot
  dplyr::mutate
  DT::datatable
  factoextra::fviz_pca_biplot
  ggplot2::ggplot
  knitr::kable
  mixOmics::plsda
  pcaMethods::pca
  plotly::ggplotly
  pls::plsr
  readxl::read_excel
  rmarkdown::render
  shiny::runApp
  tidyr::pivot_longer
}
