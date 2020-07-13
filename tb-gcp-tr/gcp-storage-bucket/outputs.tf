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

output "name" {
  description = "The name of the bucket created by this module"
  value       = google_storage_bucket.bucket.name
}

output "self_link" {
  description = "The self link of the bucket created by this module"
  value       = google_storage_bucket.bucket.self_link
}

output "url" {
  description = "The base URL of the bucket created by this module, in the form gs://<name>"
  value       = google_storage_bucket.bucket.url
}