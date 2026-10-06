# Introduction

[![R-install-check](https://github.com/CPM-Metabolomics-Lipidomics/FOS_tutorials/actions/workflows/install-check.yaml/badge.svg)](https://github.com/CPM-Metabolomics-Lipidomics/FOS_tutorials/actions/workflows/install-check.yaml)

This repository holds several `learnr` tutorials for the class **Multivariate Data Analysis** within the FOS-course of the LUMC.

The tutorials are bundled in the R package **FOStutorials** (in `inst/tutorials/`), and can also be served from a Docker container running a Shiny server.

# R package

## Installation

Install the package from GitHub. Some dependencies come from Bioconductor (`pcaMethods`, `mixOmics`, `ComplexHeatmap`); `pak` installs these automatically:

```r
install.packages("pak")
pak::pak("CPM-Metabolomics-Lipidomics/FOS_tutorials")
```

## Usage

```r
library(FOStutorials)

# which tutorials are available?
list_fos_tutorials()

# start a tutorial
run_fos_tutorial("Iris-dataset")
run_fos_tutorial("Food-dataset")
run_fos_tutorial("NMR_metabolomics")
```

The tutorials can also be started with `learnr::run_tutorial("Iris-dataset", package = "FOStutorials")`, or from the *Tutorial* pane in RStudio.

# Docker

To build the Docker container run:

```
docker build -t fos-course2026 .
```

Run the Docker container with (adjust port when needed):

```
docker run -d -p 3838:3838 fos-course2026
```

To access the tutorials go to `http://localhost:3838/FOS/2026/`
