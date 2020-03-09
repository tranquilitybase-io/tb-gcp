# Applying The Terraform Plan
1. Requires a GCP user who has been delegated Compute Shared VPC Admin role.  

2. Compute API services need to be enabled for the host and service projects.  Terraform scripting of enabling services is problematic, it's better to use the gcloud cli instead.

The commands below can be run in the google cloud shell, with appropriate permissions.

```
gcloud services enable compute.googleapis.com [--project project_id]
gcloud services enable container.googleapis.com [--project project_id]
```

3. Authenticate to GCP using the gcloud init command, providing the email address for the GCP user above with Compute Shared Admin permissions.

4. Amend the terraform.tfvars file accordingly.

5. Run the following commands:

```
    terraform init
    terrafrom plan
    terraform apply
```
