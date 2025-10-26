
#--------------------------------------------------------------------------------------
# 1. Global static IP
#--------------------------------------------------------------------------------------

# IP address created with google_compute_global_address is automatically static and reserved
# Global external IPv4 addresses always use Premium Tier
# resource "google_compute_global_address" "cloudfunctionip" {
#   name         = "global-${var.project_name}-cloudfunction-ip"
#   project      = var.google_project
#   labels       = var.google_labels
#   address_type = "EXTERNAL"
#   ip_version   = "IPV4"
# }

#--------------------------------------------------------------------------------------
# 2. Managed SSL certificate
#--------------------------------------------------------------------------------------

resource "google_compute_managed_ssl_certificate" "managedcertificate" {
  project = var.google_project
  name    = "${var.project_name}-googlemanagedcertificate"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = [var.domain]
  }
}

#--------------------------------------------------------------------------------------
# 3. SSL policy
#--------------------------------------------------------------------------------------

resource "google_compute_ssl_policy" "restrictedsslpolicy" {
  name            = "${var.project_name}-ssl-policy"
  project         = var.google_project
  profile         = "RESTRICTED"
  min_tls_version = "TLS_1_2"
}

#--------------------------------------------------------------------------------------
# 4. Regional Network Endpoint Groups
#--------------------------------------------------------------------------------------

module "neg" {
  source   = "./modules/networkendpointgroup"
  for_each = var.functions_map

  regions          = var.neg_regions
  project_id       = var.google_project
  function_name    = each.key
  function_version = each.value.version
}

#--------------------------------------------------------------------------------------
# 5. Backend service
#--------------------------------------------------------------------------------------

resource "google_compute_backend_service" "mobilitybackendservice" {
  for_each = module.neg

  connection_draining_timeout_sec = 0
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  name                            = "backend-${lower(trimspace(each.value.function_name))}"
  port_name                       = "http"
  project                         = var.google_project
  protocol                        = "HTTPS"
  session_affinity                = "NONE"
  timeout_sec                     = 30
  log_config {
    enable      = true
    sample_rate = 1.0
  }

  # The below security policy is from cloudarmorfactory
  security_policy = var.cloudarmorlink

  dynamic "backend" {
    for_each = each.value.neg_self_links
    content {
      group = backend.value
    }
  }
  # Prevent resourceInUseByAnotherResource
  # lifecycle {
  #   create_before_destroy = true
  # }
}

#--------------------------------------------------------------------------------------
# 6. URL map
#--------------------------------------------------------------------------------------

locals {
  # In order to simplify the migration of legacy load balancer code, we allow to override
  # the URL Map name (named from the `loadbalancername` variable)
  # If the override is not used, variable url_map_name is null and needs to be set
  actual_url_map_name = var.url_map_name == null ? "${var.project_name}-httpsserverless-loadbalancer" : var.url_map_name
}

resource "google_compute_url_map" "serverlesshttploadbalancerfrontend" {
  project         = var.google_project
  name            = local.actual_url_map_name
  default_service = google_compute_backend_service.mobilitybackendservice[var.default_backend_function].self_link

  host_rule {
    hosts        = [var.domain]
    path_matcher = "path-matcher"
  }

  path_matcher {
    name            = "path-matcher"
    default_service = google_compute_backend_service.mobilitybackendservice[var.default_backend_function].self_link

    dynamic "path_rule" {
      for_each = google_compute_backend_service.mobilitybackendservice
      content {
        paths   = ["/${lower(path_rule.key)}"] # Path is based on lowercase function name
        service = path_rule.value.self_link
      }
    }
  }
  # https://github.com/hashicorp/terraform-provider-google/pull/22444
  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------------------------------
# 7. HTTPS proxy
#--------------------------------------------------------------------------------------

resource "google_compute_target_https_proxy" "default" {
  project = var.google_project
  name    = "mobility-https-proxy"
  # Attach the URL map
  url_map          = google_compute_url_map.serverlesshttploadbalancerfrontend.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.managedcertificate.id]
  ssl_policy       = google_compute_ssl_policy.restrictedsslpolicy.name

}

#--------------------------------------------------------------------------------------
# 8. Global forwarding rule
#--------------------------------------------------------------------------------------

resource "google_compute_global_forwarding_rule" "serverlesshttploadbalancerfrontend" {
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = "frontend"
  ip_address            = var.glb_ip_address # google_compute_global_address.cloudfunctionip.address
  port_range            = "443-443"
  project               = var.google_project
 // labels                = module.resource_labels.labels
  target                = google_compute_target_https_proxy.default.self_link
}
