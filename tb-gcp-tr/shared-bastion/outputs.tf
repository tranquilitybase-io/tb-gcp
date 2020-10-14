// outputs the set of linux bastion instances from the linux bastion instance group
output linux_bastion_instances {
  description = "The set of linux bastion instances"
  value = data.google_compute_instance_group.linux_bastion_instance_group.instances
}

// outputs the set of windows bastion instances from the windows bastion instance group
output windows_bastion_instances {
  description = "The set of windows bastion instances"
  value = data.google_compute_instance_group.windows_bastion_instance_group.instances
}

// outputs the set of squid proxy instances from the squid proxy instance group
output squid_proxy_instances {
  description = "The set of squid proxy instances"
  value = data.google_compute_instance_group.squid_proxy_instance_group.instances
}