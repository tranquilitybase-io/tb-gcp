# Bastion Infrastructure
# Create bastion service account
resource "google_service_account" "bastion_service_account" {
  account_id   = "bastion-service-account"
  display_name = "bastion-service-account"
  project      = var.shared_bastion_id
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
  subnetwork = var.bastion_subnetwork_name
  role       = "roles/compute.networkUser"
  project    = var.shared_networking_id

  members = [
    "serviceAccount:${google_service_account.bastion_service_account.email}",
    "serviceAccount:${var.shared_bastion_project_number}@cloudservices.gserviceaccount.com"
  ]
}

resource "google_compute_firewall" "allow_bastion_ingress" {
  name    = "allow-bastion-ingress"
  network = var.shared_vpc_name
  project = var.shared_networking_id

  allow {
    protocol = "tcp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  source_service_accounts = [
    google_service_account.bastion_service_account.email
  ]
}

resource "google_compute_firewall" "allow_proxy_http_ingress" {
  name    = "allow-proxy-http-ingress"
  network = var.shared_vpc_name
  project = var.shared_networking_id

  allow {
    protocol = "tcp"
    ports    = [80, 443, 8008, 8080, 8443]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  source_service_accounts = [
    google_service_account.proxy-sa-res.email
  ]
}

data "google_compute_image" "debian_image" {
  family  = "debian-9"
  project = "debian-cloud"
}

data "google_compute_image" "centos_image" {
  family  = "centos-7"
  project = "centos-cloud"
}

// Create instance template for the linux instance
resource "google_compute_instance_template" "bastion_linux_template" {
  project     = var.shared_bastion_id
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
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/${var.bastion_subnetwork_name}"
  }

  service_account {
    email  = google_service_account.bastion_service_account.email
    scopes = []
  }

  // make sure the project is attached and can see the shared VPC network before referencing one of it's subnetworks
  depends_on = [google_compute_shared_vpc_service_project.attach_bastion_project]
}

// Create instance group for the linux bastion
resource "google_compute_instance_group_manager" "linux_bastion_group" {
  project            = var.shared_bastion_id
  base_instance_name = "tb-linux-bastion"
  zone               = var.region_zone

  version {
    instance_template = google_compute_instance_template.bastion_linux_template.self_link
    name              = "tb-bastion-linux-template"
  }

  target_size = 1
  name        = "tb-linux-bastion-group"

  depends_on = [google_compute_subnetwork_iam_binding.bastion_subnet_permission]
}

// Windows MIG
data "google_compute_image" "windows_image" {
  family  = "windows-2019"
  project = "gce-uefi-images"
}

// Create instance template for the windows instance
resource "google_compute_instance_template" "bastion_windows_template" {
  project     = var.shared_bastion_id
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
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/${var.bastion_subnetwork_name}"
  }

  service_account {
    email  = google_service_account.bastion_service_account.email
    scopes = []
  }

  metadata = {
    windows-startup-script-ps1 = "$LocalTempDir = $env:TEMP; $ChromeInstaller = \"ChromeInstaller.exe\"; (new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', \"$LocalTempDir\\$ChromeInstaller\"); & \"$LocalTempDir\\$ChromeInstaller\" /silent /install;"
  }

  // make sure the project is attached and can see the shared VPC network before referencing one of it's subnetworks
  depends_on = [google_compute_shared_vpc_service_project.attach_bastion_project]
}

// Create instance group for the windows bastion
resource "google_compute_instance_group_manager" "windows_bastion_group" {
  project            = var.shared_bastion_id
  base_instance_name = "tb-windows-bastion"
  zone               = var.region_zone

  version {
    instance_template = google_compute_instance_template.bastion_windows_template.self_link
    name              = "bastion-linux-template"
  }

  target_size = 1
  name        = "tb-windows-bastion-group"

  depends_on = [google_compute_subnetwork_iam_binding.bastion_subnet_permission]
}

//Create instance template for the Squid Proxy instance
resource "google_compute_instance_template" "squid_proxy_template" {
  project = var.shared_bastion_id
  name    = "tb-kube-proxy-template"

  machine_type = "n1-standard-2"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // boot disk
  disk {
    source_image = data.google_compute_image.centos_image.self_link
  }

  network_interface {
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/${var.bastion_subnetwork_name}"
  }

  service_account {
    email  = google_service_account.proxy-sa-res.email
    scopes = var.scopes
  }

  metadata_startup_script = file("${path.module}/squid_startup.sh")

  // make sure the project is attached and can see the shared VPC network before referencing one of it's subnetworks
  depends_on = [google_compute_shared_vpc_service_project.attach_bastion_project]
}

// Create instance group for the squid proxy
resource "google_compute_instance_group_manager" "squid_proxy_group" {
  project            = var.shared_bastion_id
  base_instance_name = "tb-kube-proxy"
  zone               = var.region_zone

  version {
    instance_template = google_compute_instance_template.squid_proxy_template.self_link
    name              = "tb-kube-proxy-template"
  }

  target_size = 1
  name        = "tb-squid-proxy-group"

  depends_on = [google_compute_subnetwork_iam_binding.bastion_subnet_permission, google_service_account.bastion_service_account]
}

resource "time_sleep" "linux_wait_30_seconds" {
  depends_on = [google_compute_instance_group_manager.linux_bastion_group]

  create_duration = "80s"
}

resource "time_sleep" "windows_wait_30_seconds" {
  depends_on = [google_compute_instance_group_manager.windows_bastion_group]

  create_duration = "80s"
}

resource "time_sleep" "squid_wait_30_seconds" {
  depends_on = [google_compute_instance_group_manager.squid_proxy_group]

  create_duration = "80s"
}

resource "null_resource" "start-iap-tunnel" {

  provisioner "local-exec" {
    command = <<EOF
echo '
INSTANCE=$(gcloud compute instance-groups managed list-instances tb-squid-proxy-group --project=${var.shared_bastion_id} --zone ${var.region_zone} --format="value(instance.scope(instances))")
gcloud compute start-iap-tunnel $INSTANCE 3128 --local-host-port localhost:3128 --project ${var.shared_bastion_id} --zone ${var.region_zone} > /dev/null 2>&1 &
TUNNELPID=$!
sleep 10
export HTTPS_PROXY="localhost:3128"' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/iap-tunnel.sh
EOF
  }
  depends_on = [google_compute_instance_group_manager.squid_proxy_group]
}