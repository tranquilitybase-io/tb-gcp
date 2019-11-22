# Tranquility Base Landing Zone Infrastructure as Code

## Prerequisites

* [terraform](https://www.terraform.io/) version `0.11.13` installed on your machine and available on your command line.

## Building Tranquility Base bootstrap infrastructure

1. Login with command: `gcloud auth application-default login`
2. Ensure that `input.tfvars` contain desired values
3. Run `terraform init`
4. Run `terrafrom apply -var-file=./input.tfvars -auto-approve`

Once the terrafrom script ends it indicates only that the bootstrap infrastructure is completed and 
the build of Landing Zone has just been initiated (started) on the `terraform-server` host in the `bootstrap` project.
It does not mean that the whole TB Landing Zone is ready for use.

## Tranquility Base Landing Zone verification
In order to ensure that whole TB Landing Zone has been built and is ready for use please follow the following steps:
1. Go to newly created "_bootstrap-dev_" project in your GCP console.
2. Select _Compute Engine_->_VM instances_->terraform-server->_Stackdriver Logging_
3. Click on _Start streaming logs_ arrow button on the top
4. In the logs you should see the following entries:
````
Aug  9 11:54:20 terraform-server startup-script: INFO startup-script: Return code 0.
Aug  9 11:54:20 terraform-server startup-script: INFO Finished running startup scripts.
````
indicating that the Landing Zone has been built successfully. 

## Possible options

### TB Discriminator

Helps to build couple of Tranquility Base instances within the same folder and organisation. 
It is really useful especially if more TBase developers are working simultaneously on _Tranquility Base IaaC_ scripts 
and they are using the same organisation/folder in GCP.

Variable `tb_discriminator` is used to add suffix to the names/IDs such elements like _Tranquility Base_ folder, 
_Bootstrap_ project what allows their coexistence with other sibling TBase instances within the same Organisation/Folder. 
Example: 'uat', 'dev-am', ''. For the empty value no suffix will be added (thus production ready).

##### Example 1: 
Default value in `input.tfvars` is `tb_discriminator = "dev"` so the following elements will be created:
* "_bootstrap-dev_" project
* "_Tranquility Base - dev_" folder

##### Example 2: 
If you would like to build your _Tranquility Base_ instance with a custom suffix (eg. "_Demo_") but without changing `input.tfvars` file, 
you can add such command line parameter:

`terrafrom apply -var-file=./input.tfvars -var "tb_discriminator=Demo" -auto-approve`

As a result the following elements will be created:
* "_bootstrap-demo_" project
* "_Tranquility Base - Demo_" folder

##### Example 3: 
For production if you wish to not use any suffix for the _Tranquility Base_ instance then 
either set `tb_discriminator` variable to empty string "" in `input.tfvars` file 
or you can set it explicitly in command line parameter:

`terrafrom apply -var-file=./input.tfvars -var "tb_discriminator=" -auto-approve`

As a result the following elements will be created:
* "_bootstrap_" project
* "_Tranquility Base_" folder


### LZ Branch

The `lz_branch` variable specifies branch name (by default it is "`master`") that will be used by Bootstrap `terraform-server` host during github cloning operation of the [TB repo](https://github.com/tranquilitybase-io/tb-gcp-tr) in order to build Landing Zone infrastructure.
For a demo purpose or if you are developing a new feature of the _Tranquility Base IaaC_ you are usually working on a specific branch rather than on master branch then
you have to instruct the Bootstrap `terraform-server` host about your specific branch via setting the following variable:

`terrafrom apply -var-file=./input.tfvars -var "lz_branch=<YOUR_BRANCH_NAME>" -auto-approve`




 







