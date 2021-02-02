# https://cloud.google.com/resource-manager/reference/rest/v2/folders

from googleapiclient import discovery


class FoldersService:

    def __init__(self, credentials):
        self.credentials = credentials
        self.service = discovery.build('cloudresourcemanager', 'v2', credentials=credentials)

    def get_folders_under_parent_folder(self, folder_id: str) -> str:
        """
        :param folder_id: folder id number
        :return: List of folder ids
        """
        resp = self.service.folders().list(parent="folders/{}".format(folder_id)).execute()
        folders = []
        child_folders = []
        if resp:
            folders = [entry['name'].split('/')[-1] for entry in resp['folders']]
        folders.reverse()
        for folder in folders:
           child_folders =  self.get_folders_under_parent_folder(folder)
        child_folders.reverse()
        folders.append(child_folders)
        return folders

    def delete_folder(self, folder_id: str) -> str:
        """
        :param folder_id:
        :return:
        """
        resp = self.service.folders().delete(name="folders/{}".format(folder_id)).execute()