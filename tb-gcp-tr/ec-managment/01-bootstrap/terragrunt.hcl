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
    bucket   = get_env("TG_STATE_BUCKET", "NULL")
    prefix   = "bootstrap/${path_relative_to_include()}/terraform.tfstate"
    project  = get_env("TG_PROJECT", "NULL")
    location = get_env("TG_REGION", "NULL")
  }
}
