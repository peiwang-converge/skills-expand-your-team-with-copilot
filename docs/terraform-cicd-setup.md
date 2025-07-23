# Terraform CI/CD Pipeline Setup Guide

This guide explains how to configure the complete CI/CD pipeline for Terraform deployments with approval gates and security scanning.

## Overview

The CI/CD pipeline automatically:
1. 🔍 Runs Checkov security scan (non-blocking)
2. 🚀 Deploys to **dev** environment (automatic)
3. ⏳ Deploys to **qa** environment (requires approval)
4. ⏳ Deploys to **prod** environment (requires approval)

## Pipeline Components

### Security Scanning
- **Checkov** security scan runs on every push/PR
- Results are uploaded as artifacts and commented on PRs
- Scan is **non-blocking** - pipeline continues even if security issues are found
- Results should be reviewed but don't prevent deployment

### Environment Progression
```
Dev (auto) → QA (approval) → Prod (approval)
```

### State Management
- Each environment has separate Terraform state files
- States are stored in S3 backend with environment-specific keys:
  - `skills-copilot/dev/terraform.tfstate`
  - `skills-copilot/qa/terraform.tfstate`
  - `skills-copilot/prod/terraform.tfstate`

## Required Setup

### 1. AWS Secrets Configuration

Configure these secrets in repository settings:

```
AWS_ACCESS_KEY_ID      # AWS access key with necessary permissions
AWS_SECRET_ACCESS_KEY  # AWS secret access key  
TF_STATE_BUCKET       # S3 bucket name for Terraform state storage
```

### 2. GitHub Environment Protection Rules

**IMPORTANT**: To enable approval gates, configure environment protection rules:

#### QA Environment
1. Go to **Settings** > **Environments**
2. Click **qa** environment (or create if it doesn't exist)
3. Configure **Protection rules**:
   - ✅ **Required reviewers**: Add 1+ team members
   - ✅ **Prevent self-review**: Recommended
   - 🕒 **Wait timer**: Optional (e.g., 5 minutes)

#### Production Environment
1. Go to **Settings** > **Environments**
2. Click **prod** environment (or create if it doesn't exist)
3. Configure **Protection rules**:
   - ✅ **Required reviewers**: Add 2+ senior team members
   - ✅ **Prevent self-review**: Required
   - 🕒 **Wait timer**: Recommended (e.g., 30 minutes)
   - 📅 **Deployment branches**: Restrict to `main` branch only

### 3. Required AWS Permissions

The AWS credentials need permissions for:
- VPC and networking resources
- CloudWatch logs
- IAM roles and policies
- S3 bucket access for state storage

## Usage

### Automatic Deployment (Dev)
Push to `main` branch triggers:
1. Security scan with Checkov
2. Automatic deployment to dev environment

### Manual Approval Required (QA/Prod)
After dev deployment succeeds:
1. QA deployment waits for approval
2. Designated reviewers receive notification
3. After QA approval and deployment, prod waits for approval
4. Final production deployment after approval

### Workflow Triggers
- **Push to main**: Full deployment pipeline (dev → qa → prod)
- **Pull Request**: Security scan + Terraform plan for all environments
- **Manual**: Use "Run workflow" button for manual triggering

## Monitoring and Troubleshooting

### Viewing Results
- **Security scan results**: Check workflow artifacts
- **Terraform outputs**: Available as artifacts for each environment
- **Deployment logs**: Full logs available in GitHub Actions

### Common Issues
1. **Missing approvals**: Check environment protection rules
2. **AWS permission errors**: Verify IAM permissions and secrets
3. **State conflicts**: Ensure S3 bucket exists and is accessible
4. **Terraform errors**: Review environment-specific `.tfvars` files

### Checkov Security Scan
- Scan runs automatically on every deployment
- Results are informational only (non-blocking)
- Review security findings but they won't stop deployments
- Results available in workflow artifacts and PR comments

## Environment Configurations

### Development
- **Purpose**: Development and testing
- **Approval**: None (automatic)
- **Resources**: Cost-optimized (NAT Gateway disabled)

### QA
- **Purpose**: Quality assurance and staging
- **Approval**: 1+ reviewers required
- **Resources**: Production-like configuration

### Production
- **Purpose**: Live production environment
- **Approval**: 2+ senior reviewers required
- **Resources**: Full production configuration

## Security Best Practices

1. ✅ Never commit secrets to code
2. ✅ Use separate state files per environment
3. ✅ Require approvals for QA/Prod deployments
4. ✅ Review Checkov scan results regularly
5. ✅ Use least-privilege AWS IAM permissions
6. ✅ Enable VPC Flow Logs for network monitoring

## Support

For issues with the CI/CD pipeline:
1. Check GitHub Actions logs
2. Verify environment protection rules
3. Confirm AWS permissions and secrets
4. Review Terraform configuration files

---

**Note**: This pipeline follows infrastructure-as-code best practices with security scanning, approval gates, and environment isolation.