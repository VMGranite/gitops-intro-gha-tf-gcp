terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # TODO: add a backend "gcs" block here pointing at the bucket you
  # created by hand in the Console (see README.md Part 1). `bucket`
  # must be a literal string, e.g. "your-project-id-tf-state" — not a
  # variable.
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# TODO: resource "google_storage_bucket" "scratch" {
#   name                        = "${var.project_id}-002-scratch"
#   location                    = var.region
#   force_destroy               = true
#   uniform_bucket_level_access = true
# }
