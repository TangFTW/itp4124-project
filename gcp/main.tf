terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.25.0"
    }
  }
}

provider "google" {
  project     = "terraformproject-415508"
  region      = "asia-east2"
}

resource "google_compute_network" "my_vpc" {
  name                    = "my-gcp-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-1" {
  name          = "subnet-1"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-east2"
  network       = google_compute_network.my_vpc.id
}

resource "google_compute_subnetwork" "subnet-2" {
  name          = "subnet-2"
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-east2"
  network       = google_compute_network.my_vpc.id
}

