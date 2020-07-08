provider "google" {
 version     = "~> 3.24"
 region      = var.gcp_region
 project     = "${var.gcp_project_id}-${var.tb_discriminator}"
}

provider "google-beta" {
 version     = "~> 3.24"
 region      = var.gcp_region
 project     = "${var.gcp_project_id}-${var.tb_discriminator}"
}