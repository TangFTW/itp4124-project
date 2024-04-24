terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
        
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.0"
        }
        helm = {
            source = "hashicorp/helm"
            version = "2.13.0"
        }
        google = {
            source = "hashicorp/google"
            version = "5.26.0"
        }
    }
    required_version = ">= 1.4.7"
}

provider "google" {
#  credentials = file("path/to/service-account-key.json")
  project     = "ite3103-assignment"
  region      = "asia-east2"
  zone        = "asia-east2-a"
}
