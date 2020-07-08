output vpn_one_interface_0_ip_address {
  value = google_compute_ha_vpn_gateway.ha_gateway1.vpn_interfaces[0].ip_address
}

output vpn_one_interface_1_ip_address {
   value = google_compute_ha_vpn_gateway.ha_gateway1.vpn_interfaces[1].ip_address
}

output vpn_two_interface_0_ip_address {
  value = google_compute_ha_vpn_gateway.ha_gateway2.vpn_interfaces[0].ip_address
}

output vpn_two_interface_1_ip_address {
   value = google_compute_ha_vpn_gateway.ha_gateway2.vpn_interfaces[1].ip_address
}
