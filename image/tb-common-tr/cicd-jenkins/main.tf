//Terraform script to provision GCP resources
//Variables defined in variables.tf

//Terraform Provider config
provider "google" {
  version = "~> 1.17"
  credentials = "${file("creds/key.json")}"
  project = "${var.project_id}"
  region = "${var.region}"
}

//GKE Cluster config
resource "google_container_cluster" "gke_cluster" {
  name = "${var.cluster_name}"
  zone = "${var.zone}"
  remove_default_node_pool = true
  //initial_node_count = 2

   node_pool {
    name = "default-pool"
  }

  master_auth {
    username = "${var.username}"
    password = "${var.password}"
  }
}

//Cluster node pool config
resource "google_container_node_pool" "gke_node_pool" {
  name = "cd-pool"
  zone = "${var.zone}"
  cluster = "${google_container_cluster.gke_cluster.name}"
  initial_node_count = 2
  autoscaling {
    min_node_count = 2
    max_node_count = 6
  }
  node_config {
    machine_type = "${var.cluster_machine_type}"
    oauth_scopes = [
      "storage-ro",
      "storage-rw",
      "compute-rw",
      "cloud-platform",
      "monitoring",
      "logging-write",
      "https://www.googleapis.com/auth/projecthosting"
    ]
  }
}

//Bastion host on GCE - Startup script inline.
resource "google_compute_instance" "default" {
  name = "${var.bastion_name}"
  machine_type = "${var.bastion_machine_type}"
  zone = "${var.zone}"


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // REQUIRED TO ALLOW SSH
      // REQUIRED FOR VM TO RUN STARTUP_SCRIPT.
    }
  }
  
    service_account {
    email = "${var.cluster_name}@${var.project_id}.iam.gserviceaccount.com"
    scopes = [
      "userinfo-email",
      "compute-ro",
      "storage-ro",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/projecthosting"]
  }
  
  
  //Update and pull from repository to install Jenkins
  metadata_startup_script = <<SCRIPT
    #update debian and install kubectl
    sudo apt-get install -y sudo git google-cloud-sdk curl kubectl

    #Pull source
    gcloud source repos clone ${var.source_repository} --project=${var.project_id}

    sudo chmod 777 ./${var.source_repository}

    cd ${var.source_repository}/sh/
    
    #run installation script
    sudo bash ./install-jenkins-itop.sh

	SCRIPT
    



  depends_on = [
    "google_container_node_pool.gke_node_pool"]

    
}
