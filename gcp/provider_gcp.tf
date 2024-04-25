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
            version = "5.25.0"
        }
        google-beta = {
            source = "hashicorp/google-beta"
            version = "5.26.0"
        }
    }
    required_version = ">= 1.4.7"
}

provider "aws" {
  region = "us-east-1"
}

provider "google" {
 # credentials = "terraformproject-415508-05982ee89e2a.json"
  project     = "terraformproject-415508"
  region      = "asia-east2"
  zone        = "asia-east2-a"
}

provider "google-beta" {
  #credentials = "terraformproject-415508-05982ee89e2a.json"
  project     = "terraformproject-415508"
  region      = "asia-east2"
  zone        = "asia-east2-a"
}
provider "azurerm" {}
