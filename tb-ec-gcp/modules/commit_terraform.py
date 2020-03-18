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

import hashlib
from python_terraform import *
from subprocess import Popen
from os import popen


def commit_terraform(terraform_path, backend_prefix, user_email, activator_terraform_code_store):
    Popen(["/opt/ec/bash/pull_changes.sh", ], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
          universal_newlines=True, shell=False).communicate()
    popen("mkdir -p " "/opt/ec/" + activator_terraform_code_store + "/" + backend_prefix, shell=False)
    popen("cp -a " + terraform_path + "*" + " /opt/ec/" + activator_terraform_code_store + "/" + backend_prefix, shell=False)
    Popen(["/opt/ec/bash/git_init.sh", user_email, ], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
          universal_newlines=True, shell=False).communicate()
    Popen(["/opt/ec/bash/commit_changes.sh", ], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
          universal_newlines=True, shell=False).communicate()

def create_hash(user, app_name):
    sha_1 = hashlib.sha256
    encoded_data = (app_name + user).encode('utf-8')
    sha_1.update(encoded_data)
    return sha_1.hexdigest()
