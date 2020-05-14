from google.cloud import resource_manager

import subprocess
import sys

BUILD_PROJECT_ID = sys.argv[1]
BILLING_ACCOUNT = sys.argv[2]
PATH_DELETE_SCRIPT = sys.argv[3]
BOOTSTRAP_PREFIX = "bootstrap-"
NO_DELETE_LABEL = "no-delete"
client = resource_manager.Client()

def main():
    projects_to_delete_list = \
        list(filter(filter_non_tb_projects, client.list_projects()))

    for project in projects_to_delete_list:
        folder_id = project.parent['id']
        print(project)
        # call_deleter_script_for_project(project.id, BILLING_ACCOUNT, folder_id, PATH_DELETE_SCRIPT)

def filter_non_tb_projects(project):
    if project.name.startswith(BOOTSTRAP_PREFIX) and NO_DELETE_LABEL not in project.labels:
        return True
    else:
        return False


def run_bash_command(cmd):
    ps = subprocess.Popen(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = ps.communicate()[0].decode()
    print(output)


def call_deleter_script_for_project(project, billing_account, folder_id, path_to_script):
    print("DELETING RESOURCES CREATED BY " + project.name + " PROJECT")
    random_id = get_random_id_from_project(project)
    cmd = "yes Y | bash {} -r {} -f {} -b {}".format(
        path_to_script, random_id, folder_id, billing_account)
    run_bash_command(cmd)


def get_random_id_from_project(project):
    return project.name[-8:]


if __name__ == "__main__":
    print("DEBUG")
    main()