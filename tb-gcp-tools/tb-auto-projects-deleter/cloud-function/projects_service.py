# https://cloud.google.com/resource-manager/reference/rest/v1/projects

from googleapiclient import discovery


class ProjectsService:

    def __init__(self, credentials):
        self.credentials = credentials
        self.service = discovery.build('cloudresourcemanager', 'v1', credentials=credentials)

    def get_liens_for_project(self, project_id: str):
        resp = self.service.liens().list(parent="projects/{}".format(project_id)).execute()
        liens = []
        if resp:
            liens = [entry['name'] for entry in resp['liens']]
        return liens

    def delete_lien(self, lien_name: str):
        resp = self.service.liens().delete(name=lien_name).execute()
        print("DELETING LIEN".format(lien_name, resp))
        return

    def delete_project(self, project_id: str):
        resp = self.service.projects().delete(projectId=project_id).execute()
        print("DELETING PROJECT".format(project_id, resp))
        return

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
            filter="parent.type:folder parent.id:{}".format(folder_id)).execute()
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