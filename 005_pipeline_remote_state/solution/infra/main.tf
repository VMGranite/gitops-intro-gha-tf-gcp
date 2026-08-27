terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "your-gcp-project-id-tf-state" # TODO: replace with your state bucket
    prefix = "terraform-course/pipeline"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
