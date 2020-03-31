tb-config-creator
=====================

`tb-config-creator` generates the required pre-configuration to deploy the Tranquility Base solution from Marketplace.

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
     - compute.networkAdmin  

   - at the project level
     - compute.admin
     - storage.admin

   - at the billing level
     - billing.admin

 2. Activation of the following APIs:
   - cloudbilling.googleapis.com
   - cloudkms.googleapis.com
   - cloudresourcemanager.googleapis.com 
   - compute.googleapis.com
   - container.googleapis.com
   - containerregistry.googleapis.com
   - logging.googleapis.com
   - serviceusage.googleapis.com
   - sourcerepo.googleapis.com
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
$ ./tb-config-creator <arguments>

-f, --parent-folder-id <id> (REQUIRED) Parent folder ID (or Organisation ID) where the Tranquility Base will be deployed (e.g. -f 705953663545)
-b, --billing-account-id <string> (REQUIRED) Billing account ID tied to all Tranquility Base consumption (e.g. -b F9C122-73127B-50AE5B)
```
Execute with elevated permissions
----------------- 
The configuration must be created by a Google account with owner role at the Folder level (or Organisation) under which the Tranquility Base
resource hierarchy will be deployed. In order to find out which account/s are currently authenticated with `gcloud`, the following command can be run:
```
$ gcloud auth list
  Credentialed Accounts
ACTIVE  ACCOUNT
        my-user1@gmail.com
*       my-user2@gmail.com
To set the active account, run:
    $ gcloud config set account `ACCOUNT`
```
In this example, the output of this command shows that there are two accounts authenticated with `gcloud` already, my-user1 and my-user2, being the latter the one currently active.

If a new account must be authorized, then the following command has to be run:

```
$ gcloud auth login

You are already authenticated with gcloud when running
inside the Cloud Shell and so do not need to run this
command. Do you wish to proceed anyway?

Do you want to continue (Y/n)?
```
Given that there are two accounts authenticated already (as seen above) and even more we are testing from Cloud Shell, proper authentications are created already. We will respond **y** to proceed: 
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
./tb-config-creator -f 705953663545 -b F9C122-73127B-50AE5B
  Found project my-service-account.
  Found parent folder 705953663545.
  Found billing account F9C122-73127B-50AE5B.
  
  You are about to create a Project to host the Tranquility Base bootstrap server.
  The project name will be randomized and provided to you at the end of this configuration
  In addition, a "super" Service Account will be created and several API's will be activated in that project:
  
  1. Permissions of the Service Account:
    - at the project level
      - compute.admin
      - storage.admin
    - at the folder level
      - resourcemanager.folderAdmin
      - resourcemanager.projectCreator
      - resourcemanager.projectDeleter
      - compute.networkAdmin
      - compute.xpnAdmin
    - at the billing account level
      - billing.admin
  2.Activation of the following API's:
    - cloudbilling.googleapis.com
    - cloudkms.googleapis.com
    - cloudresourcemanager.googleapis.com
    - compute.googleapis.com
    - container.googleapis.com
    - containerregistry.googleapis.com
    - logging.googleapis.com
    - serviceusage.googleapis.com
    - sourcerepo.googleapis.com
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
Creating project...

Create in progress for [https://cloudresourcemanager.googleapis.com/v1/projects/bootstrap-ab91ae78].
Waiting for [operations/cp.5499274151206614851] to finish...done.
Enabling service [cloudapis.googleapis.com] on project [bootstrap-ab91ae78]...
Operation "operations/acf.1bdd5536-29cd-46da-ac7a-48290cc4dec8" finished successfully.
Linking project to billing account...
Linked project to billing account [F9C122-73127B-50AE5B].
Creating service account...
Created service account [bootstrap-sa].
Adding permissions at the project level...
Updated IAM policy for project [bootstrap-ab91ae78].
Updated IAM policy for project [bootstrap-ab91ae78].
Adding permissions at the folder level...
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Updated IAM policy for folder [705953663545].
Adding permissions at the billing account level...
Updated IAM policy for account [F9C122-73127B-50AE5B].
Activating essential APIs...
Operation "operations/acf.48ef9fa6-2aca-4397-8807-11d003538321" finished successfully.
Operation "operations/acf.8f58d144-330f-4122-80e1-91534020044a" finished successfully.
Operation "operations/acf.a4f16d57-0ee9-471c-bb96-be440bdf75fb" finished successfully.
Operation "operations/acf.27d88272-921f-446f-8800-3ef50caf3dbc" finished successfully.
Operation "operations/acf.8a2848f4-5cf9-485e-8e0b-8a6a964840dc" finished successfully.
Operation "operations/acf.dfa2d987-4950-45bb-8d72-05872de3a8fb" finished successfully.
Operation "operations/acf.01c8250f-38a0-4425-a912-651f5bf284d9" finished successfully.
Operation "operations/acf.c88e4dad-8f1f-461a-a8f3-5bb8a6a84fff" finished successfully.
Operation "operations/acf.7065af63-0afd-4cf3-8b38-21fd467e09e4" finished successfully.
Essential APIs activated.

Configuration completed!
You can now deploy Tranquility Base from Marketplace in project [bootstrap-ab91ae78].

```

Installation
------------

This is an example installation process, different approaches are possible to achieve the same result which is to have the script on a directory included on the **PATH** environment variable.

1. Clone the repository:

``` bash
mkdir $HOME/repositories
cd $HOME/repositories
git clone https://github.com/tranquilitybase-io/tb-gcp
```

2. Create a local `$HOME/bin` directory link the script to it and include the directory on the shell's **PATH** environment variable.

``` bash
mkdir -p $HOME/bin
ln -s $HOME/repositories/tb-gcp/tb-marketplace/tb-config-creator/tb-config-creator $HOME/bin/tb-config-creator
echo 'export PATH="$PATH:$HOME/bin"' >> $HOME/bashrc
```

3. Start a new shell with the new configuration:

``` bash
bash
```

Upgrade
-------

This is an example upgrade process, which assumes that the installation process described on the previous section was followed.

*NOTE:* This process upgrades all tools and code available on this repository, not just `tb-config-creator`.

1. Change into the local repository's directory and fetch the latest references from the remote GitHub repository:

``` bash
cd $HOME/repositories/tb-gcp
git fetch origin
```

2. Make sure the remote `master` branch is checked out:

``` bash
git checkout origin/master
```

*NOTE:* Because `$HOME/bin/tb-config-creator` is a symbolic link to the checked out file, no further steps are required to conclude the upgrade.
