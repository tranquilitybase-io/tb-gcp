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

###
# Root module (activates other modules)
###

# CREATE CLOUD SQL MYSQL INSTANCE
resource "google_sql_database_instance" "eagle-db" {
  name = "eagle-db"
  database_version = "MYSQL_5_7"
  region = var.region
  project = var.shared_ec_project_name

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "database" {
  name = "eagle_db"
  instance = google_sql_database_instance.eagle-db.name
  charset = "utf8"
}

resource "google_sql_user" "user" {
  instance = google_sql_database_instance.eagle-db.name
  name = var.db_user
  password = var.db_password
  depends_on = [
    "google_sql_database_instance.eagle-db"
  ]

//  provisioner "local-exec" {
//    command = "psql postgresql://${google_sql_user.user.name}:${google_sql_user.user.password}@${google_sql_database_instance.eagle_db.public_ip_address}/postgres -c \"CREATE SCHEMA myschema;\""
//  }
}