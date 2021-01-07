module "folders" {
  source  = "terraform-google-modules/folders/google"
  version = "2.0.2"

  parent = var.parent_id
  names  = [local.root_folder_name]
}

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name            = local.management_project_name
  folder_id       = module.folders.id
  billing_account = var.billing_id
  org_id          = var.org_id
}
