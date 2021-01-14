// Gets the linux bastion instance group from the linux bastion instance group manager
data "google_compute_instance_group" "linux_bastion_instance_group" {
  depends_on = [time_sleep.linux_wait_30_seconds]
  self_link  = google_compute_instance_group_manager.linux_bastion_group.instance_group
}

// Gets the windows bastion instance group from the windows bastion instance group manager
data "google_compute_instance_group" "windows_bastion_instance_group" {
  depends_on = [time_sleep.windows_wait_30_seconds]
  self_link  = google_compute_instance_group_manager.windows_bastion_group.instance_group
}

// Gets the squid proxy instance group from the squid proxy instance group manager
data "google_compute_instance_group" "squid_proxy_instance_group" {
  depends_on = [time_sleep.squid_wait_30_seconds]
  self_link  = google_compute_instance_group_manager.squid_proxy_group.instance_group
}