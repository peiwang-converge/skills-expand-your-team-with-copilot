# AWS VPC Terraform Configuration

This Terraform configuration creates a complete AWS VPC infrastructure with public and private subnets, following AWS best practices.

## Architecture

The configuration creates:

- **1 VPC** with configurable CIDR block (default: 10.0.0.0/16)
- **2 Public Subnets** in different Availability Zones (default: 10.0.1.0/24, 10.0.2.0/24)
- **2 Private Subnets** in different Availability Zones (default: 10.0.10.0/24, 10.0.20.0/24)
- **1 Internet Gateway** for public internet access
- **1 NAT Gateway** with Elastic IP for private subnet internet access
- **Route Tables** with proper routing configuration
- **VPC Flow Logs** for network monitoring (optional)

## Prerequisites

1. **Terraform** >= 1.0 installed
2. **AWS CLI** configured with appropriate credentials
3. **AWS Account** with permissions to create VPC resources

## Quick Start

1. **Clone the repository and navigate to terraform directory:**
   ```bash
   cd terraform
   ```

2. **Copy and customize the variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired values
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the planned changes:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **To destroy the infrastructure when no longer needed:**
   ```bash
   terraform destroy
   ```

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
├── provider.tf              # Provider configuration
├── terraform.tfvars.example # Example variables file
└── README.md                # This documentation
```

## Support

This configuration follows AWS best practices and Terraform conventions. For issues or questions:

1. Check the troubleshooting section above
2. Review AWS VPC documentation
3. Validate your Terraform syntax and plan output