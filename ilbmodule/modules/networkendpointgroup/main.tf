# Deploy a gen1 or a gen2 cloud function based on the function_version input

# NEG for gen1 functions
resource "google_compute_region_network_endpoint_group" "neg" {
  for_each              = var.function_version == "v1" ? toset(var.regions) : toset([])
  name                  = "neg-${lower(trimspace(var.function_name))}"
  network_endpoint_type = "SERVERLESS"
  region                = each.key
  project               = var.project_id
  cloud_function {
    function = "${var.function_name}__${replace(each.key, "-", "_")}"
  }
  # Prevent resourceInUseByAnotherResource
  # lifecycle {
  #   create_before_destroy = true
  # }
}

# NEG for gen2 functions
locals {
  
  # => Addresses the name unicity across gen1 and gen2 functions
  # => Shortens function names that are limited to 63 chars
  region_short_names = {
    "northamerica-northeast1" = "ne1"
    "northamerica-northeast2" = "ne2"
    "us-central1"             = "uc1"
  }
}

resource "google_compute_region_network_endpoint_group" "neg_v2" {
  for_each              = var.function_version == "v2" ? toset(var.regions) : toset([])
  name                  = "neg-${lower(trimspace(var.function_name))}-v2" # Need to distinguish from existing NEGs on gen1 functions
  network_endpoint_type = "SERVERLESS"
  region                = each.key
  project               = var.project_id
  cloud_run {
    service = "${lower(trimspace(var.function_name))}--${local.region_short_names[each.key]}" # Must match the Cloud Run service name
  }
  # Prevent resourceInUseByAnotherResource
  lifecycle {
    create_before_destroy = true
  }
}
