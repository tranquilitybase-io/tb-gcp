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

    def can_view_folder(self, folder_id: str) -> str:
        try:
            self.service.folders().list(parent="folders/{}".format(folder_id)).execute()
            return True
        except Exception as e:
            print(f"Could not access {folder_id}".format(folder_id))
            return False

    def get_folders_under(self, folder_id: str) -> list:
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
            child_folders = self.get_folders_under(folder)
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
        print("Delete folder " + folder_id)
        if self.dry_run:
            print("mock delete folder {} ".format(folder_id))
        else:
            self.service.folders().delete(name="folders/{}".format(folder_id)).execute()

    def get_folder_name(self, root_folder_id: str, folder_id_looked_for: str) -> str:
        resp = self.service.folders().list(parent="folders/{}".format(root_folder_id)).execute()
        if resp:
            for entry in resp['folders']:
                member_folder_id = entry['name'].split('/')[-1]
                if member_folder_id == folder_id_looked_for:
                    return entry['displayName']
                else:
                    nested = self.get_folder_name(member_folder_id, folder_id_looked_for)
                    if nested:
                        return nested

        return None
