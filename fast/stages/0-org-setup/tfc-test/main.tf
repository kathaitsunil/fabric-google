terraform {
  cloud {
    organization = "terraform-cloud-deployment-GCP"
    workspaces {
      name = "fabric-google"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.0"
    }
  }
}
provider "google" {
  # No credentials needed here! TFC will use the WIF variables.
  project = "sun21-prod-iac-core-0"
}
# This data source will verify that TFC can "see" your GCP project
data "google_project" "test" {
  project_id = "sun21-prod-iac-core-0"
}
output "verification_status" {
  value = "SUCCESS: TFC is successfully authenticated as ${data.google_project.test.number}!"
}



