resource "null_resource" "kubernetes_resource" {
  triggers {
    content = "${var.dependency_var}"
  }

  provisioner "local-exec" {
    command = <<EOF
kubectl_config_args="--kubeconfig=${var.cluster_config_path}"
if [[ -n "${var.cluster_context}" ]]; then
  kubectl_config_args="$kubectl_config_args --context=${var.cluster_context}"
fi
kubectl $kubectl_config_args apply -f ${var.k8s_template_file}
EOF
}

  provisioner "local-exec" {
    command = <<EOF
kubectl_config_args="--kubeconfig=${var.cluster_config_path}"
if [[ -n "${var.cluster_context}" ]]; then
  kubectl_config_args="$kubectl_config_args --context=${var.cluster_context}"
fi
kubectl $kubectl_config_args delete -f ${var.k8s_template_file}
EOF
    when    = "destroy"
  }
}
