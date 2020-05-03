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
  folder     = "folders/${var.root_id}"
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
    "serviceAccount:${var.shared_bastion_project_number}@cloudservices.gserviceaccount.com"
  ]
}

resource "google_compute_firewall" "shared-net-bast" {
  depends_on = [google_service_account.bastion_service_account]
  name    = "allow-iap-ingress-ssh-rdp"
  network = var.shared_vpc_name
  project = var.shared_networking_id
  target_service_accounts = [
    google_service_account.bastion_service_account.email, google_service_account.proxy-sa-res.email]
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
  source_service_accounts = [
    google_service_account.bastion_service_account.email, google_service_account.proxy-sa-res.email]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "remote-mgmt-iap" {
  name        = "remote-mgmt-iap-test"
  network     = var.shared_vpc_name
  project = var.shared_networking_id
  description = "Allow inbound connections from iap"
  direction   = "INGRESS"
  source_service_accounts = [google_service_account.proxy-sa-res.email]
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
}

data "google_compute_image" "debian_image" {
  family  = "debian-9"
  project = "debian-cloud"
}



// Create instance template for the linux instance
resource "google_compute_instance_template" "bastion_linux_template" {
  project = var.shared_bastion_id
  name        = "tb-bastion-linux-template"
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

// Create instance group for the linux bastion
resource "google_compute_instance_group_manager" "linux_bastion_group" {
  project = var.shared_bastion_id
  base_instance_name = "tb-linux-bastion"
  zone               = var.region_zone

  version {
    instance_template  = google_compute_instance_template.bastion_linux_template.self_link
    name = "tb-bastion-linux-template"
  }

  target_size  = 1
  name = "tb-linux-bastion-group"

  depends_on = [google_compute_subnetwork_iam_binding.bastion_subnet_permission]
}

// Windows MIG
data "google_compute_image" "windows_image" {
  family  = "windows-2019"
  project = "gce-uefi-images"
}

// Create instance template for the windows instance
resource "google_compute_instance_template" "bastion_windows_template" {
  project = var.shared_bastion_id
  name        = "tb-bastion-windows-template"
  description = "This template is used to create windows bastion instance"

  instance_description = "Bastion windows instance"
  machine_type         = "n1-standard-2"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // boot disk
  disk {
    source_image = data.google_compute_image.windows_image.self_link
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

// Create instance group for the windows bastion
resource "google_compute_instance_group_manager" "windows_bastion_group" {
  project = var.shared_bastion_id
  base_instance_name = "tb-windows-bastion"
  zone               = var.region_zone

  version {
    instance_template  = google_compute_instance_template.bastion_windows_template.self_link
    name = "bastion-linux-template"
  }

  target_size  = 1
  name = "tb-windows-bastion-group"

  depends_on = [google_compute_subnetwork_iam_binding.bastion_subnet_permission]
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
      //image = "debian-9-stretch-v20191210"
      image = "rhel-7"
    }
  }
  //metadata_startup_script = var.metadata_startup_script
  metadata_startup_script = file("${path.module}/squid_new.sh")
  network_interface {
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/bastion-subnetwork"
  }
  service_account {
    email = google_service_account.proxy-sa-res.email
    scopes = var.scopes
  }
}

//resource "google_compute_instance" "tb_kube_proxy-dev" {
//  depends_on = [
//    google_service_account.bastion_service_account]
//  project = var.shared_bastion_id
//  zone = var.region_zone
//  name = "tb-kube-proxy-dev"
//  machine_type = "n1-standard-2"
//  boot_disk {
//    initialize_params {
//      image = "debian-9-stretch-v20191210"
//      #image = "rhel-8"
//    }
//  }
//  //metadata_startup_script = var.metadata_startup_script
//  #metadata_startup_script = file("${path.module}/privoxy_startup.sh")
//  network_interface {
//    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/bastion-subnetwork"
//  }
//  service_account {
//    email = google_service_account.proxy-sa-res.email
//    scopes = var.scopes
//  }
//}


resource "null_resource" "start-iap-tunnel" {

  provisioner "local-exec" {
    command = <<EOF
echo 'gcloud compute start-iap-tunnel tb-kube-proxy 3128 --local-host-port localhost:3128 --project ${var.shared_bastion_id} --zone ${var.region_zone} > /dev/null 2>&1 &
TUNNELPID=$!
sleep 10
export HTTPS_PROXY="localhost:3128"' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/iap-tunnel.sh
EOF
  }
  #${local.proxy_command}="gcloud compute instances list"
  depends_on = [google_compute_instance.tb_kube_proxy]
}