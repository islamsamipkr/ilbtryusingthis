terraform {
  required_version = ">= 1.3.4, < 2.0.0"
  # FIXME: required_version = ">= 1.9.0, < 2.0.0" # To enable cross-object reference in variable validation
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 7.0.0"
    }
  }
}
