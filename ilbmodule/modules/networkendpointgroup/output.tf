output "function_name" {
  value = var.function_name
}

output "function_version" {
  value = var.function_version
}

# Generic outputs
output "neg_ids" {
  value = merge(
    { for region, neg in google_compute_region_network_endpoint_group.neg : region => neg.id },
    { for region, neg in google_compute_region_network_endpoint_group.neg_v2 : region => neg.id }
  )
}

output "neg_self_links" {
  value = merge(
    { for region, neg in google_compute_region_network_endpoint_group.neg : region => neg.self_link },
    { for region, neg in google_compute_region_network_endpoint_group.neg_v2 : region => neg.self_link }
  )
}
