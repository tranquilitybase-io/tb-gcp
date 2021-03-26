import time

import pymsteams
from datetime import datetime

from reporter.reporter import generate_report
from services.billing_service import BillingService
from services.folders_service import FoldersService
from services.projects_service import ProjectsService

from config import dry_run
from config import credentials
from config import EXCLUDE_DELETE_LABEL
from config import EXCLUDE_EMPTY_FOLDER
from config import ROOT_PROJECT
from config import ReportWebhook

global kept_folders
billing_service = BillingService(credentials, dry_run)
folders_service = FoldersService(credentials, dry_run)
projects_service = ProjectsService(credentials, dry_run)
quota_grace_delay = 0.05


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


def add_to_kept_folders(folder):
    global kept_folders
    if folder not in kept_folders:
        kept_folders.append(folder)


def get_empty_folders(root_folder: str) -> list:
    empty_folders = []
    root_content = folders_service.get_folders_under(root_folder)
    for folder in root_content:
        no_sub_folders = folders_service.is_folder_empty(folder)
        sub_projects = projects_service.get_projectIds_under_folder(folder)
        if no_sub_folders and not sub_projects:
            folder_name = folders_service.get_folder_name(root_folder, folder)
            if folder_name not in EXCLUDE_EMPTY_FOLDER:
                empty_folders.append(folder)
            else:
                add_to_kept_folders(folder)
    return empty_folders


def delete_all(delete_list: list):
    for item_id in delete_list:
        __disable_and_delete_project(item_id)
        __delete_folder(item_id)


def delete_folders(delete_list: list):
    for item_id in delete_list:
        __delete_folder(item_id)


def decorate_folder_list(root_folder: str, folder_list: list) -> list:
    decorated_list = []
    for folder_id in folder_list:
        name = folders_service.get_folder_name(root_folder, folder_id)
        if name:
            app = f"{folder_id} ({name})".format(folder_id, name)
            decorated_list.append(app)
        else:
            decorated_list.append(folder_id)
    return decorated_list


def prune_all_empty_folders(root_folder):
    global kept_folders
    kept_folders = []

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

    # decorated_list = decorate_folder_list(root_folder, full_empty_folder_list)
    return full_empty_folder_list


def get_projects_under_root():
    folders_under_root = folders_service.get_folders_under(ROOT_PROJECT)

    start_projects = []
    for folder in folders_under_root:
        projects = projects_service.get_projectIds_under_folder(folder)
        print("grace time for quota")
        time.sleep(quota_grace_delay)
        if projects:
            start_projects.append(projects)

    project_details = []
    project_ids = sum(start_projects, [])
    for id in project_ids:
        print("grace time for quota")
        time.sleep(quota_grace_delay)
        project_details.append(projects_service.get_project_details(id))

    projects_at_root = projects_service.get_project_dicts_under_folder(ROOT_PROJECT)
    project_details = project_details + projects_at_root

    return project_details


def run_delete_task():

    print("")
    print("-- Starting clean up task --")
    start_time = datetime.now()
    start_timestamp = start_time.timestamp()
    start_projects = get_projects_under_root()
    print("start_projects " + str(start_projects))

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
    delete_all(delete_list)

    print("")
    print("prune empty folders")
    full_empty_folder_list = prune_all_empty_folders(ROOT_PROJECT)
    print("full_empty_folder_list: " + str(full_empty_folder_list))
    # global kept_folders
    # kept_folders = decorate_folder_list(ROOT_PROJECT, kept_folders)
    print("adding kept_folders to keep list: " + str(kept_folders))
    keep_list = keep_list + kept_folders

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


def __disable_and_delete_project(project_id: str):
    __delete_liens_for_project(project_id)
    billing_service.disable_billing_for_project(project_id)
    projects_service.delete_project(project_id)


def __get_kept_projects(exclusion_label: str) -> list:
    """
    :param parent:
    :param bootstrap_prefix:
    :param exclusion_label:
    :return:
    """
    active_projects = get_projects_under_root()

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
    active_projects = get_projects_under_root()

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
    try:
        liens = projects_service.get_liens_for_project(project_id)
        for lien in liens:
            print("DELETING LIEN {}".format(lien))
            projects_service.delete_lien(lien)
    except Exception as e:
        print("Error deleting liens for " + project_id + " " + str(e))
    return


def __delete_folder(folder_id: str):
    """
    :param folder_id:
    :return:
    """
    try:
        folders_service.delete_folder(folder_id)
    except Exception as e:
        print("Error deleting folder " + folder_id + " " + str(e))
