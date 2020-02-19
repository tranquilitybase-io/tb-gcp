tb\_config\_creator
=====================

`tb_config_creator` generates the required configuration prior to deploy the Tranquility Base solution from Marketplace.

Intended Use
------------

This script was created to be executed by future deployers of Tranquility Base from Marketplace. It performs the following configuration:
 1. Creation of a service account with the following permissions:"
   - at the folder level"
     - resourcemanager.folderAdmin
     - resourcemanager.projectCreator
     - resourcemanager.projectDeleter
     - billing.projectManager
     - compute.xpnAdmin
     - owner
     - compute.networkAdmin  
   - at the project level
     - compute.admin
   - at the billing level
     - billing.admin
 2. Activation of the following APIs:
   - appengine.googleapis.com
   - bigquery-json.googleapis.com
   - bigquerystorage.googleapis.com
   - cloudbilling.googleapis.com
   - cloudkms.googleapis.com
   - cloudresourcemanager.googleapis.com 
   - compute.googleapis.com
   - container.googleapis.com
   - containerregistry.googleapis.com
   - datastore.googleapis.com
   - iap.googleapis.com
   - iam.googleapis.com
   - iamcredentials.googleapis.com
   - logging.googleapis.com
   - oslogin.googleapis.com
   - pubsub.googleapis.com
   - serviceusage.googleapis.com
   - sourcerepo.googleapis.com
   - sqladmin.googleapis.com
   - storage-api.googleapis.com
   
The tool verifies that the provided Project, Folder and Billing Account do exist and are accessible to the authenticated account. If not, the tool exits with error message.

Provided that the supplied parameters are correct, the tool will inform the user about the configurations that will be created and will prompt for a final confirmation. If user confirms, the configuration will be created. 

*NOTE*: The user needs elevated permissions to run the configuration. See details further below.

<!--#With the generated Service Account, the user will now be able to launch the solution from Marketplace, in the specified project.
When the solution is launched from Marketplace, the following components will be generated:
- a VM instance (known as bootstrap server) with private access
- a network and subnet where the VM will run
- a Cloud NAT to allow the VM to deploy the Landing Zone
- a Cloud Storage bucket to hold Terraform state
- Firewall Rules for IAP access
-->
Usage
-----

```
Usage: /home/usr1/bin/tb_config_creator <arguments>

-p, --project_id <id>             (REQUIRED) Project ID where the bootstrap server will be installed (e.g. -p my-project-xxxx)
-s, --service-account <string>    (REQUIRED) Service account name to run the boostrap server (e.g. -s my-service-account)
-f, --parent-folder-id <id>       (REQUIRED) Parent folder ID where Landing zone will be deployed (e.g. -f 705953663545)
-b, --billing-account-id <string> (REQUIRED) Billing account ID tied to all Tranquility Base consumption (e.g. -b F9C122-73127B-50AE5B)
```
Execute with elevated permissions
----------------- 
The configuration must be created by a Google account with elevated permissions. In order to find out which account/s are currently authenticated with `gcloud`, the following command can be run:
```
$ gcloud auth list
  Credentialed Accounts
ACTIVE  ACCOUNT
        my-user1@gmail.com
*       my-user2@gmail.com
To set the active account, run:
    $ gcloud config set account `ACCOUNT`
```
In this example, the output of this command shows that there are two accounts authenticated with gcloud, my-user1 and my-user2, being the latter the one currently active.

If a new account must be authorized, then the following command has to be run:

```
$ gcloud auth login

You are already authenticated with gcloud when running
inside the Cloud Shell and so do not need to run this
command. Do you wish to proceed anyway?

Do you want to continue (Y/n)?
```
Given that there are two accounts authenticated already (as seen above) and even more we are testing from Cloud Shell, proper authentications are created already. We will respond **Y** to proceed: 
```
Do you want to continue (Y/n)?  y

Go to the following link in your browser:

    https://accounts.google.com/o/oauth2/auth?code_challenge=JS5GP8xDtqzCbk6X-9WLsC04m9e7s8edhgOqWpB24m8&prompt=select_account&code_challenge_method=S256&access_type=offline&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&client_id=32555940559.apps.googleusercontent.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth


Enter verification code:
```
We will press the link and obtain an OAuth token from Google. Finally, we enter and confirm this token into the screen:
```
Enter verification code: 4/wgF4zsx92lwRiAD7Td1jLcMPNdatYs5HtVnVSMfGlzeKqG0N4EKvhcQ

You are now logged in as [my-user3@gmail.com].
Your current project is [my-project-xxxx].  You can change this setting by running:
  $ gcloud config set project PROJECT_ID
```
The output of the below command shows now that our third user is now the active now. Ready to run the configuration!
```
$ gcloud auth list
  Credentialed Accounts
ACTIVE  ACCOUNT
        my-user1@gmail.com
        my-user2@gmail.com
*       my-user3@gmail.com
To set the active account, run:
    $ gcloud config set account `ACCOUNT`
```


