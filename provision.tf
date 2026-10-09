# Enable and provision a Firebase Hosting site
resource "google_firebase_hosting_site" "dss_chat_widget_site" {
  provider = google-beta
  project  = var.project_id
  site_id  = var.site_id
}

# Create the Cloud Build Trigger for your branch
resource "google_cloudbuild_trigger" "dssdev_chat_widget_deploy_trigger" {
  name     = "react-firebase-deploy_dev"
  project  = var.project_id
  location = "global"

  filename = "cloudbuild.yaml" 
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^dev$"
    }
  }

  # 🚀 Wire your environment variables here! # Note: Custom variables must start with an underscore (_) 
  substitutions = { _API_URL = "https://example.com" _FIREBASE_ENV = "development" }
}
} # <--- Added missing closing brace