resource "google_project_service" "compute" {
  project = "terraformproject-415508"
  service = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_compute_network" "terraformvpc" {
  project = "terraformproject-415508"

  name = "terraformvpc"
  routing_mode = "GLOBAL"

  auto_create_subnetworks = false
}

#private subnet 1
resource "google_compute_subnetwork" "private1" {
  name          = "private1"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-east2"
  network       = google_compute_network.terraformvpc.id
}

#private  subnet 2
resource "google_compute_subnetwork" "private2" {
  name          = "private2"
  ip_cidr_range = "10.0.2.0/24"
  region        = "asia-east2"
  network       = google_compute_network.terraformvpc.id
}
