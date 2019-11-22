provider "kubernetes" {
  version = "~> 1.6"
  config_path = "${var.kubernetes_config_path}"
}

provider "null" {
  version = "~> 2.1"
}

provider "helm" {
  version = "~> 0.9"
  install_tiller = true
  kubernetes {
    config_path = "${var.kubernetes_config_path}"
  }
}

