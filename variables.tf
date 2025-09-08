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
  type = list(string)
}

variable "instance_types" {
  type = list(string)
}

variable "principal_arn" {
  type = string
}