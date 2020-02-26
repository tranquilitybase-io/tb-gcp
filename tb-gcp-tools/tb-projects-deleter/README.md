tb\_projects\_deleter
=====================

`tb_projects_deleter` finds and deletes bootstrap and landing zone projects under the base folder.

Intended Use
------------

This script was created to speed up testing of Tranquility Base's bootstrap deployment. It tries to find all the bootstrap projects and any application projects and deletes them after asking the user for a confirmation. If the tool does not find all projects and folders that it expects, it will exit with errors to avoid unsafe execution.

Usage
-----

```
Usage: /home/usr1/bin/tb-projects-deleter <arguments>

-b, --bootstrap-random-id <id>          (REQUIRED) Bootstrap project's random ID (e.g. -b c556112f)
-f, --parent-folder-id <id>             (REQUIRED) Landing zone's parent folder ID (e.g. -f 238741628734)
-l, --lz-discriminator <string>         (REQUIRED) Landing zone's folder discriminator (e.g. -l usr1)
```

Example execution
-----------------

```
$ tb-projects-deleter -f 238741628734 -b 14c2aec8 -l usr1-tb01
Found project bootstrap-usr1-tb01-14c2aec8.
Found 'Tranquility Base - usr1-tb01' (875058758784) folder.
Found 'Applications' (762389942404) folder.
Found 'Shared Services' (347553333271) folder.
Found shared-networking-2d81f6a5 project.
Didn't find any application projects.
Found shared-ssp-2d81f6a5 shared-operations-2d81f6a5 shared-security-2d81f6a5  project(s).
SHOULD THE ABOVE FOLDERS AND PROJECTS BE DELETED? (press Y to continue or any other key to abort) Y
```

Notice that the script will interrupt execution and ask for confirmation before deleting the identified folders and projects. The script will abort if the user presses any key either then a CAPITAL **Y** as shown below:

```
Found shared-security-ad9ae118 shared-ssp-ad9ae118 shared-operations-ad9ae118  project(s).
SHOULD THE ABOVE FOLDERS AND PROJECTS BE DELETED? (press Y to continue or any other key to abort) y
Aborting...
$
```

If **Y** is pressed, it will automatically delete the identified folders and projects and the Shared VPC as shown below:

```
Found shared-ssp-2d81f6a5 shared-operations-2d81f6a5 shared-security-2d81f6a5  project(s).
SHOULD THE ABOVE FOLDERS AND PROJECTS BE DELETED? (press Y to continue or any other key to abort) Y

Deleting Liens...

Deleted [liens/p34467704482-l41cc4b5d-05b4-4944-be77-49e9e1717aa0].

No application projects to delete. Skipping...

Deleting shared services projects (other then networking)...

Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-ssp-2d81f6a5].

You can undo this operation for a limited period by running '
        commands below. See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects
         $ gcloud projects undelete shared-ssp-2d81f6a5
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-operations-2d81f6a5].

You can undo this operation for a limited period by running '
        commands below. See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects
         $ gcloud projects undelete shared-operations-2d81f6a5
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-security-2d81f6a5].

You can undo this operation for a limited period by running '
        commands below. See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects
         $ gcloud projects undelete shared-security-2d81f6a5

Deleting shared networking project...

Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/shared-networking-2d81f6a5].

You can undo this operation for a limited period by running '
        commands below. See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects
         $ gcloud projects undelete shared-networking-2d81f6a5

Deleting folders...

Deleted [<Folder
 createTime: u'2019-09-02T15:04:31.346Z'
 displayName: u'Shared Services'
 lifecycleState: LifecycleStateValueValuesEnum(DELETE_REQUESTED, 2)
 name: u'folders/347553333271'
 parent: u'folders/875058758784'>].
Deleted [<Folder
 createTime: u'2019-09-02T15:04:32.373Z'
 displayName: u'Applications'
 lifecycleState: LifecycleStateValueValuesEnum(DELETE_REQUESTED, 2)
 name: u'folders/762389942404'
 parent: u'folders/875058758784'>].
Deleted [<Folder
 createTime: u'2019-09-02T15:04:27.039Z'
 displayName: u'Tranquility Base - usr1-tb01'
 lifecycleState: LifecycleStateValueValuesEnum(DELETE_REQUESTED, 2)
 name: u'folders/875058758784'
 parent: u'folders/238741628734'>].
Deleting bootstrap project...

Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/bootstrap-usr1-tb01-14c2aec8].

You can undo this operation for a limited period by running '
        commands below. See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects
         $ gcloud projects undelete bootstrap-usr1-tb01-14c2aec8

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
