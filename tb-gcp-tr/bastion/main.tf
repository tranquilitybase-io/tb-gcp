# Bastion Infrastructure
# Create bastion service account
resource "google_service_account" "bastion_service_account" {
  account_id   = "bastion-service-account"
  display_name = "bastion-service-account"
  project = var.tb_bastion_id
}
# Adding bastion project as service project to host vpc
resource "google_compute_shared_vpc_service_project" "attach_bastion_project" {
  host_project    = var.shared_networking_id
  service_project = var.tb_bastion_id
}

resource "google_compute_subnetwork_iam_binding" "bastion_subnet_permission" {
  subnetwork = "bastion-subnetwork"
  role       = "roles/compute.networkUser"
  project = var.shared_networking_id

  members = [
    "serviceAccount:${google_service_account.bastion_service_account.email}",
  ]
}

# Firewall rule to allow ingress traffic on port 22 and 80
resource "google_compute_firewall" "shared-network" {
  depends_on = [google_service_account.bastion_service_account]
  name    = "http-https-ssh-allow"
  network = var.shared_vpc_name
  project = var.shared_networking_id
  source_service_accounts = ["${google_service_account.bastion_service_account.email}"]
  allow {
    protocol = "tcp"
    ports    = ["80", "22", "443"]
  }
}

resource "google_compute_firewall" "shared-network" {
  depends_on = [google_service_account.bastion_service_account]
  name    = "allow-iap-ingress-ssh-rdp"
  network = var.shared_vpc_name
  project = var.shared_networking_id
  target_service_accounts = ["${google_service_account.bastion_service_account.email}"]
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["3389", "22"]
  }
}

# Create compute instance and attach service account
resource "google_compute_instance" "tb_windows_bastion" {
  depends_on = [
    google_service_account.bastion_service_account]
  project = var.tb_bastion_id
  zone = var.region_zone
  name = "tb-windows-bastion"
  machine_type = "n1-standard-2"
  boot_disk {
    initialize_params {
      image = "windows-server-2019-dc-v20191008"
    }
  }
  network_interface {
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/bastion-subnetwork"
    access_config {
    }
  }
  service_account {
    email = google_service_account.bastion_service_account.email
    scopes = []
  }
}