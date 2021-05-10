import string
import time
from random import choice

from services.billing_service import BillingService
from services.folders_service import FoldersService
from services.projects_service import ProjectsService

from config import dry_run
from config import credentials
from config import ROOT_PROJECT
from config import TEST_OUTSIDE_SCOPE

billing_service = BillingService(credentials, dry_run)
folders_service = FoldersService(credentials, dry_run)
projects_service = ProjectsService(credentials, dry_run)


def random_string() -> str:
    letters = string.ascii_lowercase
    return ''.join(choice(letters) for i in range(10))


def cannot_view_folder(scope_folder: str):
    print("Check: Cannot view folder")
    check_result = folders_service.can_view_folder(scope_folder)
    if check_result:
        raise Exception("Error: checks show Service Account CAN view an out of bounds area")
    else:
        print("OK: cannot view folder outside bounds")


def cannot_create_project(scope_folder: str):
    print("Check: Cannot create project")
    check_result = projects_service.can_create_project("tb-del-tst-"+random_string(), scope_folder)
    if check_result:
        raise Exception("Error: checks show Service Account CAN create project in an out of bounds area")
    else:
        print("OK: cannot create project outside bounds")


def can_create_and_delete_project(scope_folder: str):
    print("Check: can create and delete project")
    name = "tb-tst-"+random_string()
    check_result = projects_service.can_create_project(name, scope_folder)
    if check_result:
        print("OK: can create project in bounds")
    else:
        raise Exception("Error: checks show Service Account CANNOT create project as needed")

    # GCP needs some grace time to create the project before deletion
    time.sleep(10)

    check_result = projects_service.delete_project_system_check(name)
    if check_result:
        print("OK: can delete project in bounds")
    else:
        raise Exception("Error: checks show Service Account CANNOT delete project as needed")


def run_system_checks():
    print("")
    print("- Running system checks -")
    try:
        # out of scope
        print("")
        cannot_view_folder(TEST_OUTSIDE_SCOPE)
        print("")
        cannot_create_project(TEST_OUTSIDE_SCOPE)

        # in scope:
        print("")
        can_create_and_delete_project(ROOT_PROJECT)
    except Exception as e:
        message = "\nSystem checks failed\n"
        message += str(e)
        raise Exception(message)

    print("- System checks passed! -")
