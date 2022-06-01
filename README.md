
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
#> Linking to GEOS 3.8.0, GDAL 3.6.0dev-b3e1f326f8, PROJ 6.3.1; sf_use_s2() is TRUE
library(vapour)

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
#>   7.464   0.388   7.852
system.time(read_ogr_table("nshn_water_line.fgb"))
#>    user  system elapsed 
#>   3.683   0.440   4.123
system.time(read_ogr_sf("nshn_water_line.gpkg"))
#>    user  system elapsed 
#>   9.738   0.531  10.265
system.time(read_sf("nshn_water_line.gpkg"))
#>    user  system elapsed 
#>  18.913   0.609  19.523
system.time({
  vapour_read_attributes("nshn_water_line.gpkg")
  vapour_read_geometry("nshn_water_line.gpkg")
})
#>    user  system elapsed 
#>  14.089   0.464  14.552
system.time(arrow::read_parquet("nshn_water_line.parquet"))
#>    user  system elapsed 
#>   2.182   0.583   2.519
```
