from oauth2client.client import GoogleCredentials


from billing_service import BillingService
from folders_service import FoldersService
from projects_service import ProjectsService


credentials = GoogleCredentials.get_application_default()
billing_service = BillingService(credentials)
folders_service = FoldersService(credentials)
projects_service = ProjectsService(credentials)
EXCLUDE_DELETE_LABEL = "dont-delete"
BOOTSTRAP_PREFIX = "bootstrap"

def delete_tbase_deployments(event, context):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
    """

    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))


    bootstrap_project_dicts = __get_target_projects(BOOTSTRAP_PREFIX, EXCLUDE_DELETE_LABEL)

    for bootstrap_project in bootstrap_project_dicts:
        tb_folder = bootstrap_project['parent']['id']
        __delete_tbase_deployment(tb_folder)
        


def __delete_tbase_deployment(tb_folder):
    """
    :param tb_folder:
    :return:
    """
    print("Deleting deployment linked to {}".format(tb_folder))
    child_folders = folders_service.get_folders_under_parent_folder(tb_folder)
    for child_folder in child_folders:
        __disable_and_delete_all_projects_under_folder(child_folder)
        __delete_folder(child_folder)

    __disable_and_delete_all_projects_under_folder(tb_folder)
    __delete_folder(tb_folder)


def __disable_and_delete_all_projects_under_folder(folder_id: str):
    """ Method does the following
        1. Gets all projects under folder and for each:
            1. disable  billing
            2. delete liens
            3. delete project
    :param folder_id:
    :return:
    """
    project_ids = projects_service.get_projectIds_under_folder(folder_id)
    for project_id in project_ids:
        print("DELETING AND DISABLING PROJECT {}".format(project_id))
        __delete_liens_for_project(project_id)
        billing_service.disable_billing_for_project(project_id)
        projects_service.delete_project(project_id)
    return


def __get_target_projects(bootstrap_prefix: str, exclusion_label: str) -> list:
    """
    :param parent:
    :param bootstrap_prefix:
    :param exclusion_label:
    :return:
    """
    active_projects = projects_service.get_all_projects()

    # filter out projects that have the exclusion label e.g 'dont-delete'
    target_projects = [project for project in active_projects
                       if 'labels' not in project
                       or 'labels' in project and exclusion_label not in project['labels']]

    return target_projects

def __delete_liens_for_project(project_id: str):
    """
    :param project_id:
    :return:
    """
    liens = projects_service.get_liens_for_project(project_id)
    for lien in liens:
        print("DELETING LIEN {}".format(lien))
        projects_service.delete_lien(lien)
    return

def __delete_folder(folder_id: str):
    """
    :param folder_id:
    :return:
    """
    print("DELETING FOLDER {}".format(folder_id))
    folders_service.delete_folder(folder_id)






