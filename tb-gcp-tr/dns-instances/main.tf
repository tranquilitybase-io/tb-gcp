data "google_compute_instance" "linux_instances" {
  zone      = "europe-west1-b"
  self_link = element(var.linux_instances, 0)
}

data "google_compute_instance" "windows_instances" {
  zone      = "europe-west1-b"
  self_link = element(var.windows_instances, 0)
}

data "google_compute_instance" "squid_proxy_instances" {
  zone      = "europe-west1-b"
  self_link = element(var.squid_proxy_instances, 0)
}

resource "google_dns_record_set" "linux_instance_dns" {
  project = var.shared_networking
  name    = "tb-linux-bastion.${var.private_dns_domain_name}"
  type    = "A"
  ttl     = 300

  managed_zone = var.private_dns_name

  rrdatas = [data.google_compute_instance.linux_instances.network_interface[0].network_ip]

  depends_on = [
    data.google_compute_instance.linux_instances, var.private_dns_name, var.private_dns_domain_name
  ]
}

resource "google_dns_record_set" "windows_instance_dns" {
  project = var.shared_networking
  name    = "tb-windows-bastion.${var.private_dns_domain_name}"
  type    = "A"
  ttl     = 300

  managed_zone = var.private_dns_name

  rrdatas = [data.google_compute_instance.windows_instances.network_interface[0].network_ip]

  depends_on = [
    data.google_compute_instance.windows_instances, var.private_dns_name, var.private_dns_domain_name
  ]
}

resource "google_dns_record_set" "squid_proxy_dns" {
  project = var.shared_networking
  name    = "tb-squid-proxy.${var.private_dns_domain_name}"
  type    = "A"
  ttl     = 300

  managed_zone = var.private_dns_name

  rrdatas = [data.google_compute_instance.squid_proxy_instances.network_interface[0].network_ip]

  depends_on = [
    data.google_compute_instance.squid_proxy_instances, var.private_dns_name, var.private_dns_domain_name
  ]
}