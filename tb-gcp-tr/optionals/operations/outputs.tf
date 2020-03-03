output "cluster_endpoint" {
  value = module.gke-operations.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.gke-operations.cluster_ca_certificate
}

output "access_token" {
  value = data.terraform_remote_state.landingzone.outputs.access_token
}

output "node_id" {
  value = module.gke-operations.node_id
}