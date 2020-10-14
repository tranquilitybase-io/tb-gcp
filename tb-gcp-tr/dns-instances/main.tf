data "google_compute_instance" "linux_instances" {
  for_each = var.linux_instances
  zone = var.zone
  self_link = each.value
}

data "google_compute_instance" "windows_instances" {
  for_each = var.windows_instances
  zone = var.zone
  self_link = each.value
}

data "google_compute_instance" "squid_proxy_instances" {
  for_each = var.squid_proxy_instances
  zone = var.zone
  self_link = each.value
}

resource "google_dns_record_set" "linux_instance_dns" {
  count = length(var.linux_instances)
  name = "tb-linux-bastion-${count.index}.${var.private_dns_domain_name}"
  type = "A"
  ttl  = 300

  managed_zone = var.private_dns_name

  rrdatas = [element([for u in data.google_compute_instance.linux_instances:u.network_interface[0].network_ip], count.index)]

    depends_on = [
    data.google_compute_instance.linux_instances, var.private_dns_name, var.private_dns_domain_name
  ]
}

resource "google_dns_record_set" "windows_instance_dns" {
  count = length(var.windows_instances)
  name = "tb-windows-bastion-${count.index}.${var.private_dns_domain_name}"
  type = "A"
  ttl  = 300

  managed_zone = var.private_dns_name

  rrdatas = [element([for u in data.google_compute_instance.windows_instances:u.network_interface[0].network_ip], count.index)]

    depends_on = [
    data.google_compute_instance.windows_instances, var.private_dns_name, var.private_dns_domain_name
  ]
}

resource "google_dns_record_set" "squid_proxy_dns" {
  count = length(var.squid_proxy_instances)
  name = "tb-squid-proxy-${count.index}.${var.private_dns_domain_name}"
  type = "A"
  ttl  = 300

  managed_zone = var.private_dns_name

  rrdatas = [element([for u in data.google_compute_instance.squid_proxy_instances:u.network_interface[0].network_ip], count.index)]

    depends_on = [
    data.google_compute_instance.squid_proxy_instances, var.private_dns_name, var.private_dns_domain_name
  ]
}
