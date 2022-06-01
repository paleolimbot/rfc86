#include <cpp11.hpp>
using namespace cpp11;

#include "narrow.h"

#include "ogr_api.h"
#include "ogrsf_frmts.h"

[[cpp11::register]]
void cpp_init_gdal() {
  GDALAllRegister();
}

[[cpp11::register]]
list cpp_read_ogr_stream(std::string dsn, sexp stream_xptr) {

  auto stream = reinterpret_cast<struct ArrowArrayStream*>(
    R_ExternalPtrAddr(stream_xptr));

  GDALDataset* poDS = GDALDataset::Open(dsn.c_str());
  if (poDS == nullptr) {
    stop("Failed to open dataset '%s'", dsn);
  }

  external_pointer<GDALDataset> dataset_xptr(poDS);

  OGRLayer* poLayer = poDS->GetLayer(0);
  if (poLayer == nullptr) {
    stop("Failed to open first layer");
  }

  OGRSpatialReference* crs = poLayer->GetSpatialRef();
  char* wkt_out;
  crs->exportToWkt(&wkt_out);
  std::string wkt_str(wkt_out);
  CPLFree(wkt_out);

  OGRLayerH hLayer = OGRLayer::ToHandle(poLayer);

  if (!OGR_L_GetArrowStream(hLayer, stream, nullptr)) {
    stop("Failed to open ArrayStream from Layer");
  }

  // make sure the dataset stays alive while the array stream is alive
  R_SetExternalPtrTag(stream_xptr, dataset_xptr);

  // pass along crs as an attribute
  writable::list out = {stream_xptr, as_sexp(wkt_str)};
  out.names() = {"stream", "crs"};
  return out;
}
