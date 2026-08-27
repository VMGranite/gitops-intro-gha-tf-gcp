variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the provider default."
  type        = string
  default     = "us-central1"
}
