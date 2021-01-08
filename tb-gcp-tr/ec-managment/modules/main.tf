resource "random_id" "prefix" {
  byte_length = 8
}

locals {
  prefix                  = random_id.prefix.dec
  root_folder_name        = format("%s-%s", "TranquilityBase", local.prefix)
  management_project_name = format("%s-%s", "management", local.prefix)
  network_name            = format("%s-%s", "vpc", local.prefix)
  subnet_name             = format("%s-%s", "subnet", local.prefix)
  router_name             = format("%s-%s", "router", local.prefix)
  sa_name                 = format("%s-%s", "sa", local.prefix)
  project_roles           = [for role in var.project_roles : format("%s=>%s", module.project.project_id, role)]
}



