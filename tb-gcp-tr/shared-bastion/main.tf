# Bastion Infrastructure
# Create bastion service account
resource "google_service_account" "bastion_service_account" {
  account_id   = "bastion-service-account"
  display_name = "bastion-service-account"
  project = var.shared_bastion_id
}
#CREATE-SERVICE-ACCOUNT
resource "google_service_account" "proxy-sa-res" {
  account_id   = "proxy-sa"
  display_name = "proxy-sa"
  project      = var.shared_bastion_id
}
locals {
  service_account_name = "serviceAccount:${google_service_account.proxy-sa-res.account_id}@${var.shared_bastion_id}.iam.gserviceaccount.com"
}
resource "google_folder_iam_member" "sa-folder-admin-role" {
  count      = length(var.main_iam_service_account_roles)
  folder     = "folders/${var.folder_id}"
  role       = element(var.main_iam_service_account_roles, count.index)
  member     = local.service_account_name
  depends_on = [google_service_account.proxy-sa-res]
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

resource "google_compute_instance" "tb_linux_bastion" {
  depends_on = [
    google_service_account.bastion_service_account]
  project = var.shared_bastion_id
  zone = var.region_zone
  name = "tb-linux-bastion"
  machine_type = "n1-standard-2"
  boot_disk {
    initialize_params {
      image = "debian-9-stretch-v20191210"
    }
  }
  network_interface {
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/bastion-subnetwork"
  }
  service_account {
    email = google_service_account.bastion_service_account.email
    scopes = []
  }
}

resource "google_compute_instance" "tb_kube_proxy" {
  depends_on = [
    google_service_account.bastion_service_account]
  project = var.shared_bastion_id
  zone = var.region_zone
  name = "tb-kube-proxy"
  machine_type = "n1-standard-2"
  boot_disk {
    initialize_params {
      image = "debian-9-stretch-v20191210"
    }
  }
  //metadata_startup_script = var.metadata_startup_script
  metadata_startup_script = file("${path.module}/startup_script.sh")
  network_interface {
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/bastion-subnetwork"
  }
  service_account {
    email = google_service_account.proxy-sa-res.email
    scopes = []
  }
}