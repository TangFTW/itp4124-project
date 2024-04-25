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

####################################Below code need to run 2 apply and 2 destroy for working

resource "google_compute_router" "nat" {

  project = "terraformproject-415508"

  name    = "asia-east2-nat-router"
  region  = "asia-east2"
  network = google_compute_network.terraformvpc.id
}

resource "google_compute_router_nat" "nat" {

  project = "terraformproject-415508"

  name                   = "asia-east2-nat"
  router                 = "asia-east2-nat-router"
  region                 = "asia-east2"
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = "private1"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
    subnetwork {
    name                    = "private2"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
################# Testing code
# allows google instances to resolve aws private domains
resource "google_dns_managed_zone" "aws" {
  provider = google-beta

  project = "terraformproject-415508"

  name        = "aws"
  description = "private dns zone to enable resolving ec2 private domains"

  dns_name = "${var.aws_dns_suffix}."

  visibility = "private"

  private_visibility_config {
    networks {
      network_url =  google_compute_network.main.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = var.aws_dns_ip_addresses[0]
    }

    target_name_servers {
      ipv4_address = var.aws_dns_ip_addresses[1]
    }
  }
}
