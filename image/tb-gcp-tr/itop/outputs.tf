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

output "database_instance_id" {
    description = "The created database instance id"
    value = "google_sql_database_instance.master.project.project_id"

}

output "database_instance_connection_name" {
    description = "The database connection name"
    value = "google_sql_database_instance.master.connection_name"
}

output "database_instance_connection_username" {
    description = "The database connection password"
    value = "${var.database_user_name}"
}

output "database_instance_connection_password" {
    description = "The database connection password"
    value = "${random_password.itop_db_user_password.result}"
}
