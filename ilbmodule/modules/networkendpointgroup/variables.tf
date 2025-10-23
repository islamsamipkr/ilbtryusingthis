variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
}

# Passthrough input/output - only used in backend service definition
variable "function_version" {
  description = "Cloud Function generation - v1 or v2"
  type = string
}

variable "regions" {
  description = "List of regions to create NEGs in"
  type        = list(string)
}
