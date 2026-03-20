# CLAUDE.md — {{project_name}}

## Purpose
{{one-line description}}

## Commands
```bash
# Init
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy
```

## Rules
- Always `terraform plan` before `terraform apply`
- Store state remotely for shared projects
- Tag every resource with Owner, Team, Purpose
- Store secrets in Key Vault, never in .tf files
- Add new resources to the README infrastructure table
