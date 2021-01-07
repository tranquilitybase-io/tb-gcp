resource "random_id" "prefix" {
  byte_length = 8
}

locals {
  prefix                  = random_id.prefix.dec
  root_folder_name        = format("TranquilityBase-", local.prefix)
  management_project_name = format("management-", local.prefix)
  network_name            = format("vpc-", local.prefix)
  subnet_name             = format("subnet-", local.prefix)
  router_name             = format("router-", local.prefix)
  sa_name                 = format("sa-", local.prefix)
  project_roles           = [for role in var.project_roles : format("%s=>%s", module.project.project_id, role)]
}



