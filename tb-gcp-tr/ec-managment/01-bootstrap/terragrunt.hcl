terraform {
  source = "github.com/tranquilitybase-io/tb-gcp-bootstrap"

    # With the get_terragrunt_dir() function, you can use relative paths!
    arguments = [
      "-var-file=${get_terragrunt_dir()}/../local.auto.tfvars"
    ]
}

remote_state {
  backend = "gcs"
  config = {
    bucket   = var.TG_STATE_BUCKET_NAME
    prefix   = "bootstrap/${path_relative_to_include()}/terraform.tfstate"
    project  = var.TG_PROJECT_ID
    location = var.TG_REGION
  }
}
