# Building GCE VM image for terraform-server with Tranquility Base Landing Zone Terraform scripts

This [Packer](https://www.packer.io) script builds a Google Compute Engine (GCE) VM image for `terraform-server` in 
Tranquility Base. The image contains all elements like [Terraform](https://www.terraform.io/) scripts or libraries 
needed to build [Tranquility Base](https://www.tranquilitybase.io) Landing Zone on the Google Cloud Platform (GCP).

## Prerequisites

* [Packer](https://www.packer.io) version `1.4.3` or later installed on your machine and available on your command line.
* The [tranquilitybase-io](https://github.com/tranquilitybase-io/tb-gcp) git repository should be copied to a local folder
  (called TB Repos Root folder) who's path can be later used to set the `tb_repos_root_path` variable for the build command.

## Template Validation 

To just validate your template, please run the following command:

`packer validate packer.json`

## Build

To build the LZ Image based on your local copy of [tranquilitybase-io](https://github.com/tranquilitybase-io/tb-gcp), 
run the following command:

`packer build packer.json`

### Build arguments

* `tb_repos_root_path` - absolute or relative path to your TB Repos Root local folder. 
  The default value is a relative path assuming that all [tranquilitybase-io](https://github.com/tranquilitybase-io/tb-gcp) 
  repositories (including this TB Delivery packer repo) are located in sibling sub folders of the same root folder.
 
  Example invocation can look like: 
  
  `packer build -var 'tb_repos_root_path=/your/path/to/tb/repos' packer.json`

* `image_suffix` - suffix added to the image name to distinguish images during development. It is empty by default.
  A generated images receive such names `tb-tr-debian-9<image_suffix>-<isotime>`. 
   
  Example invocation can look like: 
  
  `packer build -var 'image_suffix=-beta' packer.json`
  
  so the generated image will have `tb-tr-debian-9-beta-2019-09-10t15-46-51z` name

* `image_family` - the image family for your image. The default value is `tb-tr-debian-9`. During development, 
  it i highly recommended to use your own name for the image family since the latest build from particular family is 
  taken when you are building GCE VMs with specified image family name.
   
  Example invocation can look like: 
  
  `packer build -var 'image_family=tb-tr-debian-9-xyz' packer.json`
  
  so the generated image will have the `tb-tr-debian-9-xyz` family name.

* `project_id` - your project in GCP where the target image will be built and available. 
   
  Example invocation can look like: 
  
  `packer build -var 'project_id=your-project-id' packer.json`
  
You can use many variables during one build as bellow:

on Windows:

`packer build -var "image_family=tb-tr-debian-9-xyz" -var "image_suffix=xyz5" -var "project_id=xyz-image-project-id" packer.json`
 
on Linux:

`packer build -var 'image_family=tb-tr-debian-9-xyz' -var 'image_suffix=xyz5' -var 'project_id=xyz-image-project-id' packer.json`

that will build the `tb-tr-debian-9-xyz5-2019-09-12t10-26-35z` image in the `tb-tr-debian-9-xyz` family in `xyz-image-project-id` project. 
