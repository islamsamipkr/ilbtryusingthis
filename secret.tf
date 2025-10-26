locals {
  secrets = [for f in fileset(path.module, "./configs/${var.env}/gsm.yaml") : yamldecode(file(f))]

  secret_list = flatten([
    for s in local.secrets : [ 
      for secret_id, secret in s.secrets : {
        secret_id   = try(secret_id, null)
        # project_id  = try(secret.project_id, s.secret_defaults.project_id)
        project_id  = try(secret.project_id, var.project_id)
        # replication_locations = try(secret.replication_locations, [])
        replication_locations = try(secret.replication_locations, s.secret_defaults.replication_locations)
        labels      = merge(try(s.secret_defaults.labels, {}), try(var.google_labels, {}))
        secret_accessors_list = try(secret.secret_accessors_list, s.secret_defaults.secret_accessors_list)
        secret_admin_list = try(secret.secret_admin_list, s.secret_defaults.secret_admin_list)
    }
  ]
  ])
  secretobj = {for ss in local.secret_list : ss.secret_id => ss}
}


resource "google_secret_manager_secret" "app-secret" {
  for_each = local.secretobj

  project = each.value.project_id
  secret_id = each.value.secret_id

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = each.value.replication_locations
        content {
          location = replicas.value
          }
      }
    }
  }


  labels = each.value.labels
}

resource "google_secret_manager_secret_iam_binding" "admin_binding" {
  depends_on = [google_secret_manager_secret.app-secret]
  for_each = local.secretobj
  project   = each.value.project_id
  secret_id = each.value.secret_id
  role = "roles/secretmanager.admin"
  members = each.value.secret_admin_list

}



resource "google_secret_manager_secret_iam_binding" "accessor_binding" {
  depends_on = [google_secret_manager_secret.app-secret]
  for_each = local.secretobj
  project   = each.value.project_id
  secret_id = each.value.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = each.value.secret_accessors_list
}
