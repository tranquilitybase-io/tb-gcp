terraform {
  source = "github.com/tranquilitybase-io/tb-gcp-bootstrap"
}

remote_state {
  backend = "gcs"
  config = {
    bucket   = env.TG_STATE_BUCKET_NAME
    prefix   = "bootstrap/${path_relative_to_include()}/terraform.tfstate"
    project  = env.TG_PROJECT_ID
    location = env.TG_REGION
  }
}