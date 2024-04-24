resource "google_compute_network" "terraform_vpc" {
  name                    = "terraform_vpc"
  auto_create_subnetworks = false
}
#private subnet 1
resource "google_compute_subnetwork" "private_subnet_1" {
  name          = "private_subnet-1"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-east2"
  network       = google_compute_network.terraform_vpc.id
}
#private  subnet 2
resource "google_compute_subnetwork" "private_subnet_2" {
  name          = "private_subnet_2"
  ip_cidr_range = "10.0.2.0/24"
  region        = "asia-east2"
  network       = google_compute_network.terraform_vpc.id
}
