# variables.tf

variable "project_name" {
  description = "The short name of the project/application"
  type        = string
  default     = "moba025ebill"
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "US"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "cnr-moba025ebill-dev-d28b"
}

# Global HTTPS Load Balancer configuration
variable "global_ip_address_name" {
  description = "Name of the global IP address for the load balancer"
  type        = string
  default     = "ebill"
}

variable "loadbalancername" {
  description = "Name of the HTTPS load balancer"
  type        = string
  default     = "ebill-httpsserverless-loadbalancer"
}

variable "app" {
  description = "Application name"
  type        = string
  default     = "ebill"
}

variable "env" {
  description = "Deployment environment (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "hosts" {
  description = "List of hostnames to associate with the load balancer"
  type        = list(string)
  default     = ["srv.ebill-fb-dev.web.cn.ca"]
}

variable "ssl" {
  description = "Whether SSL is enabled for the load balancer"
  type        = bool
  default     = true
}

variable "dns_suffix" {
  description = "DNS suffix used for the environment"

  type        = string
  default  ="ebill"
}
variable "default_backend_function" {
  description = "DNS suffix used for the environment"

  type        = string
  default  ="putUpdateLegacyInvoice"
}
variable "neg_region_list" {
  type = list(string)
  default=["northamerica-northeast1","us-central1"]
}
