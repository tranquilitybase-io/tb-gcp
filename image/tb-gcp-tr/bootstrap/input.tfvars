# Copyright 2019 The Tranquility Base Authors
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#PROVIDER
region = "europe-west2"
region_zone = "europe-west2-a"
folder_id = "943956663445"
billing_account_id = "01A2F5-73127B-50AE5B"
tb_discriminator = "dev"
lz_branch = "master"

#CREATE-BOOTSTRAP-TERRAFORM-SERVER
terraform_server_name = "terraform-server"
terraform_server_machine_type = "f1-micro"
bootstrap_host_disk_image = "projects/debian-cloud/global/images/family/debian-9"
metadata_startup_script = "create_bootstrap_host_module/files/bootstrap.sh"
scopes = ["https://www.googleapis.com/auth/cloud-platform"]

main_iam_service_account_roles = ["roles/resourcemanager.folderAdmin", "roles/resourcemanager.projectCreator",
  "roles/resourcemanager.projectDeleter", "roles/billing.projectManager", "roles/compute.xpnAdmin", "roles/owner", "roles/compute.networkAdmin"]
