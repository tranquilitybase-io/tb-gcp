#Setting up the 0auth consent screen, which terraforms refer to as google_iap_brand
provider "google-beta" {
  credentials = var.gcp_credentials
  project     = var.project
  region      = var.region
}

data "google_client_config" "current" {
  provider = google-beta
}

resource "google_iap_brand" "iap_brand" {
  provider          = google-beta

  support_email     = data.google_client_openid_userinfo.current_identity.email
  application_title = "EC OAuth Tooling"
}


provider "google" {
  client_id 		= "${var.client_id}"
  client_secret 	= "${var.client_secret}"
}
# setup access for my users, for which I will use the google_iap_web_iam_member. in this I define the project which is mandatory and Im directly giving access to company domain using domain: prefix
resource "google_iap_web_iam_member" "access_iap_policy" {
  provider  = google-beta
  project   = var.project
  role      = "roles/iap.httpsResourceAccessor"
  member    = "domain:eagle-console.tranquilitybase-demo.io"
}

#setting up the 0AUTH app which terraform refer to as google_iap_client
resource "google_iap_client" "iap_ec_client" {
  provider      = google-beta
  display_name  = "EC Auth"
  brand         =  google_iap_brand.iap_brand.name
}

 
resource "kubernetes_secret" "iap_ec_client_k8s_secret" {
  metadata {
    name      = "ec-iap-secrets"
    namespace = "ssp"
  }
 

resource "null_resource" "kubernetes_auth_secret_ssp" {
  triggers = {
    content = var.content
    k8_name = var.context_name
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${var.context_name} create secret generic ec-iap-secrets -n ssp --from-literal=client_secret='${var.client_secret}' --from-literal=client_id='${var.client_id}' --type=kubernetes.io/basic-auth' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh"
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${self.triggers.k8_name} delete secret ec-iap-secrets' -n ssp | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh"
    when    = destroy
  }
}

# configure a BackendConfig CRD and tell Service to use it