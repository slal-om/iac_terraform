variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project where resources will be created."
}

variable "site_id" {
  type        = string
  description = "The unique ID for the Firebase Hosting site."
}

variable "github_owner" {
  type        = string
  description = "The GitHub organization or username that owns the repository."
}

variable "github_repo" {
  type        = string
  description = "The name of the GitHub repository."
}

