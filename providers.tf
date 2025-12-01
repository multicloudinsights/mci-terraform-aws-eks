terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.9"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }
  }

  required_version = ">= 1.10"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "app" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "app" {
  name = aws_eks_cluster.this.name
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.app.endpoint                                   # module.eks-util.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.app.certificate_authority.0.data) # base64decode(module.eks-util.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.app.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.app.endpoint                                   # module.eks-util.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.app.certificate_authority.0.data) # base64decode(module.eks-util.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.app.token
  }
}