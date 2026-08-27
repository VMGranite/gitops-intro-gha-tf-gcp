terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "YOUR_SHARED_STATE_BUCKET" # TODO: shared bucket from Part 0
    prefix = "terraform-course/team/YOUR_NAME"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "app" {
  name         = "${var.project_id}-YOUR_NAME-gitops-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }
}

output "vm_external_ip" {
  value = google_compute_instance.app.network_interface[0].access_config[0].nat_ip
}
