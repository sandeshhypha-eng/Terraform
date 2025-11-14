# Terraform AWS Infrastructure - Modular Structure

This Terraform project provides a modular, scalable infrastructure setup for deploying a web application on AWS with separate environments (dev, release, prod).

## Project Structure

```
terraformv2/
├── modules/
│   ├── network/          # VPC, Subnets, Internet Gateway, Route Tables
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/         # Security Groups for ALB and EC2
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── instances/        # EC2 Instances
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── alb/              # Application Load Balancer
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── dev/              # Development Environment
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── terraform.tfvars
    │   └── outputs.tf
    ├── release/          # Release/Staging Environment
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── terraform.tfvars
    │   └── outputs.tf
    └── prod/             # Production Environment
        ├── main.tf
        ├── variables.tf
        ├── terraform.tfvars
        └── outputs.tf
```

## Prerequisites

1. **Terraform** (>= 1.0) installed on your system
2. **AWS CLI** configured with appropriate credentials
3. **AWS Account** with necessary permissions

### Configure AWS Credentials

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-east-1)
- Default output format (e.g., json)

## Modules Overview

### 1. Network Module (`modules/network/`)
- Creates VPC with DNS support
- Creates Internet Gateway
- Creates 2 public subnets in different availability zones
- Creates and associates route tables

### 2. Security Module (`modules/security/`)
- Security group for Application Load Balancer (allows HTTP from internet)
- Security group for EC2 instances (allows HTTP only from ALB)

### 3. Instances Module (`modules/instances/`)
- Creates 2 EC2 instances in different subnets
- Installs and configures Apache web server
- Each instance displays a unique message

### 4. ALB Module (`modules/alb/`)
- Creates Application Load Balancer
- Creates target group with health checks
- Attaches EC2 instances to target group
- Creates HTTP listener on port 80

## Environment Configuration

Each environment (dev, release, prod) has its own configuration:

- **dev**: Uses `t2.micro` instances, VPC CIDR `10.0.0.0/16`
- **release**: Uses `t2.small` instances, VPC CIDR `10.1.0.0/16`
- **prod**: Uses `t2.medium` instances, VPC CIDR `10.2.0.0/16`

You can customize each environment by editing the respective `terraform.tfvars` file.

## Usage

### Deploy to Development Environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy to Release Environment

```bash
cd environments/release
terraform init
terraform plan
terraform apply
```

### Deploy to Production Environment

```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

### View Outputs

After deployment, view the ALB DNS name:

```bash
terraform output alb_dns_name
```

### Destroy Infrastructure

To destroy the infrastructure for a specific environment:

```bash
cd environments/<environment>
terraform destroy
```

## Customization

### Modify Environment Variables

Edit the `terraform.tfvars` file in the desired environment directory:

```hcl
aws_region          = "us-east-1"
environment         = "dev"
vpc_cidr            = "10.0.0.0/16"
public_subnet_1_cidr = "10.0.1.0/24"
public_subnet_2_cidr = "10.0.2.0/24"
instance_type       = "t2.micro"
```

### Modify Module Resources

Each module is self-contained. To modify resources:
1. Edit the `main.tf` file in the respective module directory
2. Update `variables.tf` if new variables are needed
3. Update `outputs.tf` if new outputs are required

## Best Practices

1. **State Management**: Consider using remote state (S3 + DynamoDB) for production
2. **Secrets Management**: Never commit AWS credentials or secrets to version control
3. **Tagging**: All resources are tagged with environment for easy identification
4. **Version Control**: Use version control (Git) to track changes
5. **Testing**: Always run `terraform plan` before `terraform apply`

## Outputs

Each environment outputs:
- `alb_dns_name`: The DNS name of the load balancer (use this to access your application)
- `vpc_id`: The VPC ID
- `web_1_instance_id`: EC2 instance 1 ID
- `web_2_instance_id`: EC2 instance 2 ID

## Troubleshooting

1. **ALB Health Checks Failing**: Ensure EC2 instances have Apache running and are accessible
2. **Cannot Access ALB DNS**: Wait a few minutes after deployment for DNS propagation
3. **Terraform State Issues**: Use `terraform refresh` to sync state with actual resources

## License

This project is provided as-is for educational and demonstration purposes.

