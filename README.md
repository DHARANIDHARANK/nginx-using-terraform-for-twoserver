# Terraform AWS Multi-Region Deployment

This Terraform script deploys two AWS EC2 instances running Nginx in different regions (us-east-2 and us-west-2), each within its own VPC and associated resources.

##Prerequisites
Before running this script, ensure you have:

        AWS credentials configured with appropriate permissions.
        Terraform installed on your local machine.

# Terraform Setup
## 1).Clone the Repository:

```
git clone <repository-url>
cd terraform-aws-multi-region

```

## 2).Initialize Terraform:
```
terraform init
```

## 3).Review and Modify Variables:

Optionally, review variables.tf to adjust any default settings.

# Deploy Infrastructure

## 4).Deploy the Infrastructure:
```
terraform apply --auto-approve
```

## 5).Access Nginx Instances:

Once deployed, the public IP addresses of the instances will be displayed as outputs.

# Clean Up
## 6).Destroy Resources:

```
terraform destroy --auto-approve
```

# Notes
Ensure your AWS credentials have the necessary permissions to create and manage EC2 instances, VPCs, subnets, and security groups.
Review the Terraform plan (terraform plan) before applying changes to understand the resources that will be created or modified.
