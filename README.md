
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rfc86

<!-- badges: start -->
<!-- badges: end -->

The goal of rfc86 is to add some benchmarks for reading files via the
[proposed GDAL columnar
API](https://github.com/rouault/gdal/blob/rfc_86/doc/source/development/rfc/rfc86_column_oriented_api.rst).

## Installation

You can install the development version of rfc86 from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("paleolimbot/rfc86")
```

To use it you will have to build GDAL from source against the [prototype
implementation](https://github.com/rouault/gdal/tree/arrow_batch_new).

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(rfc86)
library(geoarrow)
library(sf)
#> Linking to GEOS 3.8.0, GDAL 3.6.0dev-8143054ca0, PROJ 6.3.1; sf_use_s2() is TRUE

if (!file.exists("nshn_water_line.parquet")) {
  curl::curl_download(
    "https://github.com/paleolimbot/geoarrow-data/releases/download/v0.0.1/nshn_water_line.parquet",
    "nshn_water_line.parquet"
  )
  
  curl::curl_download(
    "https://github.com/paleolimbot/geoarrow-data/releases/download/v0.0.1/nshn_water_line.gpkg",
    "nshn_water_line.gpkg"
  )
  
  system("ogr2ogr nshn_water_line.fgb nshn_water_line.gpkg")
}

system.time(read_ogr_table("nshn_water_line.gpkg"))
#>    user  system elapsed 
#>   2.201   0.465   2.667
system.time(read_ogr_table("nshn_water_line.fgb"))
#>    user  system elapsed 
#>   3.810   0.428   4.238
system.time(read_ogr_sf("nshn_water_line.gpkg"))
#>    user  system elapsed 
#>   4.567   0.564   5.129
system.time(read_sf("nshn_water_line.gpkg"))
#>    user  system elapsed 
#>  18.528   0.684  19.212

system.time(read_ogr_table("nshn_water_line.parquet"))
#>    user  system elapsed 
#>   2.226   0.400   2.643
system.time(arrow::read_parquet("nshn_water_line.parquet"))
#>    user  system elapsed 
#>   2.135   0.605   2.503
```

``` r
# validate the output
table <- read_ogr_table("nshn_water_line.fgb")
table$ValidateFull()
#> [1] TRUE

table <- read_ogr_table("nshn_water_line.gpkg")
table$ValidateFull()
#> [1] TRUE

table <- read_ogr_table("nshn_water_line.parquet")
table$ValidateFull()
#> [1] TRUE
```

Files from <https://github.com/paleolimbot/geoarrow-data/>

``` r
files <- list.files("../geoarrow-public-data/release-files", full.names = TRUE)
for (f in files) {
  message(sprintf("Checking '%s'...", basename(f)), appendLF = FALSE)
  table <- read_ogr_table(f)
  message(sprintf("%s...", table$ValidateFull()), appendLF = FALSE)
  
  tf <- tempfile(fileext = ".feather")
  arrow::write_feather(table, tf)
  table <- read_ogr_table(tf)
  message(sprintf("feather: %s", table$ValidateFull()))
  unlink(tf)
}
```

(All files pass individually but I can get a crash if I try to read them
all sequentially)
