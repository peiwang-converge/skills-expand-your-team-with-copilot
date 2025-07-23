# GitHub Environments Setup Guide

This guide explains how to set up GitHub environments for the Terraform CI/CD pipeline.

## Required Environments

You need to create three environments in your GitHub repository:

### 1. Development Environment (`dev`)
- **Name**: `dev`
- **Approval requirements**: None (automatic deployment)
- **Branch protection**: Optional

### 2. QA Environment (`qa`)
- **Name**: `qa`
- **Approval requirements**: Require reviewers (1 or more)
- **Branch protection**: Limit to `main` branch only

### 3. Production Environment (`prod`)
- **Name**: `prod`
- **Approval requirements**: Require reviewers (1 or more)
- **Branch protection**: Limit to `main` branch only

## Setup Steps

### 1. Navigate to Repository Settings
1. Go to your repository on GitHub
2. Click on **Settings** tab
3. In the left sidebar, click on **Environments**

### 2. Create Each Environment

For each environment (`dev`, `qa`, `prod`):

1. Click **New environment**
2. Enter the environment name
3. Click **Configure environment**

### 3. Configure Environment Protection Rules

#### For QA and Production environments:

**Deployment branches:**
- Select "Selected branches"
- Add rule for `main` branch

**Required reviewers:**
- Check "Required reviewers"
- Add reviewers (team members or yourself)
- Set wait timer if desired (optional)

**Other optional settings:**
- Deployment timeout: 30 minutes (recommended)
- Allow administrators to bypass: As desired

#### For Development environment:
- No special configuration required
- Can be left with default settings

## Required Secrets

The following repository secrets must be configured:

### AWS Credentials
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add these repository secrets:

- `AWS_ACCESS_KEY_ID`: Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key
- `TF_STATE_BUCKET`: S3 bucket name for Terraform state storage

### Terraform State Bucket Setup

Create an S3 bucket for Terraform state storage:

```bash
# Create the bucket (replace with your unique bucket name)
aws s3 mb s3://your-terraform-state-bucket

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket your-terraform-state-bucket \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
    --bucket your-terraform-state-bucket \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access
aws s3api put-public-access-block \
    --bucket your-terraform-state-bucket \
    --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

## IAM Permissions

The AWS credentials need the following permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "logs:*",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:PassRole",
                "iam:CreateRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:GetRolePolicy",
                "iam:ListRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:TagRole",
                "iam:UntagRole"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::your-terraform-state-bucket",
                "arn:aws:s3:::your-terraform-state-bucket/*"
            ]
        }
    ]
}
```

## Testing the Setup

1. Push a change to the `main` branch
2. Watch the GitHub Actions workflow run
3. Verify that:
   - Checkov scan completes (may show warnings)
   - Dev deployment runs automatically
   - QA deployment waits for approval
   - Prod deployment waits for approval after QA

## Troubleshooting

### Common Issues

1. **Environment not found**: Ensure environment names match exactly (`dev`, `qa`, `prod`)
2. **Missing approvers**: At least one reviewer must be configured for QA/prod
3. **AWS permissions**: Verify IAM permissions and credentials
4. **S3 bucket**: Ensure the state bucket exists and is accessible

### Workflow Permissions

If you encounter permission issues, ensure the workflow has these permissions:

```yaml
permissions:
  contents: read
  id-token: write  # For AWS OIDC (if using)
  actions: read
  deployments: write
```