#!/bin/bash

# GitHub Environment Protection Rules Setup Helper
# This script provides instructions for setting up environment protection rules

set -e

echo "🔒 GitHub Environment Protection Rules Setup"
echo "==========================================="
echo
echo "To complete your CI/CD pipeline setup, you need to configure approval gates"
echo "for the QA and Production environments in your GitHub repository."
echo
echo "📋 Setup Instructions:"
echo
echo "1. Navigate to your GitHub repository"
echo "2. Go to Settings → Environments"
echo "3. Set up the following environments:"
echo

echo "🔧 QA Environment Setup:"
echo "------------------------"
echo "• Environment name: qa"
echo "• Required reviewers: Add 1+ team members who should approve QA deployments"
echo "• Prevent self-review: ✅ Recommended"
echo "• Wait timer: 5 minutes (optional)"
echo "• Deployment branches: main (optional, for additional security)"
echo

echo "🔧 Production Environment Setup:"
echo "--------------------------------"
echo "• Environment name: prod"
echo "• Required reviewers: Add 2+ senior team members for production approvals"
echo "• Prevent self-review: ✅ Required"
echo "• Wait timer: 30 minutes (recommended)"
echo "• Deployment branches: main only (recommended)"
echo

echo "⚙️  Additional Configuration:"
echo "----------------------------"
echo "Set up the following repository secrets:"
echo "• AWS_ACCESS_KEY_ID - Your AWS access key"
echo "• AWS_SECRET_ACCESS_KEY - Your AWS secret key"
echo "• TF_STATE_BUCKET - S3 bucket name for Terraform state storage"
echo

echo "🚀 Quick Test:"
echo "-------------"
echo "After setup, test the pipeline by:"
echo "1. Making a small change to terraform/ files"
echo "2. Pushing to main branch"
echo "3. Watching the GitHub Actions workflow"
echo "4. Approving the QA deployment when prompted"
echo "5. Approving the Production deployment when prompted"
echo

echo "📖 For detailed instructions, see:"
echo "   docs/terraform-cicd-setup.md"
echo

echo "✅ Environment protection rules are essential for:"
echo "   • Preventing accidental production deployments"
echo "   • Ensuring proper review before infrastructure changes"
echo "   • Maintaining audit trail of who approved what"
echo

read -p "Press Enter to open the GitHub Environments page in your browser (if available)..."

# Try to open the environments page (works on some systems)
if command -v xdg-open > /dev/null; then
    echo "Opening GitHub Environments page..."
    xdg-open "https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/settings/environments" 2>/dev/null || echo "Could not open browser. Please navigate manually to GitHub Settings → Environments"
elif command -v open > /dev/null; then
    echo "Opening GitHub Environments page..."
    open "https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/settings/environments" 2>/dev/null || echo "Could not open browser. Please navigate manually to GitHub Settings → Environments"
else
    echo "Please navigate to: GitHub Settings → Environments to complete setup"
fi

echo
echo "🎉 Once configured, your CI/CD pipeline will be fully operational!"