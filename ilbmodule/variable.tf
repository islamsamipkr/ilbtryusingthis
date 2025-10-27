variable "google_project" {
  type        = string
  description = "Google project **ID** where the load balancer will be deployed"
}

variable "project_name" {
  type        = string
  description = "Mobility project name"
}

//variable "google_labels" {
//  description = "Google labels to assign on the resources that will be created"
//  type        = map(string)
//}

variable "neg_regions" {
  type        = list(string)
  description = "List of regions to deploy the network endpoing group (NEG)"
  validation {
    condition     = alltrue([for k in var.neg_regions : contains(["northamerica-northeast1", "northamerica-northeast2", "us-central1"], k)])
    error_message = "The supported regions are `northamerica-northeast1`, `northamerica-northeast2` and `us-central1`"
  }
}

variable "cloudarmorlink" {
  type        = string
  description = "Cloud armor policy URL."
  default     = null
}

variable "domain" {
  type        = string
  description = "Domain name for the managed SSL certificate. Must be a fully qualified domain name (FQDN)."
  validation {
    condition     = can(regex("^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,}$", var.domain))
    error_message = "The value must be a valid fully qualified domain name (FQDN)."
  }
}

variable "glb_ip_address" {
  type        = string
  description = "Global Load Balancer ip address"
  validation {
    condition     = can(regex("^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))?$", var.glb_ip_address))
    error_message = "Invalid IP address."
  }
}

variable "default_backend_function" {
  description = "The key used to select the default backend service"
  type        = string
  # FIXME: terraform 1.9 and above required for cross-object reference
  # validation {
  #   condition = contains(keys(var.functions_map), var.default_backend_function)
  #   error_message = "Default backend function is not part of the functions map"
  # }
}

variable "functions_map" {
  description = "Map of Cloud Functions and their version (generation) to build the load balancer upon"
  type = map(object({
    version = string
  }))
  validation {
    condition = alltrue([
      for k in keys(var.functions_map) :
      can(regex("^[a-z]+(?:[a-z0-9])*(?:[A-Z]+[a-z0-9]*)*$", k))
    ])
    error_message = "All keys in **functions_map** must be in pseudo camelCase (lowercase and acronyms allowed, e.g. `health` or `verifyOTP`)"
  }
}

# Should be removed in the future - only added to help with the gen2 migrations
variable "url_map_name" {
  type        = string
  description = "**OPTIONAL:** URL Map name. By default a standard pattern is used. This input is an override that helps simplify the migration of existing load balancers to this module."
  default     = null
}
variable "certificate_manager_certificate_ids" {
  description = "Optional list of *GLOBAL* Certificate Manager certificate IDs for HTTPS (cross-region ILB)"
  type        = list(string)
  default     = []
}
