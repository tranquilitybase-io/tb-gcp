# Landing Zone optional features

The folder `tb-gcp/tb-gcp-tr/options` will contain the modules that are not deployed by default in the Landing Zone. Therefore, they will be
optional deployments.

Each option will be associated to a new Terraform state.

## Folder structure & Terraform states
Initially, only the Vault installation will be optional. The below depicts the folder structure and the Terraform folder that will
hold the state of this infrastructure. These states will be stored in the same GCS bucket that the `landingZone` state, using a specific backend prefix: 
- options
  - secrets: At this level there is code that deploys the secrets Kubernetes cluster only. Its state is stored with prefix `/secrets`
    - vault: Installation of Vault is stored at this level. Necessarily, Terraform must have been applied at the parent folder in order
           to create the cluster. State is stored with prefix `/secrets/vault`
    - _option2_: Eventually, there may be an option2 of secrets software   `/secrets/_option2_`
    - _option3_: Eventually, there may be another options of secrets software  `/secrets/_option3_`

In the near future, Itop and/or other ITSM software options will be made available: 
  - itsm:           `/itsm`
    - itop          `/itsm/itop`
    - _option2_     `/itsm/_option2_` (eventually)
    - _option3_     `/itsm/_option3_` (eventually)
    
## How to run
To generate the secrets cluster, _terraform init_ and subequently _apply_, must run at the `tb-gcp/tb-gcp-tr/options/secrets`folder:

```
terraform init -backend-config="bucket=tf-export-_XXXXXXXX_" -backend-config="prefix=options/secrets"
terraform apply -var-file input.tfvars -var-file ../options.tfvars -auto-approve
```

To deploy the Vault software, _terraform init_ and subequently _apply_, must run at the `tb-gcp/tb-gcp-tr/options/secrets/vault`folder:
```
terraform init -backend-config="bucket=tf-export-_XXXXXXXX_" -backend-config="prefix=options/secrets/vault"
terraform apply -var-file input.tfvars -var-file ../../options.tfvars -auto-approve
``` 
