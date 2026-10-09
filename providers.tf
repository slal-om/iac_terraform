terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
  }
}

# Configure the standard Google provider
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# Configure the google-beta provider
provider "google-beta" {
  project = var.project_id
  region  = "us-central1"
}