# Introduction

[![R-install-check](https://github.com/CPM-Metabolomics-Lipidomics/FOS_tutorials/actions/workflows/install-check.yaml/badge.svg)](https://github.com/CPM-Metabolomics-Lipidomics/FOS_tutorials/actions/workflows/install-check.yaml)

This repository holds several `learnr` tutorials for the class **Multivariate Data Analysis** within the FOS-course of the LUMC.

The tutorials are bundled in the R package **FOStutorials** (in `inst/tutorials/`), and can also be served from a Docker container running a Shiny server.

# R package

## Installation

### System requirements (Linux)

On Ubuntu (tested on 26.04), install the following system packages before installing the R package:

```bash
sudo apt install libgl1-mesa-dev libglu1-mesa-dev pandoc texlive
```

### Install from GitHub

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
run_fos_tutorial("NMR-metabolomics")
```

The tutorials can also be started with `learnr::run_tutorial("Iris-dataset", package = "FOStutorials")`, or from the *Tutorial* pane in RStudio.

# shinyapps.io

The three tutorials can be deployed together as **one app** on [shinyapps.io](https://www.shinyapps.io): https://cpm-lumc.shinyapps.io/fos-tutorials/

shinyapps.io serves only one learnr tutorial per app, so `deploy_shinyapps.R` merges the three tutorials into a single one (*Iris*, *Food* and *NMR* topics in the left-hand menu). The merged tutorial is generated in `shinyapps/` every time you deploy; always edit the tutorials in `inst/tutorials/`, never the generated file.

## Deploy

From the root of this repository:

```bash
Rscript deploy_shinyapps.R
```

This builds and pre-renders the merged tutorial and uploads it; shinyapps.io then installs the same package versions (including the Bioconductor ones) as on your computer. The deployment record is written to `shinyapps/rsconnect/`; commit it, so a deployment from another computer updates the same app instead of creating a new one.

To try the merged tutorial locally first, only build it and run it:

```bash
Rscript deploy_shinyapps.R build
```

```r
learnr::run_tutorial("shinyapps")
```

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
