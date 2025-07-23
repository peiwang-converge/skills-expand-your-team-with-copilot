# Terraform Deployment Quick Reference

## Deployment Flow
```
📝 Code Push → 🔍 Security Scan → 🚀 Dev → ⏳ QA Approval → 🚀 QA → ⏳ Prod Approval → 🚀 Prod
```

## Approval Process

### QA Deployment
1. Development deployment completes automatically
2. QA deployment job waits for approval
3. Reviewers receive GitHub notification
4. Click "Review deployments" to approve/reject
5. QA deployment proceeds after approval

### Production Deployment  
1. QA deployment completes successfully
2. Production deployment job waits for approval
3. Senior reviewers receive GitHub notification
4. Click "Review deployments" to approve/reject
5. Production deployment proceeds after approval

## Key Features

✅ **Non-blocking security scan** - Checkov results don't fail pipeline  
✅ **Environment isolation** - Separate configs and state files  
✅ **Approval gates** - Manual approval required for QA/Prod  
✅ **Audit trail** - All deployments logged and tracked  

## Quick Setup Checklist

- [ ] Configure AWS secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `TF_STATE_BUCKET`)
- [ ] Set up QA environment protection rules (1+ reviewers)
- [ ] Set up Prod environment protection rules (2+ reviewers)
- [ ] Test pipeline with a small change
- [ ] Verify Checkov scan results are accessible

## Environment URLs

Update these in the workflow after deployment:
- **QA**: Update `qa.example.com` to actual QA URL
- **Prod**: Update `prod.example.com` to actual production URL

## Emergency Procedures

### Skip QA and deploy directly to Prod
❌ **Not recommended** - Use environment protection rules to bypass if absolutely necessary

### Rollback
1. Revert the problematic commit
2. Push to main branch
3. Follow normal approval process

---
💡 **Tip**: Always review Checkov security scan results even though they don't block deployments