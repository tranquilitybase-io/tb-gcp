# Google Marketplace Deployment Manager scripts

## Overview
The scripts in the folder `tb-dep-manager` are those required to deploy the bootstrap server from the Google marketplace.

## Deployment on Google Marketplace

Zip up the folder 'marketplace-dm'
From the [partner marketplace editor for the Tranquility Base solution](https://console.cloud.google.com/partner/editor/gft-group-public/tranquility-base)
* Click on the Edit button next to Deployment Package

* On the right hand side click on 'Upload a package'

* Browse for the zip file created above

* Click 'Continue', ensuring 'Keep metadata changes from .jinja.display' is checked

* Click 'Save' to save the new deployment package in the Marketplace solution

* **NB If there are any errors when saving then correct these and retry**

* Click 'Preview & test solution' to try out the deployed package from the Marketplace.

* **NB** The script `tb-config-creator` (in folder `tb-config-creator`) needs to be run before these deployment manager scripts**
    * This is to ensure that a **project** and a **service account** that the scripts rely on are created beforehand
    
## Deployment testing from gcloud
* Run the `tb-config-creator` (in folder `tb-config-creator`) to create a **project** and a **service account** that the scripts rely on are created beforehand
* Make a note of the project created
* run `gcloud init` to set the currently used project to be this project
* Create a file `test_config_with_mp_params.yaml` from the `test_config.yaml.template` file that includes the parameters that would be entered in the marketplace
* **NB Ensure that this file is NOT checked in as it will contain the billing account id** 
* To deploy:
``` google cloud
gcloud deployment-manager deployments create deployment-tbase --config=tb-marketplace\tb-dep-manager\test_config_with_mp_params.yaml
```

To delete deployment
``` google cloud
gcloud deployment-manager deployments delete deployment-tbase --quiet
```
