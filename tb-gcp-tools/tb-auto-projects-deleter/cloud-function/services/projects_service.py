# https://cloud.google.com/resource-manager/reference/rest/v1/projects

from googleapiclient import discovery

from services.helper import handle_permission_error


class ProjectsService:

    def __init__(self, credentials, dry_run):
        self.dry_run = dry_run
        self.credentials = credentials
        self.service = discovery.build('cloudresourcemanager', 'v1', credentials=credentials, cache_discovery=False)

    def can_create_project(self, project_name: str, parent_folder: str) -> bool:
        try:
            project_body = {
                "projectId": project_name,
                "name": project_name,
                "parent": {
                    "id": parent_folder,
                    "type": "folder"
                }
            }

            req = self.service.projects().create(body=project_body)
            req.execute()
            return True
        except Exception as e:
            message = f"Could not create project under {parent_folder}".format(parent_folder)
            handle_permission_error(e, message)
            return False

    def get_liens_for_project(self, project_id: str):
        resp = self.service.liens().list(parent="projects/{}".format(project_id)).execute()
        liens = []
        if resp:
            liens = [entry['name'] for entry in resp['liens']]
        return liens

    def delete_lien(self, lien_name: str):
        if self.dry_run:
            print("mock delete lien".format(lien_name))
        else:
            resp = self.service.liens().delete(name=lien_name).execute()
            print("DELETING LIEN".format(lien_name, resp))
        return

    def delete_project_system_check(self, project_id: str) -> bool:
        try:
            self.service.projects().delete(projectId=project_id).execute()
        except Exception as e:
            message = f"Error deleting project for {project_id}".format(project_id)
            handle_permission_error(e, message)
            return False
        return True

    def delete_project(self, project_id: str):
        print("Delete project " + project_id)
        try:
            if self.dry_run:
                print("mock delete project {}".format(project_id))
            else:
                self.service.projects().delete(projectId=project_id).execute()
        except Exception as e:
            print(str(e))

    def delete_project_by_project_number(self, project_number: str):
        if self.dry_run:
            print("mock delete project {}".format(project_number))
        else:
            resp = self.service.projects().delete(projectNumber=project_number).execute()
            print("DELETING PROJECT {project_number}, {resp}".format(project_number, resp))
        return

    def get_project_details(self, project_id: str) -> dict:
        project = None
        resp = self.service.projects().list(
            filter="projectId:{} ".format(project_id)).execute()
        if resp:
            project = [entry for entry in resp['projects'] if entry['lifecycleState'] == 'ACTIVE'][0]
        return project

    def get_project_dicts_under_folder(self, folder_id: str) -> list:
        """
        Returns project dictionaries that represent project state, example dictionary:
        {
          "projectNumber": "132259151143",
          "projectId": "bootstrap-b5930959",
          "lifecycleState": "DELETE_REQUESTED",
          "name": "bootstrap-b5930959",
          "labels": {
            "admin": "connor-mcshane"
          },
          "createTime": "2020-05-15T21:11:49.794Z",
          "parent": {
            "type": "folder",
            "id": "578018371171"
          }
        }
        :param folder_id:
        :return:
        """

        projects = []
        resp = self.service.projects().list(
            filter="parent.type:folder parent.id:{} ".format(folder_id)).execute()
        if resp:
            projects = [entry for entry in resp['projects'] if entry['lifecycleState'] == 'ACTIVE']
        return projects

    def get_all_projects(self):
        projects = []
        resp = self.service.projects().list().execute()
        if resp:
            projects = [entry for entry in resp['projects'] if entry['lifecycleState'] == 'ACTIVE']
        return projects

    def get_projectIds_under_folder(self, folder_id: str) -> list:
        projects = []
        resp = self.service.projects().list(
            filter="parent.type:folder parent.id:{}".format(folder_id)).execute()
        if resp:
            projects = [entry['projectId'] for entry in resp['projects'] if entry['lifecycleState'] == 'ACTIVE']
        return projects

