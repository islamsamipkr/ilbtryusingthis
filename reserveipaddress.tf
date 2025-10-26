resource "google_compute_global_address" "cloudfunctionip" {
  name         = "global-${var.global_ip_address_name}-cloudfunction-ip"
  project      = var.project_id
  address_type = "INTERNAL"
  ip_version   = "IPV4"
purpose      = "GCE_ENDPOINT"

}
