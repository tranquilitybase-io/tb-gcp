# advanced example

Creates standard subnets, kubernetes subnets with secondary networking and enables shared vpc.

1. Requires a GCP user who has been delegated Compute Shared VPC Admin role.  

2. Authenticate to GCP using the gcloud init command, providing the email address for the GCP user above with Compute Shared Admin permissions.

3. Run the following commands:

```
    terraform init
    terrafrom plan
    terraform apply
```
