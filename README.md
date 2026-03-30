# AWS Web Infrastructure with Terraform

A modular Terraform project that deploys simple web servers on AWS.

## Architecture & Structure

```text
.
├── .github/workflows/   # CI/CD pipeline configurations (GitHub Actions)
├── environments/        # Environment-specific configurations (Development, Staging, Production)
│   └── dev/             # Development environment consuming the core module
├── global/              # Global infrastructure (S3 backend & DynamoDB locking)
└── modules/             # Reusable Terraform modules
    └── web-app-module/  # Core logic (EC2, Security Groups, ALB, Networking)
```

## Prerequisites

To operate this infrastructure locally, ensure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.14.0 or newer)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate IAM permissions

## Deployment

### Continuous Integration & Deployment (CI/CD)

This project utilises GitHub Actions to manage infrastructure changes safely:

- **Pull Requests:** Automatically trigger `terraform fmt`, `init`, and `plan`. A summary of the execution plan is posted directly to the PR for review.

- **Merges to Main:** Automatically trigger `terraform apply` to provision resources on AWS.

- **Workflow Dispatch:** Manual triggers are available in the GitHub Actions UI to run `apply` or `destroy` operations on demand.

### Local Execution

To deploy or test locally:

1. Navigate to the target environment:

   ```bash
   cd environments/dev
   ```
2. Initialise the working directory (downloads plugins and configures the S3 backend):

   ```bash
   terraform init
   ```
3. Preview the infrastructure changes:

   ```bash
   terraform plan
   ```
4. Provision the resources:

   ```bash
   terraform apply
   ```

## State Management

State files are strictly managed remotely enabling team collaboration and preventing race conditions. The backend uses an encrypted **Amazon S3 Bucket** to store the `terraform.tfstate` and an **Amazon DynamoDB Table** for state locking.

## Backend Configuration Note

The example backend configuration in this repository uses a placeholder S3 bucket name (for example, `tf-state-2026`). **Before running `terraform init` or `terraform apply`, this bucket name bust me replaced with one that is globally unique** and ensure that the same name is used consistently in:

- The S3 bucket and DynamoDB table definitions under `global/`

- Any `backend "s3"` blocks in each environment under `environments/`

- Any CI/CD workflow configuration that passes backend settings to Terraform

***