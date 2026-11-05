# Dataset labels are text; only the popup layout should contain HTML.
heritage_popup <- function(name, detail_labels, detail_values, source) {
  escape <- function(value) htmltools::htmlEscape(as.character(value))
  details <- Map(function(label, value) {
    paste0(escape(label), ": ", escape(value), "<br>")
  }, detail_labels, detail_values)
  paste0("<b>", escape(name), "</b><br>",
         Reduce(paste0, details, init = ""), "(", escape(source), ")")
}
