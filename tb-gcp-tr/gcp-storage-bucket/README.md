# Terraform Module Google Cloud Storage Bucket 

A Terraform module for creating a GCS bucket.

This module:

* Covers a set amount of attributes exposed by Terraform's [`google_storage_bucket`](https://www.terraform.io/docs/providers/google/r/storage_bucket.html) resource:
  * location
  * storage class
  * logging
  * lifecycle rules
  * retention policy
  * encryption
  * versioning
  * uniform bucket-level access
  * website
  
The resources/services/activations/deletions that this module will create/trigger are:

- One GCS bucket
- Zero or more IAM bindings for that bucket

## Compatibility

This module is meant for use with Terraform >=0.12.

## Usage

Basic usage of this module is as follows:

If the "tb-bucket-access-storage-logs" bucket does not already exist then remember to ensure you create a separate bucket in TB with this name. It is required to allow GCS bucket logging no matter how complex the bucket configuration. This is needed to comply with CIS/NIST/PCI/ISO.

Example with log bucket not existing

```hcl
# create a bucket for the access & storage logs
module "gcs_bucket_access_storage_logs" {
  source     = "../../modules/simple_bucket"
 
  name       = "tb-bucket-access-storage-logs"
  project_id = module.shared_projects.shared_telemetry_id
  iam_members = var.iam_members_bindings
}

# create the main bucket and use the other bucket for its access logs
module "gcs_bucket" {
  source  = "../../modules/simple_bucket"

  name       = "a-globally-unique-name-zi01farm"
  project_id = module.shared_projects.shared_telemetry_id
  log_bucket = module.gcs_bucket_access_storage_logs.name
}
```
Example with log bucket existing

```hcl
# create the main bucket and use the other bucket for its access & storage logs
module "gcs_bucket" {
  source  = "../../modules/simple_bucket"

  name       = "a-globally-unique-name-zi01farm"
  project_id = module.shared_projects.shared_telemetry_id
  log_bucket = "tb-bucket-access-storage-logs"
}
```
Example with more features - the bucket features are not mutually exclusive so you can, of course, mix and match. For example:
```hcl
# create a bucket for the access & storage logs
module "gcs_bucket_access_storage_logs" {
  source     = "../../modules/simple_bucket"
 
  name       = "tb-bucket-access-storage-logs"
  project_id = module.shared_projects.shared_telemetry_id
  iam_members = var.iam_members_bindings
}

# create the main bucket and use the other bucket for its access logs
module "gcs_bucket" {
  source             = "../../modules/simple_bucket"
  
  name               = "a-globally-unique-name-zi01farm" 
  project_id         = module.shared_projects.shared_telemetry_id
  log_bucket         = module.gcs_bucket_access_storage_logs.name
  location           = "europe-west2"
  storage_class      = "REGIONAL"
  force_destroy      = false
  bucket_policy_only = true
  versioning_enabled = false
  set_admin_roles    = true

  lifecycle_rules = [{
    action = {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition = {
      age                   = "10"
      matches_storage_class = "MULTI_REGIONAL"
    }
  }]

  admins = ["group:foo-admins@example.com"]
  bucket_admins = {
    second = "user:spam@example.com,eggs@example.com"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| project\_id | The ID of the project to create the bucket in. | string | `""` | yes |
| name | The name of the bucket. | string | n/a | yes |
| log_bucket | The name of the bucket to which access logs for this bucket should be written. If this is not supplied then no access logs are written. | string | `"null"` | yes |
| log_object_prefix | The prefix for access log objects. If this is not provided then GCS defaults it to the name of the source bucket. | string  | `"null"` | no |
| bucket\_policy\_only | Enables Bucket Policy Only access to a bucket. | bool | `"true"` | no |
| encryption | A Cloud KMS key that will be used to encrypt objects inserted into this bucket | object | `"null"` | no |
| force\_destroy | When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects. | bool | `"false"` | no |
| iam\_members | The list of IAM members to grant permissions on the bucket. | object | `<list>` | no |
| labels | A set of key/value label pairs to assign to the bucket. | map(string) | `"null"` | no |
| lifecycle\_rules | The bucket's Lifecycle Rules configuration. | object | `<list>` | no |
| location | The location of the bucket. | string | "EU" | no |
| retention\_policy | Configuration of the bucket's data retention policy for how long objects in the bucket should be retained. | object | `"null"` | no |
| storage\_class | The Storage Class of the new bucket. | string | `"null"` | no |
| versioning | While set to true, versioning is fully enabled for this bucket. | bool | `"true"` | no |
| buckets_depend_on | Optional list of resources that need to be created before our bucket creation. | bool | `"null"` | no |
| website_main_page_suffix | The name of a file in the bucket which will act as the 'index' page to be served by GCS if this bucket is hosting a static website. | any | `"null"` | no |
| website_not_found_page | The name of the 'not found' page to be served by GCS if this bucket is hosting a static website. | any | `"null"` | no |
| bucket\_admins | Map of lowercase unprefixed name => comma-delimited IAM-style bucket admins. | map | `<map>` | no |
| bucket\_creators | Map of lowercase unprefixed name => comma-delimited IAM-style bucket creators. | map | `<map>` | no |
| bucket\_viewers | Map of lowercase unprefixed name => comma-delimited IAM-style bucket viewers. | map | `<map>` | no |
| set\_admin\_roles | Grant roles/storage.objectAdmin role to admins and bucket_admins. | bool | `"false"` | no |
| set\_creator\_roles | Grant roles/storage.objectCreator role to creators and bucket_creators. | bool | `"false"` | no |
| set\_viewer\_roles | Grant roles/storage.objectViewer role to viewers and bucket_viewers. | bool | `"false"` | no |
| admins | IAM-style members who will be granted roles/storage.objectAdmin on all buckets. | list(string) | `<list>` | no |
| viewers | IAM-style members who will be granted roles/storage.objectViewer on all buckets. | list(string) | `<list>` | no |
| creators | IAM-style members who will be granted roles/storage.objectCreators on all buckets. | list(string) | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The name of bucket |
| self_link | The URI of the created resource |
| url | The base URL of the bucket, in the format gs:// |