module "glb" {
  source = "../../"

  google_project = "myproject"

  project_name   = "myapp"
  domain         = "ilbtest.com"
  glb_ip_address = "203.0.113.1"
  neg_regions    = ["northamerica-northeast1", "us-central1"]
  functions_map = {
    "myFunction1" = {
      "version" = "v1"
    }
    "myfunction2" = {
      "version" = "v2"
    }
  }
  default_backend_function = "myFunction1"
}
