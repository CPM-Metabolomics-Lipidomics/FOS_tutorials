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
RUN R -e "install.packages(c('shiny', 'learnr', 'rmarkdown', 'tidyverse', 'plotly', 'corrplot', 'DT', 'factoextra', 'FactomineR', 'BiocManager', 'knitr', 'pls'))"
RUN R -e "BiocManager::install(c('pcaMethods', 'mixOmics'))"

# Copy tutorials
COPY FOS/ /srv/FOS/

# Copy Shiny Server config
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Fix permissions
RUN chown -R shiny:shiny /srv/FOS

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
