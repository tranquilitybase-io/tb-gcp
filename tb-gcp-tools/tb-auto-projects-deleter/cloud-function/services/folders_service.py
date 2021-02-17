# https://cloud.google.com/resource-manager/reference/rest/v2/folders

from googleapiclient import discovery


class FoldersService:

    def __init__(self, credentials, dry_run):
        self.dry_run = dry_run
        self.credentials = credentials
        self.service = discovery.build('cloudresourcemanager', 'v2', credentials=credentials, cache_discovery=False)

    def is_folder_empty(self, folder_id: str) -> bool:
        folder_under = self.get_next_folder_under_parent_folder(folder_id)
        if len(folder_under) > 0:
            return False
        return True

    def get_folders_under_parent_folder(self, folder_id: str) -> list:
        """
        :param folder_id: folder id number
        :return: List of folder ids
        """
        resp = self.service.folders().list(parent="folders/{}".format(folder_id)).execute()
        parent_folder = []
        total_folders = []
        if resp:
            parent_folder = [entry['name'].split('/')[-1] for entry in resp['folders']]

        for folder in parent_folder:
            total_folders.append(folder)
            child_folders = self.get_folders_under_parent_folder(folder)
            total_folders += child_folders

        return total_folders

    def get_next_folder_under_parent_folder(self, folder_id: str) -> str:
        """
        :param folder_id: folder id number
        :return: List of folder ids
        """
        resp = self.service.folders().list(parent="folders/{}".format(folder_id)).execute()
        child_folder = []
        if resp:
            child_folder = [entry['name'].split('/')[-1] for entry in resp['folders']]
        return child_folder

    def delete_folder(self, folder_id: str) -> str:
        """
        :param folder_id:
        :return:
        """
        if self.dry_run:
            print("mock delete folder {} ".format(folder_id))
        else:
            resp = self.service.folders().delete(name="folders/{}".format(folder_id)).execute()
            #print("DELETE FOLDER ID {folder_id}".format(folder_id))