Example execution
-----------------

```
$ tb_projects_deleter.sh -p my-project-xxxx -s my-service-account -b F9C122-73127B-50AE5B -f 705953663545
  Found project my-service-account.
  Found parent folder 705953663545.
  Found billing account 01A2F5-73127B-50AE5BF9C122-73127B-50AE5B.
  
  You are about to create Service Account [my-service-account] and activate API's in project [my-project-xxxx].
  
  1. Permissions of the Service Account:
    - at the project level
      - compute.admin
    - at the folder level
      - resourcemanager.folderAdmin
      - resourcemanager.projectCreator
      - resourcemanager.projectDeleter
      - compute.networkAdmin
      - compute.xpnAdmin
      - owner
    - at the billing account level
      - billing.admin
  2.Activation of the following API's:
    - appengine.googleapis.com
    - bigquery-json.googleapis.com
    - bigquerystorage.googleapis.com
    - cloudbilling.googleapis.com
    - cloudkms.googleapis.com
    - cloudresourcemanager.googleapis.com
    - compute.googleapis.com
    - container.googleapis.com
    - containerregistry.googleapis.com
    - datastore.googleapis.com
    - iap.googleapis.com
    - iam.googleapis.com
    - iamcredentials.googleapis.com
    - logging.googleapis.com
    - oslogin.googleapis.com
    - pubsub.googleapis.com
    - serviceusage.googleapis.com
    - sourcerepo.googleapis.com
    - sqladmin.googleapis.com
    - storage-api.googleapis.com
  
  Press Y to continue or any other key to abort: 
```

Notice that the script will interrupt execution and ask for confirmation before deleting the identified folders and projects. The script will abort if the user presses any key either then a CAPITAL **Y** as shown below:

```
Press Y to continue or any other key to abort: y
Aborting...
$
```

If **Y** is pressed, it will automatically create the Service Account and activate the API's:

```
Creating a service account...
Created service account [my-service-account].
Adding permissions at the project level...
Updated IAM policy for project [my-project-xxxx].
Adding permissions at the folder level...
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Adding permissions at the billing account level...
Updated IAM policy for account [F9C122-73127B-50AE5B].
Activating essential APIs...
Essential APIs acitvated.

The connfiguration has been completed successfully.
You can now deploy the Tranquility Base solution using [my-service-account@my-project-xxxx.iam.gserviceaccount.com] in project [my-project-xxxx].$
```

Installation
------------

This is an example installation process, different approaches are possible to achieve the same result which is to have the script on a directory included on the **PATH** environment variable.

1. Clone the repository:

```
$ mkdir $HOME/repositories
$ cd $HOME/repositories
$ git clone https://github.com/tranquilitybase-io/tb-gcp
```

2. Create a local `$HOME/bin` directory link the script to it and include the directory on the shell's **PATH** environment variable.

```
$ mkdir -p $HOME/bin
$ ln -s $HOME/repositories/tb-gcp/tb-gcp-tools/tb_config_creator/tb_config_creator $HOME/bin/tb_config_creator
$ echo 'export PATH="$PATH:$HOME/bin"' >> $HOME/bashrc
```

3. Start a new shell with the new configuration:

```
$ bash
```

Upgrade
-------

This is an example upgrade process, which assumes that the installation process described on the previous section was followed.

*NOTE:* This process upgrades all tools and code available on this repository, not just `tb_config_creator`.

1. Change into the local repository's directory and fetch the latest references from the remote GitHub repository:

```
$ cd $HOME/repositories/tb-gcp
$ git fetch origin
```

2. Make sure the remote `master` branch is checked out:

```
$ git checkout origin/master
```

*NOTE:* Because `$HOME/bin/tb_config_creator` is a symbolic link to the checked out file, no further steps are required to conclude the upgrade.
