# tb-gcp-activator

This repository is responsible for building an activator infrastructrue under 'Applications' folder.

It creates a project with following components: 
 - activator and workspace projects
 - empty kubentetes cluster for application in activator project
 - kubenetes cluster with jenkins master deployment in workspace project
 - empty git repository in workspace project
 
 ## Prerequisites
 
This module uses modules from two other repositories:
 - <https://github.com/tranquilitybase-io/tb-common-tr>
 - <https://github.com/tranquilitybase-io/tb-ec-gcp>
 
 and assumes that this two repositories are already cloned next to this repository
 To be able to use this module you need to clone this two repositories under the same 
 directory, you've got this repository:
 ```aidl
 <directory>
    <current_directory>(tb-gcp-activator)
    tb-common-tr
    tb-ec-gcp
```

#### To get access to Jenkins master:
- find the loadbalancer ip in `Network services` tab in the workspace project
- paste the ip address to your browser:
  http://<loadbalancer_ip>
- configure jenkins setting up the users and admin password immediately after the deployment 