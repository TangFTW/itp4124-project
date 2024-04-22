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
        azurerm = {
            source = "hashicorp/azurerm"
            version = "=3.98.0"
        }
    }
    required_version = ">= 1.4.7"
}

provider "aws" {
    region = "us-east-1"
    
}

provider "azurerm" {
    features{}
    client_id       = "30e4bdea-1736-4424-bd94-956afc7b5dc4"
    client_secret   = "V1w8Q~n~SuXTGspdJzYtwR2lUGzprmkJQLxMBceB"
    tenant_id       = "d5e8f2bd-dfc1-429d-962f-8afd55059a0e"
    subscription_id = "a56bde15-c786-45a1-882b-dedb4e179ad6"
}

provider "kubernetes" {
    host                   = azurerm_kubernetes_cluster.ea2_aks.kube_config[0].host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.ea2_aks.kube_config[0].cluster_ca_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.ea2_aks.kube_config[0].client_key)
    client_certificate = base64decode(azurerm_kubernetes_cluster.ea2_aks.kube_config[0].client_certificate)
}
