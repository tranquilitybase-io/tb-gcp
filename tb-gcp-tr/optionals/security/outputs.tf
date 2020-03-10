output "cluster_sa" {
  value = module.gke-security.cluster_endpoint
}

output "cluster_endpoint" {
  value = module.gke-security.cluster_ca_certificate
}

output "cluster_master_auth_username" {
  value = module.gke-security.cluster_master_auth_username
}

output "cluster_master_auth_password" {
  value = module.gke-security.cluster_master_auth_password
}

output "cluster_master_auth_0_client_certificate" {
  value = module.gke-security.cluster_master_auth_0_client_certificate
}

output "cluster_master_auth_0_client_key" {
  value = module.gke-security.cluster_master_auth_0_client_key
}

output "cluster_master_auth_0_cluster_ca_certificate" {
  value = module.gke-security.cluster_master_auth_0_cluster_ca_certificate
}
