# AWS VPC Terraform Configuration with CI/CD Pipeline

This Terraform configuration creates a complete AWS VPC infrastructure with public and private subnets, following AWS best practices. It includes a comprehensive CI/CD pipeline for automated deployments across multiple environments.

## 🏗️ Architecture

The configuration creates:

- **1 VPC** with configurable CIDR block (default: 10.0.0.0/16)
- **2 Public Subnets** in different Availability Zones (default: 10.0.1.0/24, 10.0.2.0/24)
- **2 Private Subnets** in different Availability Zones (default: 10.0.10.0/24, 10.0.20.0/24)
- **1 Internet Gateway** for public internet access
- **1 NAT Gateway** with Elastic IP for private subnet internet access
- **Route Tables** with proper routing configuration
- **VPC Flow Logs** for network monitoring

## 🚀 CI/CD Pipeline

### Deployment Flow
1. **Security Scan**: Checkov security analysis (non-blocking)
2. **Development**: Automatic deployment on main branch
3. **QA**: Manual approval required
4. **Production**: Manual approval required

### Environment Configuration
- `environments/dev.tfvars`: Development (cost-optimized, no NAT Gateway)
- `environments/qa.tfvars`: QA environment (production-like)
- `environments/prod.tfvars`: Production environment (full features)

### Security Features
- **Checkov scanning**: Automated security and compliance checks
- **Environment isolation**: Separate Terraform state per environment
- **Manual approvals**: Required for QA and production deployments
- **Artifact storage**: Plans and outputs saved for review

## Prerequisites

1. **Terraform** >= 1.0 installed
2. **AWS CLI** configured with appropriate credentials
3. **AWS Account** with permissions to create VPC resources
4. **GitHub Secrets** configured for CI/CD:
   - `AWS_ACCESS_KEY_ID`: AWS access key
   - `AWS_SECRET_ACCESS_KEY`: AWS secret key
   - `TF_STATE_BUCKET`: S3 bucket for Terraform state

## Quick Start

### Local Development
1. **Clone the repository and navigate to terraform directory:**
   ```bash
   cd terraform
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init \
     -backend-config="bucket=your-state-bucket" \
     -backend-config="key=skills-copilot/dev/terraform.tfstate" \
     -backend-config="region=us-west-2"
   ```

3. **Plan for specific environment:**
   ```bash
   terraform plan -var-file="environments/dev.tfvars"
   ```

4. **Apply the configuration (dev only):**
   ```bash
   terraform apply -var-file="environments/dev.tfvars"
   ```

### CI/CD Deployment
1. **Push to main branch** for automatic dev deployment
2. **Approve QA deployment** in GitHub Actions
3. **Approve production deployment** in GitHub Actions

## Configuration Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region for resources | `us-west-2` | No |
| `environment` | Environment name (dev, staging, prod) | `dev` | No |
| `project_name` | Project name for resource naming | `vpc-project` | No |
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` | No |
| `availability_zones` | List of availability zones | `["us-west-2a", "us-west-2b"]` | No |
| `public_subnet_cidrs` | CIDR blocks for public subnets | `["10.0.1.0/24", "10.0.2.0/24"]` | No |
| `private_subnet_cidrs` | CIDR blocks for private subnets | `["10.0.10.0/24", "10.0.20.0/24"]` | No |
| `enable_nat_gateway` | Enable NAT Gateway for private subnets | `true` | No |
| `enable_vpn_gateway` | Enable VPN Gateway | `false` | No |

## Outputs

The configuration provides the following outputs:

- `vpc_id` - ID of the created VPC
- `vpc_cidr_block` - CIDR block of the VPC
- `public_subnet_ids` - IDs of public subnets
- `private_subnet_ids` - IDs of private subnets
- `nat_gateway_id` - ID of the NAT Gateway
- `nat_gateway_ip` - Elastic IP of the NAT Gateway
- `internet_gateway_id` - ID of the Internet Gateway
- `availability_zones` - List of availability zones used

## AWS Costs

This configuration will create the following billable resources:

- **NAT Gateway**: ~$45/month + data processing charges
- **Elastic IP**: Free when attached to running NAT Gateway
- **VPC Flow Logs**: CloudWatch Logs charges apply
- **Other VPC resources**: Generally free tier eligible

## Security Considerations

- Private subnets don't have direct internet access (traffic routed through NAT Gateway)
- VPC Flow Logs enabled for network monitoring
- Default security groups restrict access appropriately
- Resources tagged for proper management and cost tracking

## Customization

To customize for your specific needs:

1. **Multi-AZ Setup**: Modify `availability_zones` and subnet CIDR blocks
2. **Different Region**: Change `aws_region` variable
3. **Custom CIDR Blocks**: Adjust `vpc_cidr`, `public_subnet_cidrs`, and `private_subnet_cidrs`
4. **Disable NAT Gateway**: Set `enable_nat_gateway = false` (reduces costs but removes internet access for private subnets)

## Validation

To validate the configuration meets requirements:

```bash
# Check Terraform syntax
terraform validate

# Check formatting
terraform fmt -check

# Plan and review changes
terraform plan
```

## Troubleshooting

### Common Issues

1. **Insufficient Permissions**: Ensure your AWS credentials have VPC creation permissions
2. **Region Availability**: Verify the selected region supports all required resources
3. **CIDR Conflicts**: Ensure CIDR blocks don't conflict with existing VPCs
4. **Resource Limits**: Check AWS service limits for your account

### Validation Commands

```bash
# Check if VPC was created successfully
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Verify subnets
aws ec2 describe-subnets --subnet-ids $(terraform output -json public_subnet_ids | jq -r '.[]')
aws ec2 describe-subnets --subnet-ids $(terraform output -json private_subnet_ids | jq -r '.[]')

# Check NAT Gateway
aws ec2 describe-nat-gateways --nat-gateway-ids $(terraform output -raw nat_gateway_id)
```

## File Structure

```
terraform/
├── main.tf                    # Main VPC and networking resources
├── variables.tf              # Variable definitions
├── outputs.tf               # Output definitions
├── provider.tf              # Provider and backend configuration
├── terraform.tfvars.example # Example variables file
├── validate.sh              # Validation script
├── environments/            # Environment-specific configurations
│   ├── dev.tfvars          # Development environment
│   ├── qa.tfvars           # QA environment
│   └── prod.tfvars         # Production environment
└── README.md               # This documentation
```

## CI/CD Workflow

The GitHub Actions workflow (`.github/workflows/terraform-deploy.yml`) provides:

- **Checkov Security Scanning**: Runs on every push/PR
- **Multi-environment Planning**: Shows plans for all environments on PRs
- **Progressive Deployment**: Dev → QA → Prod with approvals
- **Artifact Management**: Saves plans and outputs for review

## Support

This configuration follows AWS best practices and Terraform conventions. For issues or questions:

1. Check the troubleshooting section above
2. Review AWS VPC documentation
3. Validate your Terraform syntax and plan output