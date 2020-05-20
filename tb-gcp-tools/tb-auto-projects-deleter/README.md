tb-auto-deleter
=====================

`tb-auto-deleter`  is a cloud function that is triggered via a cron service to deleter tranquility base deployments 
for development use.

Intended Use
------------
Once the cloud function and source files are uploaded, a cron service (e.g Cloud Scheduler) can be setup to trigger the function. The function selects 
bootstrap projects in the GCP organization that don't have an exclusion label, then with those projects it attempts to 
delete the entire tranquility base depoyment linked to each bootstrap project.