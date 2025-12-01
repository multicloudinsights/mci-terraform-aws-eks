variable "subnet_ids" {
  type = list(string)
}

variable "resourcename_prefix" {
  type = string
}

variable "authentication_mode" {
  type = string
}

variable "cluster_log_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "instance_types" {
  type = list(string)
}

variable "principal_arn" {
  type = string
}

variable "add-ons" {
  type        = list(string)
  description = "Add-on's for EKS cluster"
  default     = ["kube-proxy", "coredns", "vpc-cni", "aws-ebs-csi-driver"]
}

variable "add-ons-version" {
  type        = list(string)
  description = "Add-on's for EKS cluster"
  default     = ["v1.32.3-eksbuild.7", "v1.11.4-eksbuild.14", "v1.19.5-eksbuild.3", "v1.44.0-eksbuild.1"]
}