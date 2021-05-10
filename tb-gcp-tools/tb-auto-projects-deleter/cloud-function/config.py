import os
from google.oauth2 import service_account
from oauth2client.client import GoogleCredentials

global credentials


def establish_gcp_credentials():
    global credentials

    if is_cloud_run:
        credentials = GoogleCredentials.get_application_default()
    else:
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "credentials/credentials.json"
        credentials_path = os.environ["GOOGLE_APPLICATION_CREDENTIALS"]
        credentials = service_account.Credentials.from_service_account_file(credentials_path)


def get_env(name: str, default: str) -> str:
    value = default
    if name in os.environ:
        value = os.environ[name]
    return value


def str_to_bool(s):
    if type(s) == bool:
        return s

    if s == 'True':
        return True
    elif s == 'False':
        return False
    else:
        raise ValueError


def str_to_list(string_list: str):
    un_trimmed = string_list.split(",")
    trimmed = []
    for item in un_trimmed:
        trimmed.append(item.strip())
    return trimmed


dry_run = str_to_bool(get_env('dry_run', True))
is_cloud_run = str_to_bool(get_env('is_cloud_run', "False"))
EXCLUDE_DELETE_LABEL = get_env('EXCLUDE_DELETE_LABEL', "dont-delete")
EXCLUDE_EMPTY_FOLDER = str_to_list(get_env('EXCLUDE_EMPTY_FOLDER', "Shared Services,  Applications, tranquilitybase-development"))
ROOT_PROJECT = get_env('ROOT_PROJECT', "256793750708")
TEST_OUTSIDE_SCOPE = get_env('TEST_OUTSIDE_SCOPE', "261170752178")
ReportWebhook = get_env('WebHook', "none")


print("")
print("------ Configuration ------")
print("dry_run: " + str(dry_run))
print("is_cloud_run: " + str(is_cloud_run))
print("EXCLUDE_DELETE_LABEL: " + EXCLUDE_DELETE_LABEL)
print("EXCLUDE_EMPTY_FOLDER: " + str(EXCLUDE_EMPTY_FOLDER))
print("TEST_OUTSIDE_SCOPE: " + str(TEST_OUTSIDE_SCOPE))
print("ROOT_PROJECT: " + ROOT_PROJECT)
print("---------------------------")
print("")

establish_gcp_credentials()
