output "cluster_endpoint" {
  value = module.gke-itsm.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.gke-itsm.cluster_ca_certificate
}

output "node_id" {
  value = module.gke-itsm.node_id
}