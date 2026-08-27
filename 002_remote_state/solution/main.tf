terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Backend config can't reference variables — it has to be a literal.
  # This bucket was created by hand in the Console (see
  # task/README.md Part 1), not by this or any Terraform config.
  backend "gcs" {
    bucket = "your-gcp-project-id-tf-state" # TODO: replace with your state bucket
    prefix = "terraform-course/002-remote-state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "scratch" {
  name                        = "${var.project_id}-002-scratch"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}
