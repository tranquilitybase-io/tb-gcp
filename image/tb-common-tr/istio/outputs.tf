output "namespace_istio_system_name" {
  value = "${kubernetes_namespace.istio_system.metadata.0.name}"
}

output "name_istio_relesas" {
  value = "${helm_release.istio.id}"
}

output "endpoint_file_generated" {
  description = "List showing that endpoint file has been generated"
  value = "${ join(" ", null_resource.get_endpoint.*.id )}"
}