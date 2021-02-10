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
        value = os.environ['dry_run']
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


dry_run = str_to_bool(get_env('dry_run', True))
is_cloud_run = str_to_bool(get_env('is_cloud_run', "False"))
EXCLUDE_DELETE_LABEL = get_env('EXCLUDE_DELETE_LABEL', "dont-delete")
ROOT_PROJECT = get_env('ROOT_PROJECT', "943956663445")

print("")
print("------ Configuration ------")
print("dry_run: " + str(dry_run))
print("is_cloud_run: " + str(is_cloud_run))
print("EXCLUDE_DELETE_LABEL: " + EXCLUDE_DELETE_LABEL)
print("ROOT_PROJECT: " + ROOT_PROJECT)
print("---------------------------")
print("")

establish_gcp_credentials()
