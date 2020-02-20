#CREATE-CLOUD-NAT-ROUTER
resource "google_compute_router" "router" {
  name    = var.router_name
  network = var.vpc_name
  project = var.project_id
  region  = var.region
}

resource "google_compute_address" "nat_gw_ip" {
  address_type = "EXTERNAL"
  name         = "${var.router_nat_name}-ip"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_router_nat" "nat_gw" {
  name                               = var.router_nat_name
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_gw_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
