tb-projects-deleter
=====================

`tb-projects-deleter` finds and deletes bootstrap and landing zone projects under the base folder.

Intended Use
------------

This script was created to speed up testing of Tranquility Base's bootstrap deployment. It tries to find all the bootstrap projects and any application projects and deletes them after asking the user for a confirmation. If the tool does not find all projects and folders that it expects, it will exit with errors to avoid unsafe execution.

Usage
-----

```
Usage: /home/usr1/bin/tb-projects-deleter <arguments>

-r, --bootstrap-random-id <id>	(REQUIRED) Bootstrap project's random ID (e.g. -r 6813a9eb )
-f, --folder-id <id>	(REQUIRED) Landing zone's folder ID (e.g. -f 238741628734)
-b, --billing-account-id <string>	(REQUIRED) Tranquility Base related Billing Account (e.g. -b AB1234-CD1234-EF1234)
```

Example execution
-----------------

```
$ ./tb-projects-deleter -r 98b3465e -f 1035941827006 -b AB1234-CD1234-EF1234 
Found project bootstrap-98b3465e.
Found 'Tranquility Base - 98b3465e' (698227606755) folder.
Found 'Applications' (806674588542) folder.
Found 'Shared Services' (276539436569) folder.
Found shared-networking-98b3465e project.
Didn't find any application projects.
Found shared-secrets-98b3465e shared-telemetry-98b3465e shared-itsm-98b3465e shared-ec-98b3465e shared-billing-98b3465e shared-bastion-98b3465e  project(s).
Found billing account AB1234-CD1234-EF1234.
SHOULD THE ABOVE FOLDERS AND PROJECTS BE DELETED? (press Y to continue or any other key to abort) Y
```

Notice that the script will interrupt execution and ask for confirmation before deleting the identified folders and projects. The script will abort if the user presses any key either then a CAPITAL **Y** as shown below:

```
SHOULD THE ABOVE FOLDERS AND PROJECTS BE DELETED? (press Y to continue or any other key to abort) y
Aborting...
$
```

If **Y** is pressed, it will automatically delete the identified folders and projects and the Shared VPC as shown below:

```
SHOULD THE ABOVE FOLDERS AND PROJECTS BE DELETED? (press Y to continue or any other key to abort) Y

Deleting Liens...

Deleted [liens/p740123174815-l45ced260-54ed-48fa-9a61-e2db89177deb].

No application projects to delete. Skipping...

Deleting shared services projects (other then networking)...

Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-security-98b3465e].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete shared-security-98b3465e

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-telemetry-98b3465e].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete shared-telemetry-98b3465e

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-itsm-98b3465e].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete shared-itsm-98b3465e

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-ec-98b3465e].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete shared-ec-98b3465e

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-billing-98b3465e].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete shared-billing-98b3465e

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-bastion-98b3465e].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete shared-bastion-98b3465e

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.

Deleting shared networking project...

Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-networking-98b3465e].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete shared-networking-98b3465e

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.

Removing bootstrap service account [bootstrap-sa@bootstrap-98b3465e.iam.gserviceaccount.com] as billing account admin...
Updated IAM policy for account [AB1234-CD1234-EF1234].
Removing activator service account [activator-dev-sa@shared-ec-98b3465e.iam.gserviceaccount.com] as billing account admin...
Updated IAM policy for account [AB1234-CD1234-EF1234].
Removing bootstrap service account [bootstrap-sa@bootstrap-98b3465e.iam.gserviceaccount.com] bindings at the project level...
Updated IAM policy for project [bootstrap-98b3465e].
Updated IAM policy for project [bootstrap-98b3465e].
Removing bootstrap service account [bootstrap-sa@bootstrap-98b3465e.iam.gserviceaccount.com] IAM policy bindings for folder [238741628734]...
Updated IAM policy for folder [238741628734].
Updated IAM policy for folder [238741628734].
Updated IAM policy for folder [238741628734].
Updated IAM policy for folder [238741628734].
Updated IAM policy for folder [238741628734].
Updated IAM policy for folder [238741628734].
Removing activator service account [activator-dev-sa@shared-ec-98b3465e.iam.gserviceaccount.com] as billing account admin...
Updated IAM policy for account [AB1234-CD1234-EF1234].

Deleting bootstrap project...
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/bootstrap-98b3465e].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete bootstrap-98b3465e

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.

Deleting folders...
Deleted [<Folder
 createTime: u'2020-03-03T10:30:32.734Z'
 displayName: u'Shared Services'
 lifecycleState: LifecycleStateValueValuesEnum(DELETE_REQUESTED, 2)
 name: u'folders/276539436569'
 parent: u'folders/698227606755'>].
Deleted [<Folder
 createTime: u'2020-03-03T10:30:33.336Z'
 displayName: u'Applications'
 lifecycleState: LifecycleStateValueValuesEnum(DELETE_REQUESTED, 2)
 name: u'folders/806674588542'
 parent: u'folders/698227606755'>].
Deleted [<Folder
 createTime: u'2020-03-03T10:30:28.704Z'
 displayName: u'Tranquility Base - 98b3465e'
 lifecycleState: LifecycleStateValueValuesEnum(DELETE_REQUESTED, 2)
 name: u'folders/698227606755'
 parent: u'folders/238741628734'>].

$
```

Installation
------------

This is an example installation process, different approaches are possible to achieve the same result which is to have the script on a directory included on the the **PATH** environment variable.

1. Clone the repository:

```
$ mkdir $HOME/repositories
$ cd $HOME/repositories
$ git clone git@github.com:tranquilitybase-io/tb-gcp.git
```

2. Create a local `$HOME/bin` directory link the script to it and include the directory on the shell's **PATH** environment variable.

```
$ mkdir -p $HOME/bin
$ ln -s $HOME/repositories/tb-gcp/tb-gcp-tools/tb-projects-deleter/tb-projects-deleter $HOME/bin/tb-projects-deleter
$ echo 'export PATH="$PATH:$HOME/bin"' >> $HOME/bashrc
```

3. Start a new shell with the new configuration:

```
$ bash
```

Upgrade
-------

This is an example upgrade process, which assumes that the installation process described on the previous section was followed.

*NOTE:* This process upgrades all tools and code available on this repository, not just `tb-projects-deleter`.

1. Change into the local repository's directory and fetch the latest references from the remote GitHub repository:

```
$ cd $HOME/repositories/tb-gcp
$ git fetch origin
```

2. Make sure the remote `master` branch is checked out:

```
$ git checkout origin/master
```

*NOTE:* Because `$HOME/bin/tb-projects-deleter` is a symbolic link to the checked out file, no further steps are required to conclude the upgrade.
