terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # TODO: add a backend "gcs" block here:
  #   bucket = "YOUR_PROJECT_ID-tf-state" (literal — see README.md)
  #   prefix = "terraform-course/pipeline"
}

provider "google" {
  project = var.project_id
  region  = var.region
}
