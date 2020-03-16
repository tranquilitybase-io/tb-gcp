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

import subprocess, os


def run_once(f):
    def wrapper(*args, **kwargs):
        if not wrapper.has_run:
            wrapper.has_run = True
            return f(*args, **kwargs)

    wrapper.has_run = False
    return wrapper


@run_once
def clone_code_store(ec_project_id, activator_terraform_code_store):
    subprocess.call(
        ["gcloud", "auth", "activate-service-account", "--key-file", os.environ['GOOGLE_APPLICATION_CREDENTIALS']])
    subprocess.call(["gcloud", "config", "set", "project", ec_project_id])
    subprocess.call(
        ["gcloud", "source", "repos", "clone", "terraform-code-store", "/opt/ec/" + activator_terraform_code_store,
         "--project", ec_project_id])
