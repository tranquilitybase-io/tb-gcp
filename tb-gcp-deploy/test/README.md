# Building Test GCE instance using VM image containing Tranquility Base Landing Zone Terraform scripts

This Terraform script is written just for testing purpose. It creates minimal infrastructure 
(test GCE instance and test service account) based on given VM image containing Tranquility Base Landing Zone Terraform 
scripts just to verify its content.

## Prerequisites


* [terraform](https://www.terraform.io/) version `0.11.13` installed on your machine and available on your command line.
* Your test project in GCP.
* VM Image with TB LZ for GCP (for instructions how to build such image, see: [pack](../pack/README.md) readme file.

## Build

To build the test Google Cmpute Engine instance using your image run the following command:

`terraform init`

`terraform apply -var "project_id=your-test-project-id" -var "image=family/your-image-family"`

