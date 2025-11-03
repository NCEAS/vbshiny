FROM rocker/shiny-verse:4.5.1
LABEL org.opencontainers.image.source="https://github.com/NCEAS/vbshiny"
LABEL org.opencontainers.image.title="VegBank Shiny"
LABEL org.opencontainers.image.version="0.0.1"
RUN install2.r duckdb DT \
    && R -q -e 'remotes::install_github("NCEAS/vegbankr", ref="develop")' \
    && rm -rf /tmp/downloaded_packages
