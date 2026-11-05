# Run from the repository root: Rscript --vanilla tests/smoke.R
app <- new.env(parent = globalenv())
sys.source("app.R", envir = app)

popup <- app$heritage_popup(
  c("A & B", "<img src=x onerror=alert(1)>"),
  c("Category", "Country"),
  list(c("Cultural", "<script>bad()</script>"), c("X", "Y")),
  "UNESCO Site"
)
stopifnot(
  length(popup) == 2L,
  identical(popup[1], "<b>A &amp; B</b><br>Category: Cultural<br>Country: X<br>(UNESCO Site)"),
  grepl("&lt;img", popup[2], fixed = TRUE),
  grepl("&lt;script&gt;", popup[2], fixed = TRUE),
  !grepl("<img|<script", popup[2])
)

sites <- app$all_sites_df
stopifnot(
  all(c("name", "is_unesco", "region_group", "category", "type", "lon", "lat") %in% names(sites)),
  all(is.na(sites$lon) | (sites$lon >= -180 & sites$lon <= 180)),
  all(is.na(sites$lat) | (sites$lat >= -90 & sites$lat <= 90))
)

shiny::testServer(app$server, {
  session$setInputs(
    regionSelect = "Africa", unescoType = c("Cultural", "Natural", "Mixed"),
    nonType = c("museum", "archaeological_site", "monument", "memorial", "ruins", "attraction"),
    toggleUNESCO = TRUE, toggleNon = TRUE, aggLevel = "Region",
    regionFilter = "Africa", numericVar = "Year Inscribed", distRegionFilter = "Africa"
  )
  stopifnot(nrow(UNESCO_filtered()) > 0L, nrow(nonUNESCO_filtered()) > 0L)
  stopifnot(all(UNESCO_filtered()$region_group == "Africa"))
  stopifnot(!anyNA(UNESCO_filtered()$lon), !anyNA(UNESCO_filtered()$lat))
  stopifnot(!is.null(output$map), !is.null(output$barPlot), !is.null(output$distPlot))
  session$setInputs(aggLevel = "Country", numericVar = "Area (hectares)")
  stopifnot(!is.null(output$barPlot), !is.null(output$distPlot))
  session$setInputs(regionSelect = character(0), toggleUNESCO = FALSE, toggleNon = FALSE)
  stopifnot(nrow(UNESCO_filtered()) == 0L, nrow(nonUNESCO_filtered()) == 0L)
  stopifnot(!is.null(output$map))
})
cat("Popup escaping, dataset schema/coordinates and Shiny map/chart smoke checks passed.\n")
