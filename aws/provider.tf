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
        
    }
    required_version = ">= 1.4.7"
}

provider "aws" {
    region = "us-east-1"
    
}

data "aws_eks_cluster_auth" "ea2_eks_auth" {
    name = "ea2_eks"
    depends_on = [
        aws_eks_cluster.ea2_eks
    ]
}

provider "kubernetes" {
    host                   = aws_eks_cluster.ea2_eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.ea2_eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.ea2_eks_auth.token
}

provider "helm" {
    kubernetes {
    host                   = aws_eks_cluster.ea2_eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.ea2_eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.ea2_eks_auth.token
    }
}