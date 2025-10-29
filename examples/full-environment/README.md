# Full Stack Example

VPC + EKS + ECR + DNS subdomain setup.

## Recommended Structure

I recommend using a directory-based organization for environments:
```
your-project/
└── environments/
    ├── dev/
    │   ├── main.tf
    │   ├── locals.tf
    │   ├── outputs.tf
    │   └── providers.tf
    ├── staging/
    │   └── ...
    └── prod/
        └── ...
```

Each environment maintains its own specifications in `locals.tf`. This keeps configs isolated and explicit.

## Why This Approach?

### Pros
- ✅ **Clear separation** - Each env is isolated
- ✅ **Easy to understand** - Open `locals.tf` and see everything
- ✅ **No variables.tf confusion** - No need for `.tfvars` files
- ✅ **Self-contained** - Each env dir has everything it needs
- ✅ **Easy to copy/paste** - Want new env? Copy folder, change `locals.tf`

### Cons
- ❌ **Repeating `main.tf` across envs** - Yeah, but it's minimal and explicit
- ❌ **Some say "should use workspaces"** - Workspaces suck for multi-env
- ❌ **Some say "should use `.tfvars`"** - More files to juggle, easier to mess up

## Setup
```bash
# Create your environment directory
mkdir -p environments/dev
cd environments/dev

# Copy these files
cp path/to/examples/full-stack/* .

# Update locals.tf with your values
vim locals.tf

# Deploy
terraform init
terraform apply
```

## Configuration

All configuration lives in `locals.tf`. Update these values:

- **DNS**: Change `subdomain`, `parent_domain`, `parent_hosted_zone_id`
- **VPC**: Adjust CIDR ranges if needed
- **EKS**: Update `cluster_admin_arns` to your IAM user/role
- **ECR**: Add/remove repositories as needed

## Why locals.tf?

I use `locals` to keep all config in one place instead of scattered `.tfvars` files. Each environment directory is self-contained and easier to understand.

## After Apply
```bash
# Configure kubectl
$(terraform output -raw kubectl_config_command)

# Login to ECR
$(terraform output -raw ecr_docker_login_command)
```
