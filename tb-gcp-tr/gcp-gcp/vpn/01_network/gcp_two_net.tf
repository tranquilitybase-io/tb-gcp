resource "google_compute_network" "main_two" {
  name                    = var.gcp_vpc_two
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  description = "VPN connection between GCP and GCP"
}

resource "google_compute_subnetwork" "network2_subnet" {
  name          = var.net2_sub
  ip_cidr_range = var.net2_sub_cidr
  region = var.gcp_region
  network       = google_compute_network.main_two.self_link
  depends_on = [google_compute_network.main_two]
}

// Create cloud router
resource "google_compute_router" "main_two" {
  name    = var.cloud_router_two
  network  = var.gcp_vpc_two
  bgp {
    asn = var.gcp_asn_two
   # advertise_mode    = "CUSTOM"
    #advertised_groups = ["ALL_SUBNETS"]
    #advertised_ip_ranges {
     # range = google_compute_subnetwork.network1-subnet1.ip_cidr_range
    #}
    #advertised_ip_ranges {
     # range = google_compute_subnetwork.network1-subnet2.ip_cidr_range
    }
  depends_on = [google_compute_network.main_two]
  }

// Create HA VPN gateway
resource "google_compute_ha_vpn_gateway" "ha_gateway2" {
  provider = "google-beta"
  region = var.gcp_region
  name     = var.vpn_gw_two
  network  = var.gcp_vpc_two
  depends_on = [google_compute_network.main_two]
}

// Create first VPN tunnel
resource "google_compute_vpn_tunnel" "tunnel2" {
  provider         = "google-beta"
  name             = var.tunnel2
  region           = var.gcp_region
  vpn_gateway      = google_compute_ha_vpn_gateway.ha_gateway2.name
  peer_gcp_gateway = google_compute_ha_vpn_gateway.ha_gateway1.name
  shared_secret    = "1234"
  router           = google_compute_router.main_two.self_link
  vpn_gateway_interface = 0
  depends_on = [google_compute_router.main_two,google_compute_ha_vpn_gateway.ha_gateway2,google_compute_ha_vpn_gateway.ha_gateway1]
}

// Create second VPN tunnel
resource "google_compute_vpn_tunnel" "tunnel3" {
  provider         = "google-beta"
  name             = var.tunnel3
  region           = var.gcp_region
  vpn_gateway      = google_compute_ha_vpn_gateway.ha_gateway2.name
  peer_gcp_gateway = google_compute_ha_vpn_gateway.ha_gateway1.name
  shared_secret    = "1234"
  router           = google_compute_router.main_two.self_link
  vpn_gateway_interface = 1
  depends_on = [google_compute_router.main_two,google_compute_ha_vpn_gateway.ha_gateway2,google_compute_ha_vpn_gateway.ha_gateway1]
}

// Create first cloud router interface
resource "google_compute_router_interface" "vpc_two_int0" {
  provider   = "google-beta"
  name       = var.router2_int0
  router     = google_compute_router.main_two.name
  region     = var.gcp_region
  ip_range   = var.router2_inside1
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.self_link
  depends_on = [google_compute_router.main_two,google_compute_vpn_tunnel.tunnel2]
}

// Create second cloud router interface
resource "google_compute_router_interface" "vpc_two_int1" {
  provider   = "google-beta"
  name       = var.router2_int1
  router     = google_compute_router.main_two.name
  region     = var.gcp_region
  ip_range   = var.router2_inside2
  vpn_tunnel = google_compute_vpn_tunnel.tunnel3.self_link
  depends_on = [google_compute_router.main_two,google_compute_vpn_tunnel.tunnel3]
}

// Create first BGP peer
resource "google_compute_router_peer" "network2_peer0" {
  provider         = "google-beta"
  name                      = var.bgp_peer_3
  router                    = google_compute_router.main_two.name
  region                    = var.gcp_region
  peer_asn                  = var.gcp_asn_one
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.vpc_two_int0.name
  peer_ip_address = var.router2_peer1
  depends_on = [google_compute_router.main_two,google_compute_router_interface.vpc_two_int0]

}

// Create second BGP peer
resource "google_compute_router_peer" "network2_peer1" {
  provider         = "google-beta"
  name                      = var.bgp_peer_4
  router                    = google_compute_router.main_two.name
  region                    = var.gcp_region
  peer_asn                  = var.gcp_asn_one
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.vpc_two_int1.name
  peer_ip_address = var.router2_peer2
  depends_on = [google_compute_router.main_two,google_compute_router_interface.vpc_two_int1]
}