locals {
  config  = yamldecode(file("./configs/${var.env}/ilb.yaml"))
}

module "ilb" {
  source = "./ilbmodule/"

  google_project           = var.project_id
 // google_labels            = var.google_labels
  project_name             = var.project_name
  domain                   = var.hosts[0]
  glb_ip_address           = google_compute_address.cloudfunctionip.address
  url_map_name             = var.loadbalancername
  neg_regions              = var.neg_region_list
  //cloudarmorlink           = var.cloudarmorlink
  functions_map            = local.config
  default_backend_function = var.default_backend_function
}
