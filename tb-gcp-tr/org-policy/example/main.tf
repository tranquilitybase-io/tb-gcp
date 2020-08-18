module "example_folder" {
  source = "../"

  org_id     = var.org_id
  folder_id  = var.folder_id
  project_id = var.project_id
}
