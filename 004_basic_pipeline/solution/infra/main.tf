terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # No backend yet — that's 005_pipeline_remote_state. This exercise
  # only needs `fmt` and `validate` to pass, neither of which touches
  # state at all.
}

provider "google" {
  project = var.project_id
  region  = var.region
}
