# Production Environment Configuration
aws_region           = "us-west-2"
environment          = "prod"
project_name         = "skills-copilot-prod"
vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.20.0/24"]
enable_nat_gateway   = true
enable_vpn_gateway   = false