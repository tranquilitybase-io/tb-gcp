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

  metadata_startup_script = <<SCRIPT
                              #!/bin/bash -x
                              #
                              # Startup script to install Chrome remote desktop and a desktop environment.
                              #
                              # See environmental variables at then end of the script for configuration
                              #

                              function install_desktop_env {
                                PACKAGES="desktop-base xscreensaver"

                                if [[ "$INSTALL_XFCE" != "yes" && "$INSTALL_CINNAMON" != "yes" ]] ; then
                                  # neither XFCE nor cinnamon specified; install both
                                  INSTALL_XFCE=yes
                                  INSTALL_CINNAMON=yes
                                fi

                                if [[ "$INSTALL_XFCE" = "yes" ]] ; then
                                  PACKAGES="$PACKAGES xfce4"
                                  echo "exec xfce4-session" > /etc/chrome-remote-desktop-session
                                  [[ "$INSTALL_FULL_DESKTOP" = "yes" ]] && \
                                    PACKAGES="$PACKAGES task-xfce-desktop"
                                fi

                                if [[ "$INSTALL_CINNAMON" = "yes" ]] ; then
                                  PACKAGES="$PACKAGES cinnamon-core"
                                  echo "exec cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session
                                  [[ "$INSTALL_FULL_DESKTOP" = "yes" ]] && \
                                    PACKAGES="$PACKAGES task-cinnamon-desktop"
                                fi

                                DEBIAN_FRONTEND=noninteractive \
                                  apt-get install --assume-yes $PACKAGES $EXTRA_PACKAGES

                                systemctl disable lightdm.service
                              }

                              function download_and_install { # args URL FILENAME
                                curl -L -o "$2" "$1"
                                dpkg --install "$2"
                                apt-get install --assume-yes --fix-broken
                              }

                              function is_installed {  # args PACKAGE_NAME
                                dpkg-query --list "$1" | grep -q "^ii" 2>/dev/null
                                return $?
                              }

                              # Configure the following environmental variables as required:
                              INSTALL_XFCE=yes
                              INSTALL_CINNAMON=no
                              INSTALL_CHROME=no
                              INSTALL_FULL_DESKTOP=no

                              # Any additional packages that should be installed on startup can be added here
                              EXTRA_PACKAGES="less bzip2 zip unzip"

                              apt-get update

                              ! is_installed chrome-remote-desktop && \
                                download_and_install \
                                  https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
                                  /tmp/chrome-remote-desktop_current_amd64.deb

                              install_desktop_env

                              [[ "$INSTALL_CHROME" = "yes" ]] && \
                                ! is_installed google-chrome-stable && \
                                download_and_install \
                                  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
                                  /tmp/google-chrome-stable_current_amd64.deb

                              echo "Chrome remote desktop installation completed"
                              SCRIPT

  network_interface {
    subnetwork = "projects/${var.shared_networking_id}/regions/${var.region}/subnetworks/bastion-subnetwork"
  }
  service_account {
    email = google_service_account.bastion_service_account.email
    scopes = []
  }
}