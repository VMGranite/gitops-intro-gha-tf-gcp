variable "project_id" {
  description = "The shared GCP project ID for this class."
  type        = string
}

variable "region" {
  description = "Region for the provider default."
  type        = string
  default     = "us-central1"
}
