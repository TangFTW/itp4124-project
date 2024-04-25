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
            version = "3.98.0"
        }
    }
    required_version = ">= 1.4.7"
}

provider "aws" {
    region = "us-east-1"
    
}

provider "azurerm" {
    features{}
}


data "aws_eks_cluster_auth" "ea2_eks_auth" {
    name = "ea2_eks"
    depends_on = [
        aws_eks_cluster.ea2_eks
    ]
}

provider "kubernetes" {
    alias = "aws"
    host                   = aws_eks_cluster.ea2_eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.ea2_eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.ea2_eks_auth.token
}


provider "kubernetes" {
    alias = "azure"
    host                   = azurerm_kubernetes_cluster.ea2_aks.kube_config[0].host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.ea2_aks.kube_config[0].cluster_ca_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.ea2_aks.kube_config[0].client_key)
    client_certificate = base64decode(azurerm_kubernetes_cluster.ea2_aks.kube_config[0].client_certificate)
}



provider "helm" {
    kubernetes {
    host                   = aws_eks_cluster.ea2_eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.ea2_eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.ea2_eks_auth.token
    }
}