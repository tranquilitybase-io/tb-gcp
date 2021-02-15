import pymsteams
from datetime import datetime

from reporter.reporter import generate_report
from services.billing_service import BillingService
from services.folders_service import FoldersService
from services.projects_service import ProjectsService

from config import dry_run
from config import credentials
from config import EXCLUDE_DELETE_LABEL
from config import ROOT_PROJECT
from config import ReportWebhook

billing_service = BillingService(credentials, dry_run)
folders_service = FoldersService(credentials, dry_run)
projects_service = ProjectsService(credentials, dry_run)


def create_keep_list() -> list:
    item_list = __get_kept_projects(EXCLUDE_DELETE_LABEL)
    listing = []
    for item in item_list:
        tb_folder = str(item['parent']['id'])
        listing.append(tb_folder)

    listing = list(dict.fromkeys(listing))
    return listing


def create_delete_and_conflict_list(keep_list: list):
    delete_list = []
    conflict_list = []
    project_to_delete = __get_target_projects(EXCLUDE_DELETE_LABEL)
    for item in project_to_delete:
        tb_folder = item['parent']['id']
        if tb_folder in keep_list:
            conflict_list.append(tb_folder)
        else:
            delete_list.append(tb_folder)

    delete_list = list(dict.fromkeys(delete_list))
    conflict_list = list(dict.fromkeys(conflict_list))
    return delete_list, conflict_list


def send_teams_message(message: str):
    if ReportWebhook != "none":
        my_teams_message = pymsteams.connectorcard(ReportWebhook)
        my_teams_message.text(message)
        my_teams_message.send()


def run_delete_task():

    print("")
    print("-- Starting clean up task --")

    start_time = datetime.now()
    start_timestamp = start_time.timestamp()
    start_projects = projects_service.get_all_projects()

    print("")
    print("Projects/folders to keep:")
    keep_list = create_keep_list()
    print("keep: " + str(keep_list))

    delete_list, conflict_list = create_delete_and_conflict_list(keep_list)
    print("Projects under root folder to delete:")
    print("")
    orphan_projects_kill = __get_target_projects(EXCLUDE_DELETE_LABEL)
    parent_folders_kill = []
    
    for project in orphan_projects_kill:
        print(project)
        parent_folder = str(project['parent']['id'])
        parent_folders_kill.append(parent_folder)
    parent_folders_kill = list(dict.fromkeys(parent_folders_kill))
    parent_folders_kill.reverse()
    print(parent_folders_kill)

    orphan_projects_kill_ids = []
    print("Deleting projects: ") 
    for project in orphan_projects_kill:
        project_id = str(project['projectId'])
        print(project_id)
        orphan_projects_kill_ids.append(project_id)
    
    for project_id in orphan_projects_kill_ids:
        #delete orphan projects
        projects_service.delete_project(project_id)

    #projects with dont-delete label that are not in a sub folder
    print("")
    print("Orphan projects to keep")
    orphan_projects_keep = __get_kept_projects(EXCLUDE_DELETE_LABEL)
    print(orphan_projects_keep)
    parent_folders_keep = []
    
    for project in orphan_projects_keep:
        parent_folder = str(project['parent']['id'])
        parent_folders_keep.append(parent_folder)
    keep_listing = list(dict.fromkeys(parent_folders_keep))
    print(keep_listing)

    print("")
    print("deleting folders: ")
    for folder in parent_folders_kill:
        if folder in parent_folders_keep:
            continue
        __disable_and_delete_all_projects_under_folder(folder)
        __delete_folder(folder)
    #for each folder under root folder, generate a list of sub folders for each child folder, 
    #the structure must be reversed such that lowest child folders are first.

    
    end_projects = projects_service.get_all_projects()

    finish_timestamp = datetime.now().timestamp()
    duration = round(finish_timestamp - start_timestamp, 2)

    report = generate_report(dry_run,
                             start_time.strftime("%H:%M:%S"), str(duration),
                             delete_list, keep_list, conflict_list,
                             start_projects, end_projects)

    send_teams_message(report)

    print("-- clean up finished --")


def delete_tbase_deployments(event, context):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
    """

    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))
    try:
        run_delete_task()
    except Exception as e:
        send_teams_message('<strong style="color:red;">Error running delete task</strong>')
        raise Exception("Error running delete task " + str(e))


def __delete_tbase_deployment(tb_folder):
    """
    :param tb_folder:
    :return:
    """
    child_folders = folders_service.get_folders_under_parent_folder(tb_folder)

    if child_folders:
        print("found child folders under " + str(tb_folder))
        for child_folder in child_folders:
            if child_folder == ROOT_PROJECT:
                continue
            __disable_and_delete_all_projects_under_folder(child_folder)
            __delete_folder(child_folder)

    if tb_folder is not ROOT_PROJECT:
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
        __delete_liens_for_project(project_id)
        billing_service.disable_billing_for_project(project_id)
        projects_service.delete_project(project_id)
    return


def __get_kept_projects(exclusion_label: str) -> list:
    """
    :param parent:
    :param bootstrap_prefix:
    :param exclusion_label:
    :return:
    """
    active_projects = projects_service.get_all_projects()

    # filter in projects that have the exclusion label e.g 'dont-delete'
    kept_projects = [project for project in active_projects
                     if 'labels' in project and exclusion_label in project['labels']]
    return kept_projects


def __get_target_projects(exclusion_label: str) -> list:
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


def __get_target_projects(exclusion_label: str) -> list:
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
    folders_service.delete_folder(folder_id)

if __name__ == "__main__":
    run_delete_task()
