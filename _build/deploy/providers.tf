provider "google" {
  version = "3.5.0"
  credentials = var.credentials_file
  project = var.project
  region = var.region
  zone = var.zone
}

provider "google-beta" {
  credentials = var.credentials_file
  project = var.project
  region = var.region
  zone = var.zone
}