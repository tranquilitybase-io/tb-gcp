module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  network_name = local.network_name
  project_id   = module.project.project_id
  subnets = [
    {
      subnet_name = local.subnet_name
      subnet_ip   = "192.168.0.0/28"
      region      = var.region
    }
  ]
}

module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"

  name    = local.router_name
  project = module.project.id
  region  = var.region
  network = module.vpc.network_self_link
}

module "cloud-nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 1.2"

  project_id = module.project.id
  region     = var.region
  router     = module.cloud_router.router
}
