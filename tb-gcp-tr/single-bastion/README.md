# Applying The Terraform Plan
1. Requires a terraform service account and associated JSON key file.  Service account needs appropriate permisions to create compute instance.

1. Copy file terraform.tfvars.example to terraform.tfvars and amend accordingly.

1. Run the following commands:

```
    terraform init -backend-config="credentials=[PATH]" -backend-config="bucket=[BUCKET_NAME]"
    terrafrom plan
    terraform apply
```

Variables cannot be passed to the terraform code block, therefore "-backend-config" needs to be passed to terraform init
