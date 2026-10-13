data "google_secret_manager_secret" "dialogflow_token_secret" {
  secret_id = "DIALOGFLOW_TOKEN"
  project   = var.project_id
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_secret_accessor" {
  project   = var.project_id
  secret_id = data.google_secret_manager_secret.dialogflow_token_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
}