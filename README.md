# iac_terraform

Terraform for the Google Cloud resources behind the `gcp-serverless` React app's dev environment:

- **Firebase Hosting site** (`google_firebase_hosting_site.dss_chat_widget_site`) with the ID `var.site_id`.
- **Cloud Build trigger** (`google_cloudbuild_trigger.dssdev_chat_widget_deploy_trigger`, named `react-firebase-deploy_dev`). It runs `cloudbuild.yaml` from the GitHub repo on every push to `dev`.
- **Secret Manager access.** Lets the Cloud Build service account read the existing `DIALOGFLOW_TOKEN` secret (`roles/secretmanager.secretAccessor`).

## Files

| File | Purpose |
| --- | --- |
| `providers.tf` | Terraform >= 1.0, `google` and `google-beta` providers `~> 6.0`, region `us-central1` |
| `variables.tf` | Input variables (see below) |
| `provision.tf` | Hosting site and Cloud Build trigger |
| `secrets.tf` | Looks up the `DIALOGFLOW_TOKEN` secret and grants Cloud Build access to it |
| `terraform.tfvars` | Values for the dev environment |
| `.terraform.lock.hcl` | Provider version lock file; commit it |

## Variables

| Name | Type | Description |
| --- | --- | --- |
| `project_id` | string | GCP project to create the resources in |
| `project_number` | number | Project number, used to build the Cloud Build service account email |
| `site_id` | string | Firebase Hosting site ID; must be globally unique |
| `github_owner` | string | GitHub user or org that owns the app repo |
| `github_repo` | string | GitHub repository name |

## Prerequisites

- Terraform >= 1.0 and the `gcloud` CLI, authenticated with `gcloud auth application-default login`.
- Firebase enabled on the project (`firebase projects:addfirebase <project_id>` or the Firebase console).
- These APIs enabled: `firebase.googleapis.com`, `firebasehosting.googleapis.com`, `cloudbuild.googleapis.com`, `secretmanager.googleapis.com`.
- The `DIALOGFLOW_TOKEN` secret already exists in Secret Manager. It is read with a `data` source, not created.
- The Cloud Build GitHub App installed on the repo and connected to the project, through Cloud Build > Triggers > Connect repository.
- A `cloudbuild.yaml` at the root of the app repo.
- The Cloud Build service account needs the `Firebase Hosting Admin` role to deploy.

## Usage

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

To use another environment, pass a different vars file: `terraform plan -var-file=uat.tfvars`.

## Known issues

`terraform validate` and `terraform plan` succeed, but the following problems only appear during `apply` or when the trigger runs.

1. **Cloud Build service account.** `secrets.tf` grants access to the legacy `${var.project_number}@cloudbuild.gserviceaccount.com` account. Projects created after mid-2024 may default Cloud Build to the Compute Engine default service account (`${var.project_number}-compute@developer.gserviceaccount.com`). The member must match the account the trigger actually runs as. Setting `service_account` on the trigger makes that explicit.
2. **Missing trigger substitutions.** `cloudbuild.yaml` references `$_API_URL` and `$_ENVIRONMENT`, but the trigger no longer defines `substitutions`. Cloud Build rejects builds that reference undefined user substitutions. Add them to the trigger:
   ```hcl
   substitutions = {
     _API_URL     = "https://example.com"
     _ENVIRONMENT = "development"
   }
   ```
3. **Deploy target not tied to `site_id`.** `cloudbuild.yaml` runs `firebase deploy --only hosting` and `firebase.json` has no `site`/`target`, so it deploys to the project's default site, not `var.site_id`. Add `"site": "<site_id>"` to `firebase.json` or use a hosting target.
4. **Secret exposed in the browser bundle.** `DIALOGFLOW_TOKEN` is passed into the Vite build step. If the app reads it as a `VITE_*` variable, Vite embeds the token in public JS. Keep tokens on the backend (Cloud Run) instead.
5. **No remote state.** State is stored locally. Add a `gcs` backend if more than one person runs this.
6. **Hard-coded dev values.** The trigger name and branch (`^dev$`) are fixed. Make them variables if more environments are needed.
7. **Dependencies are not managed in Terraform.** API enablement (`google_project_service`) and Firebase project setup (`google_firebase_project`) are expected to be done manually.
