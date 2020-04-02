# Bastion Infrastructure
# Create bastion service account
resource "google_service_account" "bastion_service_account" {
  account_id   = "bastion-service-account"
  display_name = "bastion-service-account"
  project = var.shared_bastion_id
}
# Adding bastion project as service project to host vpc
resource "google_compute_shared_vpc_service_project" "attach_bastion_project" {
  host_project    = var.shared_networking_id
  service_project = var.shared_bastion_id
}

resource "google_compute_subnetwork_iam_binding" "bastion_subnet_permission" {
  subnetwork = "bastion-subnetwork"
  role       = "roles/compute.networkUser"
  project = var.shared_networking_id

  members = [
    "serviceAccount:${google_service_account.bastion_service_account.email}",
    "serviceAccount:${var.shared_bastion_project_number}@cloudservices.gserviceaccount.com"
  ]
}

resource "google_compute_firewall" "shared-net-bast" {
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

resource "google_compute_firewall" "bast-nat-http" {
  depends_on = [google_service_account.bastion_service_account]
  name    = "bastion-http-https-allow"
  network = var.shared_vpc_name
  project = var.shared_networking_id
  source_ranges = [var.nat_static_ip]
  source_service_accounts = ["${google_service_account.bastion_service_account.email}"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Create compute instance and attach service account
resource "google_compute_instance" "tb_windows_bastion" {
  depends_on = [
    google_service_account.bastion_service_account]
  project = var.shared_bastion_id
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
  }
  service_account {
    email = google_service_account.bastion_service_account.email
    scopes = []
  }
  metadata = {
    windows-startup-script-ps1 = "$LocalTempDir = $env:TEMP; $ChromeInstaller = \"ChromeInstaller.exe\"; (new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', \"$LocalTempDir\\$ChromeInstaller\"); & \"$LocalTempDir\\$ChromeInstaller\" /silent /install;"
  }
}

//resource "google_compute_instance" "tb_linux_bastion" {
//  depends_on = [
//    google_service_account.bastion_service_account]
//  project = var.shared_bastion_id
//  zone = var.region_zone
//  name = "tb-linux-bastion"
//  machine_type = "n1-standard-2"
//  boot_disk {
//    initialize_params {
//      image = "debian-9-stretch-v20191210"
//    }
//  }
//  network_interface {
//    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/bastion-subnetwork"
//  }
//  service_account {
//    email = google_service_account.bastion_service_account.email
//    scopes = []
//  }
//}

data "google_compute_image" "debian_image" {
  family  = "debian-9"
  project = var.shared_bastion_id
}

// Create instance template
resource "google_compute_instance_template" "bastion_linux_template" {
  project = var.shared_bastion_id
  name        = "bastion-linux-template"
  description = "This template is used to create linux bastion instance"

  instance_description = "Bastion linux instance"
  machine_type         = "n1-standard-2"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // boot disk
  disk {
    source_image = data.google_compute_image.debian_image.self_link
  }

  network_interface {
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/bastion-subnetwork"
  }

  service_account {
    email = google_service_account.bastion_service_account.email
    scopes = []
  }
}

// Create instance group

resource "google_compute_instance_group_manager" "linux_bastion_group" {
  project = var.shared_bastion_id
  base_instance_name = "linux-bastion"
  zone               = var.region_zone

  version {
    instance_template  = google_compute_instance_template.bastion_linux_template.self_link
    name = "bastion-linux-template"
  }

  target_size  = 1
  instance_template = google_compute_instance_template.bastion_linux_template.self_link
  name = "linux-bastion-group"

  depends_on = [google_compute_subnetwork_iam_binding.bastion_subnet_permission]
}