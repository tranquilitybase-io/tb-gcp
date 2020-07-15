# Copyright 2020 The Tranquility Base Authors
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

output "name" {
  description = "The name of the bucket created by this module"
  value       = module.gcs_bucket.name
}

output "self_link" {
  description = "The self link of the bucket created by this module"
  value       = module.gcs_bucket.self_link
}

output "url" {
  description = "The base URL of the bucket created by this module, in the form gs://<name>"
  value       = module.gcs_bucket.url
}

output "gcs_bucket_access_storage_logs_name" {
  description = "The name of the bucket created by this module"
  value       = module.gcs_bucket_access_storage_logs.name
}

output "gcs_bucket_access_storage_logs_name_self_link" {
  description = "The self link of the bucket created by this module"
  value       = module.gcs_bucket_access_storage_logs.self_link
}

output "gcs_bucket_access_storage_logs_url" {
  description = "The name of the bucket created by this module"
  value       = module.gcs_bucket_access_storage_logs.url
}
