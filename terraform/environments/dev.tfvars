# Development Environment Configuration
aws_region           = "us-west-2"
environment          = "dev"
project_name         = "skills-copilot-dev"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
enable_nat_gateway   = false # Cost optimization for dev
enable_vpn_gateway   = false