# MCI Terraform AWS EKS

This project provisions an Amazon EKS cluster using Terraform, following security best practices.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.10
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Usage

1.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

2.  **Review the Plan:**
    ```bash
    terraform plan
    ```

3.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```

4.  **Configure kubectl:**
    After applying, use the output command to update your kubeconfig:
    ```bash
    aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
    ```

## Inputs

| Name | Description | Type |
|------|-------------|------|
| `resourcename_prefix` | Prefix for resource names | `string` |
| `subnet_ids` | List of subnet IDs for the cluster | `list(string)` |
| `instance_types` | List of instance types for the node group | `list(string)` |
| `cluster_log_types` | List of enabled control plane log types | `list(string)` |
| `principal_arn` | ARN of the principal to grant cluster access | `string` |

## Outputs

- `cluster_endpoint`: Endpoint for EKS control plane.
- `cluster_name`: Kubernetes Cluster Name.
- `cluster_security_group_id`: Security group IDs attached to the cluster control plane.
- `region`: AWS region.

## Security

- **Secrets Encryption**: Enabled using a dedicated KMS key.
- **Logging**: All control plane logs are enabled by default.
- **Private Access**: Cluster endpoint has private access enabled.