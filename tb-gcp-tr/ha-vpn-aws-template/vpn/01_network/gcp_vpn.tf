// Create HA VPN gateway
resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  provider = "google-beta"
  region = var.gcp_region
  name     = var.ha_vpn_gateway
  network  = var.network
}

// Create cloud router
resource "google_compute_router" "router-a" {
  name    = var.cloud_router
  network  = var.network
  bgp {
    asn = var.gcp_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = var.subnet_ip_cidr
    }

  }
}


// Create external aka peer gateway
resource "google_compute_external_vpn_gateway" "aws_gateway" {
  provider        = "google-beta"
  name            = var.peer_gw_name
  redundancy_type = "FOUR_IPS_REDUNDANCY"
  description     = "VPN Gateway on AWS side"
  interface {
    id = 0
    ip_address = var.aws_gw1_tunnel1_address
  }
  interface {
    id = 1
    ip_address = var.aws_gw1_tunnel2_address
  }
    interface {
    id = 2
    ip_address = var.aws_gw2_tunnel1_address
  }
  interface {
    id = 3
    ip_address = var.aws_gw2_tunnel2_address
  }
}

// Create first VPN tunnel
resource "google_compute_vpn_tunnel" "tunnel1" {
  provider         = "google-beta"
  name             = var.tunnel_name_if1
  region           = var.gcp_region
  vpn_gateway      = var.ha_vpn_gateway
  peer_external_gateway = var.peer_gw_name
  peer_external_gateway_interface = 0
  shared_secret    = var.aws_gw1_tunnel1_shared_secret
  router           = var.cloud_router
  vpn_gateway_interface = 0
  ike_version = 2
  depends_on = [google_compute_router.router-a,google_compute_ha_vpn_gateway.ha_gateway,google_compute_external_vpn_gateway.aws_gateway]
}

// Create second VPN tunnel
resource "google_compute_vpn_tunnel" "tunnel2" {
  provider         = "google-beta"
  name             = var.tunnel_name_if2
  region           = var.gcp_region
  vpn_gateway      = var.ha_vpn_gateway
  peer_external_gateway = var.peer_gw_name
  peer_external_gateway_interface = 1
  shared_secret    = var.aws_gw1_tunnel2_shared_secret
  router           = var.cloud_router
  vpn_gateway_interface = 0
  ike_version = 2
  depends_on = [google_compute_router.router-a,google_compute_ha_vpn_gateway.ha_gateway,google_compute_external_vpn_gateway.aws_gateway]
}

// Create third VPN tunnel
resource "google_compute_vpn_tunnel" "tunnel3" {
  provider         = "google-beta"
  name             = var.tunnel_name_if3
  region           = var.gcp_region
  vpn_gateway      = var.ha_vpn_gateway
  peer_external_gateway = var.peer_gw_name
  peer_external_gateway_interface = 2
  shared_secret    = var.aws_gw2_tunnel1_shared_secret
  router           = var.cloud_router
  vpn_gateway_interface = 1
  ike_version = 2
  depends_on = [google_compute_router.router-a,google_compute_ha_vpn_gateway.ha_gateway,google_compute_external_vpn_gateway.aws_gateway]
}

// Create fourth VPN tunnel
resource "google_compute_vpn_tunnel" "tunnel4" {
  provider         = "google-beta"
  name             = var.tunnel_name_if4
  region           = var.gcp_region
  vpn_gateway      = var.ha_vpn_gateway
  peer_external_gateway = var.peer_gw_name
  peer_external_gateway_interface = 3
  shared_secret    = var.aws_gw2_tunnel2_shared_secret
  router           = var.cloud_router
  vpn_gateway_interface = 1
  ike_version = 2
  depends_on = [google_compute_router.router-a,google_compute_ha_vpn_gateway.ha_gateway,google_compute_external_vpn_gateway.aws_gateway]
}

// Create first cloud router interface
resource "google_compute_router_interface" "router1_interface0" {
  provider         = "google-beta"
  name       = var.router_int0
  router     = var.cloud_router
  region     = var.gcp_region
  ip_range   = var.aws_gw1_tunnel1_inside_address
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
  depends_on = [google_compute_vpn_tunnel.tunnel1]

}

// Create second cloud router interface
resource "google_compute_router_interface" "router1_interface1" {
  provider         = "google-beta"
  name       = var.router_int1
  router     = var.cloud_router
  region     = var.gcp_region
  ip_range   = var.aws_gw1_tunnel2_inside_address
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
  depends_on = [google_compute_vpn_tunnel.tunnel2]
}

// Create third cloud router interface
resource "google_compute_router_interface" "router1_interface2" {
  provider         = "google-beta"
  name       = var.router_int2
  router     = var.cloud_router
  region     = var.gcp_region
  ip_range   = var.aws_gw2_tunnel1_inside_address
  vpn_tunnel = google_compute_vpn_tunnel.tunnel3.name
  depends_on = [google_compute_vpn_tunnel.tunnel3]
}

// Create fourth cloud router interface
resource "google_compute_router_interface" "router1_interface3" {
  provider         = "google-beta"
  name       = var.router_int3
  router     = var.cloud_router
  region     = var.gcp_region
  ip_range   = var.aws_gw2_tunnel2_inside_address
  vpn_tunnel = google_compute_vpn_tunnel.tunnel4.name
  depends_on = [google_compute_vpn_tunnel.tunnel4]
}


// Create first BGP peer
resource "google_compute_router_peer" "router1_peer1" {
  provider         = "google-beta"
  name                      = var.bgp_peer_1
  router                    = var.cloud_router
  region                    = var.gcp_region
  peer_asn                  = var.gw1_tunnel1_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface0.name
  depends_on = [google_compute_router_interface.router1_interface0]
  peer_ip_address = var.aws_gw1_tunnel1_peer_ip

}


// Create second BGP peer
resource "google_compute_router_peer" "router1_peer2" {
  provider         = "google-beta"
  name                      = var.bgp_peer_2
  router                    = var.cloud_router
  region                    = var.gcp_region
  peer_asn                  = var.gw1_tunnel2_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface1.name
  depends_on = [google_compute_router_interface.router1_interface1]
  peer_ip_address = var.aws_gw1_tunnel2_peer_ip
}

// Create third BGP peer
resource "google_compute_router_peer" "router1_peer3" {
  provider         = "google-beta"
  name                      = var.bgp_peer_3
  router                    = var.cloud_router
  region                    = var.gcp_region
  peer_asn                  = var.gw2_tunnel1_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface2.name
  depends_on = [google_compute_router_interface.router1_interface2]
  peer_ip_address = var.aws_gw2_tunnel1_peer_ip

}


// Create fourth BGP peer
resource "google_compute_router_peer" "router1_peer4" {
  provider         = "google-beta"
  name                      = var.bgp_peer_4
  router                    = var.cloud_router
  region                    = var.gcp_region
  peer_asn                  = var.gw2_tunnel2_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface3.name
  depends_on = [google_compute_router_interface.router1_interface3]
  peer_ip_address = var.aws_gw2_tunnel2_peer_ip
}
