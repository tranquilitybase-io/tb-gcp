# start service

Runs the appplication defined by yaml file in given kubernetes cluster.

###Inputs
* **cluster_config_path**  
The filename of the config file allowing to connect to the cluster.  

* **cluster_context**  
Optional kubeconfig context. This allows to connect to a cluster either then the one configured on the currently selected context.

* **k8s_template_file**  
File name where there is described what kubernetes resources should be created to run the application

###Outputs

**id**
The id of the resource created by this module. Indicates that `kubectl apply` command was already performed

**service_path**
Path to file containing kubernetes deployment used in this module
