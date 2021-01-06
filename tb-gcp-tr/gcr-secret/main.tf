resource "null_resource" "gcr_root_folder_id_cicd" {
  triggers = {
    content = var.content
    k8_name = var.context_name
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${var.context_name} create secret generic gcr-folder -n cicd --from-literal=username=folder --from-literal=password='${var.root_id}' --type=kubernetes.io/basic-auth' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh"
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${self.triggers.k8_name} delete secret gcr-folder' -n cicd | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh"
    when    = destroy
  }
}
