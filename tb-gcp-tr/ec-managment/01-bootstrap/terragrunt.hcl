terraform {
  source = "github.com/tranquilitybase-io/tb-gcp-bootstrap"
}

remote_state {
  backend = "gcs"
  config = {
    bucket   = get_env("TG_STATE_BUCKET_NAME", "NULL")
    prefix   = "bootstrap/${path_relative_to_include()}/terraform.tfstate"
    project  = get_env("TG_PROJECT_ID", "NULL")
    location = get_env("TG_REGION", "NULL")

    enable_bucket_policy_only = true
    gcs_bucket_labels = {
      activator_type = "tbbootstrap"
      environment    = "development"
      terraform      = "true"
    }
  }
}