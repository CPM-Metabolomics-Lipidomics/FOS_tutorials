FROM rocker/shiny:4.6.1

# system dependencies for R packages
RUN apt-get update && apt-get install -y \
    pandoc \
 #   pandoc-citeproc \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libglpk-dev \
    vim \
    && apt-get clean

# Install R packages
RUN R -e "install.packages(c('shiny', 'learnr', 'rmarkdown', 'tidyverse', 'plotly', 'corrplot', 'DT', 'factoextra', 'gridExtra', 'circlize', 'BiocManager', 'knitr', 'pls'))"
RUN R -e "BiocManager::install(c('pcaMethods', 'mixOmics', 'ComplexHeatmap'))"

# install.packages() only WARNS about a package it cannot find (a typo in the
# list above would produce an image whose tutorials die on startup), so verify
# explicitly that everything the tutorials load is actually present.
RUN R -e "pkgs <- c('shiny','learnr','rmarkdown','ggplot2','dplyr','tidyr','readxl','plotly','corrplot','DT','factoextra','gridExtra','circlize','knitr','pls','pcaMethods','mixOmics','ComplexHeatmap'); \
          missing <- pkgs[!pkgs %in% rownames(installed.packages())]; \
          if (length(missing)) stop('Missing packages: ', paste(missing, collapse=', ')); \
          cat('All required packages present\n')"

# Copy the overview pages, and the tutorials (the source of the R package in
# inst/tutorials) into the year folder they are served from
COPY FOS/ /srv/FOS/
COPY inst/tutorials/ /srv/FOS/2026/

# Copy Shiny Server config
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Fix permissions
RUN chown -R shiny:shiny /srv/FOS

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
