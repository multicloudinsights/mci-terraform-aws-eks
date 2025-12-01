resource "aws_eks_cluster" "this" {
  name     = "${var.resourcename_prefix}-cluster"
  version  = "1.33"
  role_arn = aws_iam_role.cluster.arn

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = []
  }

  enabled_cluster_log_types = var.cluster_log_types

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster
  ]
}

resource "aws_iam_role" "cluster" {
  name = "${var.resourcename_prefix}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.this.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.resourcename_prefix}-cluster-node-group"
  node_role_arn   = aws_iam_role.nodegroup.arn
  subnet_ids      = var.subnet_ids
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = var.instance_types
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  ami_type        = "AL2_x86_64"

  # remote_access {
  #   ec2_ssh_key = ""
  # }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecr_read_only,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_worker_node
  ]
}

resource "aws_iam_role" "nodegroup" {
  name = "${var.resourcename_prefix}-cluster-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodegroup.name
}

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "this" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.principal_arn

  access_scope {
    type = "cluster"
  }
}

locals {
  autoscaling_group_name = flatten(aws_eks_node_group.this.resources.autoscaling_group.name)
}

resource "aws_autoscaling_group_tag" "eks-worker-nodes" {
  autoscaling_group_name = local.autoscaling_group_name

  tag {
    key                 = "Name"
    value               = "aws-eks-cluster-nodes"
    propagate_at_launch = true
  }
}

# Manage EKS add-on's
resource "aws_eks_addon" "eks-cluster-add-on" {
  count                       = length(var.add-ons)
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = var.add-ons[count.index]
  addon_version               = var.add-ons-version[count.index]
  resolve_conflicts_on_update = "PRESERVE"
}