TB Static-Host Terraform module
=========================

This module creates GCS bucket, sets the object ACLs and creates loadBalancer that exposes the bucket to the public.

Inputs
=========================

**bucket_name**
The prefix attached to the bucket name. The whole name of the bucket is combined from this variable and project name

**bucket_location**
 Location of the bucket that will store the static website

**project_id**
ID of the project where the bucket will be created

**bucket_storage_class**
"Storage class of the bucket that will store the static website. This can be MULTI_REGIONAL, REGIONAL, NEARLINE or COLDLINE"

**bucket_versioning**
Decides if the bucket should be versioned

**main_page_suffix**
File that is treated as a main index

**not_found_page**
File bad requests are redirected to

**role_entity**
Sets bucket default object ACLs. If bucket should have public objects keep it as default

**source_bucket**
The name of the bucket where to find files to be uploaded to newly created bucket. If you want to create empty bucket keep it empty


Outputs
===============================

**self_link**
The URI of the bucket

**external_ip**
IP to access the bucket via browser in public network

**bucket_name**
Full name of created bucket