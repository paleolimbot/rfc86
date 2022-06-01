
#' Read OGR using the Columnar API
#'
#' @param dsn A GDAL datsource name
#'
#' @export
#'
read_ogr_array_stream <- function(dsn) {
  stream_ptr <- narrow::narrow_allocate_array_stream()
  result <- cpp_read_ogr_stream(dsn, stream_ptr)

  # we need to modify this stream because GDAL uses the extension name
  # "WKB" instead of "geoarrow.wkb"
  schema <- narrow::narrow_array_stream_get_schema(stream_ptr)
  for (i in seq_along(schema$children)) {
    is_wkb <- identical(
      schema$children[[i]]$metadata[["ARROW:extension:name"]],
      "WKB"
    )
    if (is_wkb) {
      schema$children[[i]]$metadata[["ARROW:extension:name"]] <-
        "geoarrow.wkb"
      schema$children[[i]]$metadata[["ARROW:extension:metadata"]] <-
        geoarrow:::geoarrow_metadata_serialize(
          crs = result$crs
        )
    }
  }

  f <- function() {
    array <- narrow::narrow_array_stream_get_next(stream_ptr, validate = FALSE)
    if (is.null(array)) {
      return(NULL)
    }

    narrow::narrow_array(schema, array$array_data, validate = FALSE)
  }

  narrow::narrow_array_stream_function(schema, f, validate = FALSE)
}

#' @rdname read_ogr_array_stream
#' @export
read_ogr_table <- function(dsn) {
  requireNamespace("geoarrow", quietly = TRUE)
  stream <- read_ogr_array_stream(dsn)
  rbr <- narrow::narrow_array_stream_to_arrow(stream)
  rbr$read_table()
}

#' @rdname read_ogr_array_stream
#' @export
read_ogr_df <- function(dsn) {
  tibble::as_tibble(read_ogr_table(dsn))
}
