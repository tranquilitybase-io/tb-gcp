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
        tb_folder = str(item['projectNumber'])
        listing.append(tb_folder)

    listing = list(dict.fromkeys(listing))
    return listing


def create_delete_and_conflict_list(keep_list: list):
    delete_list = []
    conflict_list = []
    projects_to_delete = __get_target_projects(EXCLUDE_DELETE_LABEL)
    for project in projects_to_delete:
        project_number = project['projectNumber']
        if project_number in keep_list:
            conflict_list.append(project_number)
        else:
            delete_list.append(project_number)

    delete_list = list(dict.fromkeys(delete_list))
    conflict_list = list(dict.fromkeys(conflict_list))
    return delete_list, conflict_list


def send_teams_message(message: str):
    if ReportWebhook != "none":
        my_teams_message = pymsteams.connectorcard(ReportWebhook)
        my_teams_message.text(message)
        my_teams_message.send()


def get_empty_folders(root_folder: str) -> list:
    empty_folders = []
    root_content = folders_service.get_folders_under_parent_folder(root_folder)
    for folder in root_content:
        no_sub_folders = folders_service.is_folder_empty(folder)
        sub_projects = projects_service.get_projectIds_under_folder(folder)
        if no_sub_folders and not sub_projects:
            empty_folders.append(folder)
    return empty_folders


def delete_all_under_id(delete_list: list):
    for id in delete_list:
        __disable_and_delete_all_projects_under_folder(id)
        __delete_folder(id)


def delete_folders(delete_list: list):
    for id in delete_list:
        __delete_folder(id)


def prune_all_empty_folders(root_folder):
    max_iteration = 3
    if dry_run:
        max_iteration = 1

    counter = 0
    full_empty_folder_list = []
    empty_folders = get_empty_folders(root_folder)
    while empty_folders:
        full_empty_folder_list += empty_folders
        delete_folders(empty_folders)
        empty_folders = get_empty_folders(root_folder)

        counter += 1
        if counter >= max_iteration:
            break

    return full_empty_folder_list


def run_delete_task():
    print("")
    print("-- Starting clean up task --")
    start_time = datetime.now()
    start_timestamp = start_time.timestamp()
    start_projects = projects_service.get_all_projects()

    print("")
    print("Projects/folders to keep:")
    keep_list = create_keep_list()
    print("keep_list " + str(keep_list))

    print("")
    delete_list, conflict_list = create_delete_and_conflict_list(keep_list)
    print("conflict_list " + str(conflict_list))
    print("delete_list " + str(delete_list))

    print("")
    print("Run deletion")
    delete_all_under_id(delete_list)

    print("")
    print("prune empty folders")
    full_empty_folder_list = prune_all_empty_folders(ROOT_PROJECT)
    print("full_empty_folder_list: " + str(full_empty_folder_list))

    print("")
    print("Generate report")
    end_projects = projects_service.get_all_projects()
    finish_timestamp = datetime.now().timestamp()
    duration = round(finish_timestamp - start_timestamp, 2)

    report = generate_report(dry_run,
                             start_time.strftime("%H:%M:%S"), str(duration),
                             delete_list, full_empty_folder_list, keep_list, conflict_list,
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
