# QA Environment Configuration
aws_region           = "us-west-2"
environment          = "qa"
project_name         = "skills-copilot-qa"
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24"]
enable_nat_gateway   = true
enable_vpn_gateway   = false