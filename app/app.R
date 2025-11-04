library(shiny)
library(DT)
library(vegbankr)

vegbankr::set_vb_base_url("https://api-dev.vegbank.org")

PAGE_LENGTH <- 10L

plant_fields <- c(
  "plant_name",
  "current_accepted",
  "plant_level",
  "concept_rf_name",
  "obs_count",
  "plant_description"
)
plant_labels <- c(
  "Plant Name",
  "Current Accepted",
  "Level",
  "Reference Name",
  "Observation Count",
  "Description"
)

# zero-row data frame defining the DT column structure returned by the endpoint
empty_plant_df <- {
  cols <- stats::setNames(rep(list(character()), length(plant_fields)), plant_fields)
  as.data.frame(cols, stringsAsFactors = FALSE)
}

# Null-coalescing helper so we can fall back to defaults when VegBank omits fields
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) {
    return(y)
  }
  x
}

# Reuse DT's internal sanitiser to produce Ajax-friendly payloads
clean_for_dt <- get("cleanDataFrame", envir = asNamespace("DT"))

# Ensure each VegBank page has the expected columns and string data types
normalize_plants <- function(df, fields) {
  if (!is.data.frame(df)) {
    df <- as.data.frame(df, stringsAsFactors = FALSE)
  }
  if (!nrow(df)) {
    return(empty_plant_df[FALSE, ])
  }
  missing <- setdiff(fields, names(df))
  for (fld in missing) {
    df[[fld]] <- NA_character_
  }
  df <- df[, fields, drop = FALSE]
  df[] <- lapply(df, as.character)
  rownames(df) <- NULL
  df
}

# Pull the total record count advertised by VegBank's paging metadata
extract_reported_total <- function(details) {
  if (is.null(details)) {
    return(NA_integer_)
  }
  val <- details["count_reported"]
  if (is.null(val) || !length(val)) {
    return(NA_integer_)
  }
  suppressWarnings(total <- as.numeric(val[1]))
  if (is.na(total)) {
    return(NA_integer_)
  }
  as.integer(round(total))
}

# Request a single VegBank page while being resilient to intermittent API failures
fetch_plants_page <- function(limit, offset) {
  tryCatch(
    vegbankr::get_all_plant_concepts(limit = limit, offset = offset, parquet = FALSE),
    error = function(e) {
      warning("Failed to fetch plant concepts: ", conditionMessage(e))
      empty_plant_df[FALSE, ]
    }
  )
}

ui <- fluidPage(
  titlePanel("VegBank Plant Concepts"),
  sidebarLayout(
    sidebarPanel(
      p("This table pages directly against VegBank's plant concepts endpoint."),
      p("Sorting and searching are disabled because the API exposes only limit and offset parameters.")
    ),
    mainPanel(
      DTOutput("plants")
    )
  )
)

server <- function(input, output, session) {
  # Cache the total record count once per session to avoid redundant network calls
  total_cache <- new.env(parent = emptyenv())
  total_cache$count <- NULL

  # Translate DataTables paging parameters into VegBank API calls
  remote_filter <- function(data, params) {
    draw <- as.integer(params$draw %||% 0L)

    limit <- PAGE_LENGTH

    offset <- as.integer(params$start)
    if (is.na(offset) || offset < 0L) {
      offset <- 0L
    }

    page_raw <- fetch_plants_page(limit, offset)
    details <- tryCatch(vegbankr::get_page_details(page_raw), error = function(e) NULL)
    page_df <- normalize_plants(page_raw, plant_fields)

    reported_total <- extract_reported_total(details)
    if (is.null(total_cache$count) && !is.na(reported_total)) {
      total_cache$count <- reported_total
    }

    total_records <- total_cache$count
    if (is.null(total_records) || !length(total_records) || is.na(total_records)) {
      total_records <- reported_total
    }
    if (is.null(total_records) || !length(total_records) || is.na(total_records)) {
      total_records <- nrow(page_df)
    }
    total_records <- as.integer(round(total_records))

    list(
      draw = draw,
      recordsTotal = total_records,
      recordsFiltered = total_records,
      data = clean_for_dt(page_df)
    )
  }

  # Generate the ajax endpoint that DataTables will hit for every pagination request
  ajax_url <- dataTableAjax(
    session = session,
    data = empty_plant_df,
    filter = remote_filter,
    outputId = "plants"
  )

  output$plants <- renderDT({
    datatable(
      data = empty_plant_df,
      colnames = plant_labels,
      rownames = FALSE,
      options = list(
        serverSide = TRUE,
        processing = TRUE,
        deferRender = TRUE,
        ajax = list(url = ajax_url),
        pageLength = PAGE_LENGTH,
        lengthChange = FALSE,
        ordering = FALSE,
        searching = FALSE,
        dom = "tip"
      )
    )
  }, server = TRUE)
}

shinyApp(ui = ui, server = server)
