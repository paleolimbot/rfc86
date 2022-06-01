
test_that("read_ogr_array_stream() works", {
  file <- system.file("extdata/nc.gpkg", package = "rfc86")
  stream <- read_ogr_array_stream(file)
  expect_s3_class(stream, "narrow_array_stream")

  schema <- narrow::narrow_array_stream_get_schema(stream)
  expect_s3_class(schema, "narrow_schema")
  expect_identical(
    schema$children[[16]]$metadata[["ARROW:extension:name"]],
    "geoarrow.wkb"
  )
  meta <- schema$children[[16]]$metadata[["ARROW:extension:metadata"]]
  expect_match(
    rawToChar(meta[16:length(meta)]),
    "^GEOGCS"
  )
  expect_s3_class(
    narrow::narrow_array_stream_get_next(stream, validate = FALSE),
    "narrow_array"
  )
})

test_that("read_ogr_table() works", {
  file <- system.file("extdata/nc.gpkg", package = "rfc86")
  table <- read_ogr_table(file)
  expect_s3_class(table, "Table")
  expect_equal(table$num_rows, 100)
  expect_s3_class(table$geom$type, "GeoArrowType")
})

test_that("read_ogr_df() works", {
  file <- system.file("extdata/nc.gpkg", package = "rfc86")
  df <- read_ogr_df(file)
  expect_s3_class(df, "tbl_df")
  expect_s3_class(df$geom, "geoarrow_vctr")
})

test_that("read_ogr_sf() works", {
  file <- system.file("extdata/nc.gpkg", package = "rfc86")
  df <- read_ogr_sf(file)
  expect_s3_class(df, "sf")
  expect_s3_class(df$geom, "sfc")
  expect_true(sf::st_crs(df) != sf::NA_crs_)
})
