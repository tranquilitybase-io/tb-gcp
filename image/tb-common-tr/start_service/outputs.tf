output "service_path" {
  value = "${var.k8s_template_file}"
}

output "id" {
  value = "${null_resource.kubernetes_resource.id}"
}