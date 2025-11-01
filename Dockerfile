FROM rocker/shiny-verse:4.5.1
RUN install2.r duckdb \
    && R -q -e 'remotes::install_github("NCEAS/vegbankr", ref="develop")' \
    && rm -rf /tmp/downloaded_packages
