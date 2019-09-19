# Folder and Project Structure for the GCP Landing Zone

Currently very simple, creates three directories, root can be either an org, or an existing directory inside an org

Requires a user with "roles/resourcemanager.folderCreator"

1. Authenticate to GCP using the gcloud init command, providing the email address for the GCP user

2. Amend the terraform.tfvars file accordingly

3. Run the following commands:

```
    terraform init
    terraform plan
    terraform apply
```