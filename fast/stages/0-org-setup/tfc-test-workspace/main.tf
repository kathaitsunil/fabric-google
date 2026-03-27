terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  # The provider automatically picks up WIF credentials when TFC_GCP_PROVIDER_AUTH=true.
  # Just declare your basic configurations here:
  project = "your-target-project-id"
  region  = "europe-west1"
}

# Add a simple data source to test the connection
data "google_client_openid_userinfo" "me" {}

output "authenticated_user_email" {
  value       = data.google_client_openid_userinfo.me.email
  description = "The email of the authenticated Service Account"
}
