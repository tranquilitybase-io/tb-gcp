output vpn_interface_0_ip_address {
  value = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address
}

output vpn_interface_1_ip_address {
   value = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address
}
