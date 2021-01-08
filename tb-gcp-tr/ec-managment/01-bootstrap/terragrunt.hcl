terraform {
  source = "github.com/tranquilitybase-io/tb-gcp-bootstrap"

    # With the get_terragrunt_dir() function, you can use relative paths!
    arguments = [
      "-var-file=${get_terragrunt_dir()}/../local.auto.tfvars"
    ]
}
