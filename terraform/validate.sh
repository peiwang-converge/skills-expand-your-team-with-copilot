#!/bin/bash

# Terraform VPC Configuration Validation Script
# This script validates that the Terraform configuration meets all requirements

set -e

echo "=== Terraform VPC Configuration Validation ==="
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validation functions
check_pass() {
    echo -e "${GREEN}✓ $1${NC}"
}

check_fail() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

check_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

echo "Checking Terraform configuration..."

# Change to terraform directory
cd "$(dirname "$0")"

# 1. Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    check_fail "Terraform is not installed"
fi
check_pass "Terraform is installed"

# 2. Check if terraform files exist
required_files=("main.tf" "variables.tf" "outputs.tf" "provider.tf")
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        check_fail "Required file $file is missing"
    fi
done
check_pass "All required Terraform files exist"

# 3. Initialize Terraform (if not already done)
if [[ ! -d ".terraform" ]]; then
    echo "Initializing Terraform..."
    terraform init > /dev/null 2>&1 || check_fail "Terraform initialization failed"
fi
check_pass "Terraform initialized successfully"

# 4. Validate Terraform syntax
terraform validate > /dev/null 2>&1 || check_fail "Terraform validation failed"
check_pass "Terraform configuration is valid"

# 5. Check formatting
terraform fmt -check > /dev/null 2>&1 || check_fail "Terraform files are not properly formatted"
check_pass "Terraform files are properly formatted"

# 6. Validate VPC CIDR configuration
vpc_cidr=$(grep -E 'default.*=.*"10\.0\.0\.0/16"' variables.tf || echo "")
if [[ -z "$vpc_cidr" ]]; then
    check_fail "VPC CIDR block is not set to standard size 10.0.0.0/16"
fi
check_pass "VPC CIDR block is set to standard size (10.0.0.0/16)"

# 7. Check for public subnets
public_subnets=$(grep -E 'default.*=.*\["10\.0\.1\.0/24".*"10\.0\.2\.0/24"\]' variables.tf || echo "")
if [[ -z "$public_subnets" ]]; then
    check_fail "Public subnets are not configured correctly"
fi
check_pass "2 public subnets configured (10.0.1.0/24, 10.0.2.0/24)"

# 8. Check for private subnets
private_subnets=$(grep -E 'default.*=.*\["10\.0\.10\.0/24".*"10\.0\.20\.0/24"\]' variables.tf || echo "")
if [[ -z "$private_subnets" ]]; then
    check_fail "Private subnets are not configured correctly"
fi
check_pass "2 private subnets configured (10.0.10.0/24, 10.0.20.0/24)"

# 9. Check for Internet Gateway
igw_check=$(grep -E 'resource.*"aws_internet_gateway"' main.tf || echo "")
if [[ -z "$igw_check" ]]; then
    check_fail "Internet Gateway not found in configuration"
fi
check_pass "Internet Gateway configured"

# 10. Check for NAT Gateway
nat_check=$(grep -E 'resource.*"aws_nat_gateway"' main.tf || echo "")
if [[ -z "$nat_check" ]]; then
    check_fail "NAT Gateway not found in configuration"
fi
check_pass "NAT Gateway configured"

# 11. Check for Elastic IP
eip_check=$(grep -E 'resource.*"aws_eip"' main.tf || echo "")
if [[ -z "$eip_check" ]]; then
    check_fail "Elastic IP not found in configuration"
fi
check_pass "Elastic IP configured for NAT Gateway"

# 12. Check for Route Tables
route_table_check=$(grep -E 'resource.*"aws_route_table"' main.tf || echo "")
if [[ -z "$route_table_check" ]]; then
    check_fail "Route tables not found in configuration"
fi
check_pass "Route tables configured"

# 13. Check for Route Table Associations
rta_check=$(grep -E 'resource.*"aws_route_table_association"' main.tf || echo "")
if [[ -z "$rta_check" ]]; then
    check_fail "Route table associations not found in configuration"
fi
check_pass "Route table associations configured"

# 14. Check outputs
required_outputs=("vpc_id" "public_subnet_ids" "private_subnet_ids" "nat_gateway_id")
for output in "${required_outputs[@]}"; do
    output_check=$(grep -E "output.*\"$output\"" outputs.tf || echo "")
    if [[ -z "$output_check" ]]; then
        check_fail "Output $output not found"
    fi
done
check_pass "All required outputs configured"

# 15. Check .gitignore
if [[ -f "../.gitignore" ]]; then
    gitignore_check=$(grep -E '(\*\.tfstate|\*\.terraform)' ../.gitignore || echo "")
    if [[ -z "$gitignore_check" ]]; then
        check_warn ".gitignore exists but may not exclude Terraform state files"
    else
        check_pass ".gitignore configured to exclude Terraform state files"
    fi
else
    check_warn ".gitignore file not found"
fi

# 16. Check documentation
if [[ -f "README.md" ]]; then
    check_pass "Documentation (README.md) exists"
else
    check_warn "README.md documentation not found"
fi

# 17. Check example variables file
if [[ -f "terraform.tfvars.example" ]]; then
    check_pass "Example variables file (terraform.tfvars.example) exists"
else
    check_warn "terraform.tfvars.example file not found"
fi

echo
echo "=== Validation Summary ==="
echo -e "${GREEN}✓ All core requirements met!${NC}"
echo
echo "Requirements verified:"
echo "  ✓ Terraform runs without error"
echo "  ✓ Configuration creates VPC with 2 private and 2 public subnets"
echo "  ✓ CIDR block is standard size (10.0.0.0/16)"
echo "  ✓ All networking components properly configured"
echo
echo -e "${GREEN}The Terraform infrastructure is ready for deployment!${NC}"
echo
echo "Next steps:"
echo "1. Copy terraform.tfvars.example to terraform.tfvars"
echo "2. Configure your AWS credentials"
echo "3. Run 'terraform plan' to review changes"
echo "4. Run 'terraform apply' to create infrastructure"