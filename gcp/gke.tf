resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "asia-east2-a"

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection       = false 
  }

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "asia-east2-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
