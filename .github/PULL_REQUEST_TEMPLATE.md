## Description

Please include a summary of the changes and which environments this affects.

- [ ] Dev-a
- [ ] Dev-b  
- [ ] Release
- [ ] Prod

## Type of Change

- [ ] Infrastructure addition
- [ ] Infrastructure modification
- [ ] Infrastructure removal
- [ ] Configuration change

## Related Issues

Closes #(issue number)

## Terraform Plan Summary

Please paste the output of `terraform plan` from your local machine:

```terraform
(paste output here)
```

## Testing

- [ ] Ran `terraform init`
- [ ] Ran `terraform validate`
- [ ] Ran `terraform plan` with appropriate `.tfvars`
- [ ] Verified formatting with `terraform fmt -check`
- [ ] Tested locally in dev environment

## Checklist

- [ ] My code follows the Terraform best practices
- [ ] I have tested this change locally
- [ ] I have updated the README or documentation if needed
- [ ] No hardcoded secrets or credentials
- [ ] State file considerations documented (if applicable)
- [ ] I have verified this doesn't break existing infrastructure
- [ ] All variables are documented

## Deployment Instructions

After approval and merge, deploy using:

**For Dev-a:**
- Go to Actions → Terraform Deploy → Run workflow
- Select environment: `dev`
- Select variant: `dev-a`

**For Dev-b:**
- Go to Actions → Terraform Deploy → Run workflow
- Select environment: `dev`
- Select variant: `dev-b`

**For Release:**
- Go to Actions → Terraform Deploy → Run workflow
- Select environment: `release`

**For Prod:**
- Go to Actions → Terraform Deploy → Run workflow
- Select environment: `prod`
