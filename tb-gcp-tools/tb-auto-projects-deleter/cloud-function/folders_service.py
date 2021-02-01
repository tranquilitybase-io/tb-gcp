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
        if resp:
            folders.append([entry['name'].split('/')[-1] for entry in resp['folders']])
            for folder_ids in folders:
                for folder in  folder_ids:
                    folders.extend(self.get_all_child_folders(folder))
        folders = list(dict.fromkeys(folders))
        folders.reverse()
        print()
        return folders

    def get_all_child_folders(self,folder_id: str) -> str:
        """
        :param folder_id:
        :return:
        """
        #get initial child folder
        child_folders = []
        resp = self.service.folders().list(parent="folders/{}".format(folder_id)).execute()
        #if empty return an empty list
        if not resp:
            return child_folders
        #otherwise, append the child folder to the list
        else:
            child_folders.append([entry['name'].split('/')[-1] for entry in resp['folders']])
        #for each folder in the list, look for a sub folder
        for folder in child_folders:
            resp = self.service.folders().list(parent="folders/{}".format(folder)).execute()
            #if there is no response, return the current list
            if not resp:
                return child_folders
                #otherwise append the child folder
            else:
                child_folders.append([entry['name'].split('/')[-1] for entry in resp['folders']])
        return child_folders

    def delete_folder(self, folder_id: str) -> str:
        """
        :param folder_id:
        :return:
        """
        resp = self.service.folders().delete(name="folders/{}".format(folder_id)).execute()