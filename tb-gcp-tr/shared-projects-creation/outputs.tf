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

output "shared_networking_id" {
  description = "identifier for the shared_networking project."
  value       = google_project.shared_networking.project_id
}

output "shared_secrets_id" {
  description = "identifier for the shared_secrets project."
  value       = google_project.shared_secrets.project_id
}

output "shared_itsm_id" {
  description = "identifier for the shared_itsm project."
  value       = google_project.shared_itsm.project_id
}

output "shared_telemetry_id" {
  description = "identifier for the shared_telemetry project."
  value       = google_project.shared_telemetry.project_id
}

output "shared_ssp_id" {
  description = "identifier for the shared_ssp project."
  value       = google_project.shared_ssp.project_id
}

output "shared_ssp_name" {
  description = "identifier for the shared_ssp project."
  value       = google_project.shared_ssp.name
}

output "tb_bastion_id" {
  description = "identifier for the tab_bastion project."
  value       = google_project.tb_bastion.id
}
