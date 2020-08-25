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

resource "null_resource" "kubernetes_resource" {
  triggers = {
    content = var.dependency_var
    k8s_template = var.k8s_template_file
    cluster_config_path = var.cluster_config_path
    context = var.cluster_context
  }

  provisioner "local-exec" {
    command = <<EOF
echo 'kubectl_config_args="--kubeconfig=${var.cluster_config_path}"
if [[ -n "${var.cluster_context}" ]]; then
  kubectl_config_args="$kubectl_config_args --context=${var.cluster_context}"
fi
kubectl $kubectl_config_args apply -f ${var.k8s_template_file}' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh
EOF

  }

  provisioner "local-exec" {
    command = <<EOF
echo 'kubectl_config_args="--kubeconfig=${self.triggers.cluster_config_path}"
if [[ -n "${self.triggers.context}" ]]; then
  kubectl_config_args="$kubectl_config_args --context=${self.triggers.context}"
fi
kubectl $kubectl_config_args delete -f ${self.triggers.k8s_template}' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh
EOF


    when = destroy
  }
}

