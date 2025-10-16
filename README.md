# my-devops-project

This repository has my comprehensive, reusable Terraform module for provisioning AWS Virtual Private Cloud (VPC) infrastructure.

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-VPC-FF9900?logo=amazon-aws)](https://aws.amazon.com/vpc/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)


---

# Terraform AWS VPC Reusable Infrastructure Module

## Overview

This repository provides a reusable and modular Terraform configuration to provision a Virtual Private Cloud (VPC) on AWS.  
It creates a foundational network infrastructure that can serve as a base for deploying applications, compute resources, and managed services in a secure and isolated environment.

The VPC module is designed for scalability and reusability across multiple environments (e.g., development, staging, production).  
It adheres to Infrastructure as Code (IaC) principles and follows Terraform best practices.

---

## Components Included

This Terraform configuration provisions the following AWS components:

- **VPC (Virtual Private Cloud)** – a logically isolated network within AWS.
- **Public Subnets** – for resources that require direct internet access.
- **Private Subnets** – for internal workloads without direct internet access.
- **Internet Gateway (IGW)** – to enable internet connectivity for public subnets.
- **Route Tables** – for routing network traffic between subnets and gateways.
- **Route Table Associations** – for subnet-to-route-table mapping.
- **Tags** – consistent resource tagging for management and billing.

---

## Components That Can Be Added or Extended

This VPC can be easily extended to include additional AWS infrastructure components such as:

- **NAT Gateway** – to allow outbound internet access from private subnets.
- **Elastic IPs (EIP)** – for persistent public IPs attached to resources.
- **EC2 Instances** – to deploy compute resources inside subnets.
- **EKS (Elastic Kubernetes Service)** – for Kubernetes cluster deployment within the VPC.
- **RDS (Relational Database Service)** – for managed databases in private subnets.
- **ALB/NLB (Application or Network Load Balancer)** – to distribute traffic across multiple instances.
- **Security Groups and Network ACLs** – to control inbound and outbound traffic.
- **VPC Peering or Transit Gateway** – for multi-VPC connectivity.
- **S3 Backend Configuration** – to store Terraform state remotely for team collaboration.

For additional configuration patterns or more advanced usage of Terraform modules, refer to the [official Terraform documentation](https://developer.hashicorp.com/terraform/language/modules/configuration#generic-git-repository).

---

## Directory Structure

```
project-root/
├── providers.tf              # AWS provider configuration
├── network.tf                # Root-level invocation of the VPC module
├── modules/
│   └── vpc/
│       ├── main.tf           # Core VPC and subnet resources
│       ├── variables.tf      # Input variable definitions
│       ├── outputs.tf        # Module output definitions
│       └── locals.tf         # Local values and conditional logic
└── demo/
    └── demo-vpc/
        ├── main.tf           # Example implementation of the module
        └── providers.tf      # Provider for demo usage
```


---

## Prerequisites

Before using this module, ensure the following prerequisites are met:

### 1. Terraform Installation

Install Terraform (version 1.5 or above).  
[Official Terraform Installation Guide](https://developer.hashicorp.com/terraform/downloads)

### 2. AWS Account

You must have an AWS account with sufficient IAM permissions to create VPC, subnets, route tables, and related networking resources.

### 3. AWS CLI Configuration

Configure AWS credentials using one of the recommended secure methods (see below).

### 4. Backend Configuration (Recommended)

To enable team collaboration and state persistence, configure a remote backend such as **Amazon S3** with **DynamoDB** for state locking.  
Example backend block in `providers.tf`:

```hcl
terraform {
    backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    }
}
```

---

## Secure AWS Credential Management

Do not store AWS credentials in any Terraform files, variables, or code. Use one of the following secure methods to authenticate Terraform with AWS:

### 1. AWS CLI Profile

 Configure credentials using:

```bash
aws configure
```

This stores credentials in:

```
~/.aws/credentials
~/.aws/config
```

Then reference the profile in your provider block:

```hcl
  provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}
```
### 2. Environment Variables
Set credentials temporarily in the shell session:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

### 3. IAM Role (Recommended for CI/CD)

If Terraform runs inside AWS (for example, in EC2, CodeBuild, or GitHub Actions using OIDC), use an IAM Role or assumed role for secure, short-lived credentials.

---

## Steps to Deploy

### 1. Clone the Repository


```bash
git clone https://github.com/<your-username>/terraform-aws-vpc-module.git
cd terraform-aws-vpc-module
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate Configuration

```bash
terraform validate
```

### 4. Preview the Changes

```bash
terraform plan
```

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` to confirm the changes.

### 6. View Outputs

```bash
terraform output
```

### 7. Destroy the Infrastructure (when no longer needed)

```bash
terraform destroy
```

---

## Example Usage

Below is an example of how to call this module in a root configuration:

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_info = {
    cidr_block           = "192.160.0.0/16"
    enable_dns_hostnames = true
    tags = {
      Name    = "demo-vpc"
      Purpose = "infrastructure"
    }
  }

  public_subnets = [{
    cidr_block = "192.160.0.0/24"
    az         = "ap-south-1a"
    tags = { Name = "public-subnet-a" }
  }]

  private_subnets = [{
    cidr_block = "192.160.1.0/24"
    az         = "ap-south-1a"
    tags = { Name = "private-subnet-a" }
  }]
}
```

----

## Integration in DevOps and CI/CD Pipelines:

This module can be used in DevOps pipelines to automate AWS infrastructure provisioning.Typical use cases include:

- **Infrastructure Provisioning Stages** in Jenkins, GitHub Actions, GitLab CI, or Azure DevOps.
- **Environment Creation** for development, staging, or production environments.
- **Blue-Green or Multi-Environment Deployments** where separate VPCs or subnets are provisioned dynamically.
- **Immutable Infrastructure Workflows**, where infrastructure changes are version-controlled and automated.

For CI/CD pipelines:

- Use remote state (S3 backend) for consistency.
- Use AWS roles instead of static credentials.
- Automate `terraform plan` and `terraform apply` using approval gates.

---

## Frequently Asked Questions

**Q1. Can I use this module to deploy an EKS or EC2 cluster?**

Yes. This VPC can serve as the base network for EKS, EC2, or ECS deployments. Use the subnet and VPC outputs to attach additional modules (for example, `eks`, `ec2`, or `rds` modules).

**Q2. Can I use this with a remote module hosted in a Git repository?**

Yes. Modules can be sourced directly from a Git URL as per Terraform's documentation.

**Q3. Can I customize the subnets or add more Availability Zones?**

Yes. Simply add more subnet objects in the `public_subnets` or `private_subnets` variable lists.

**Q4. Should I commit the `.terraform` folder or state files to Git?**

No. Always exclude `.terraform/` and `*.tfstate*` files using a `.gitignore` file.

**Q5. Can this be used for hybrid cloud or multi-region setups?**

Yes. You can parameterize the region and call the module multiple times with different regions.

---

## Best Practices

- Always use remote state backends for production deployments.
- Parameterize inputs and avoid hardcoding values.
- Use workspaces to manage multiple environments (e.g., dev, staging, prod).
- Apply tags consistently across all resources for cost management.
- Avoid storing credentials or secrets in Terraform code or state.
- Version-control this repository and enforce reviews on infrastructure changes.

---

## Conclusion

This repository provides a foundational AWS VPC module designed for reuse, scalability, and integration with DevOps automation pipelines.It enables DevOps engineers to create and manage network infrastructure consistently across multiple environments while adhering to security and IaC best practices.

For extended use cases, advanced configurations, and official syntax guidance, refer to the [Terraform documentation](https://developer.hashicorp.com/terraform/language/modules/configuration#generic-git-repository).

---

## Recommended .gitignore for Terraform Projects

Add the following `.gitignore` file to your repository root to prevent committing Terraform state, cache, and sensitive data:

```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude variable files with secrets
*.tfvars
*.tfvars.json

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Terraform plan output
*.plan

# Sensitive local files
terraform.tfstate.backup
.terraformrc
terraform.rc
```

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.