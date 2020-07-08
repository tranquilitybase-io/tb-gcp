
resource "google_compute_network" "main_one" {
  name                    = var.gcp_vpc_one
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  description = "VPN connection between GCP and GCP"
}

resource "google_compute_subnetwork" "network1_subnet" {
  name          = var.net1_sub
  ip_cidr_range = var.net1_sub_cidr
  region = var.gcp_region
  network       = google_compute_network.main_one.self_link
   depends_on = [google_compute_network.main_one]
}


// Create cloud router
resource "google_compute_router" "main_one" {
  name    = var.cloud_router_one
  network  = var.gcp_vpc_one
  bgp {
    asn = var.gcp_asn_one
   # advertise_mode    = "CUSTOM"
    #advertised_groups = ["ALL_SUBNETS"]
    #advertised_ip_ranges {
     # range = google_compute_subnetwork.network1-subnet1.ip_cidr_range
    #}
    #advertised_ip_ranges {
     # range = google_compute_subnetwork.network1-subnet2.ip_cidr_range
    }
  depends_on = [google_compute_network.main_one]
  }

// Create HA VPN gateway
resource "google_compute_ha_vpn_gateway" "ha_gateway1" {
  provider = "google-beta"
  region = var.gcp_region
  name     = var.vpn_gw_one
  network  = var.gcp_vpc_one
  depends_on = [google_compute_network.main_one]
}


// Create first VPN tunnel
resource "google_compute_vpn_tunnel" "tunnel0" {
  provider         = "google-beta"
  name             = var.tunnel0
  region           = var.gcp_region
  vpn_gateway      = google_compute_ha_vpn_gateway.ha_gateway1.name
  peer_gcp_gateway = google_compute_ha_vpn_gateway.ha_gateway2.name
  shared_secret    = "1234"
  router           = google_compute_router.main_one.self_link
  vpn_gateway_interface = 0
  depends_on = [google_compute_router.main_one,google_compute_ha_vpn_gateway.ha_gateway1,google_compute_ha_vpn_gateway.ha_gateway2]
}

// Create second VPN tunnel
resource "google_compute_vpn_tunnel" "tunnel1" {
  provider         = "google-beta"
  name             = var.tunnel1
  region           = var.gcp_region
  vpn_gateway      = google_compute_ha_vpn_gateway.ha_gateway1.name
  peer_gcp_gateway = google_compute_ha_vpn_gateway.ha_gateway2.name
  shared_secret    = "1234"
  router           = google_compute_router.main_one.self_link
  vpn_gateway_interface = 1
  depends_on = [google_compute_router.main_one,google_compute_ha_vpn_gateway.ha_gateway1,google_compute_ha_vpn_gateway.ha_gateway2]
}

// Create first cloud router interface
resource "google_compute_router_interface" "router-name-10" {
  provider   = "google-beta"
  name       = var.router1_int0
  router     = google_compute_router.main_one.name
  region     = var.gcp_region
  ip_range   = var.router1_inside1
  vpn_tunnel = google_compute_vpn_tunnel.tunnel0.self_link
  depends_on = [google_compute_router.main_one,google_compute_vpn_tunnel.tunnel0]
}

// Create second cloud router interface
resource "google_compute_router_interface" "router-name-11" {
  provider   = "google-beta"
  name       = var.router1_int1
  router     = google_compute_router.main_one.name
  region     = var.gcp_region
  ip_range   = var.router1_inside2
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.self_link
  depends_on = [google_compute_router.main_one,google_compute_vpn_tunnel.tunnel1]
}

// Create first BGP peer
resource "google_compute_router_peer" "network1_peer0" {
  provider         = "google-beta"
  name                      = var.bgp_peer_1
  router                    = google_compute_router.main_one.name
  region                    = var.gcp_region
  peer_asn                  = var.gcp_asn_two
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router-name-10.name
  peer_ip_address = var.router1_peer1
  depends_on = [google_compute_router.main_one,google_compute_router_interface.router-name-10]

}

// Create second BGP peer
resource "google_compute_router_peer" "network1_peer1" {
  provider         = "google-beta"
  name                      = var.bgp_peer_2
  router                    = google_compute_router.main_one.name
  region                    = var.gcp_region
  peer_asn                  = var.gcp_asn_two
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router-name-11.name
  peer_ip_address = var.router1_peer2
  depends_on = [google_compute_router.main_one,google_compute_router_interface.router-name-11]
}

