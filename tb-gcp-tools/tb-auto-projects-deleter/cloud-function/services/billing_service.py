# https://developers.google.com/resources/api-libraries/documentation/cloudbilling/v1/python/latest/cloudbilling_v1.projects.html#updateBillingInfo


from apiclient import discovery


class BillingService:

    def __init__(self, credentials, dry_run):
        self.dry_run = dry_run
        self.credentials = credentials
        self.service = discovery.build('cloudbilling', 'v1', credentials=credentials, cache_discovery=False)

    def disable_billing_for_project(self, project_id):
        """

        :param project_id: project_id to cap costs for, by disabling billing
        :return:
        """

        # service = __get_cloud_billing_service()
        # https://developers.google.com/resources/api-libraries/documentation/cloudbilling/v1/python/latest/cloudbilling_v1.projects.html#updateBillingInfo
        try:
            if self.dry_run:
                print("mock remove billing account")
            else:
                billing_info = self.service.projects().updateBillingInfo(name='projects/{}'.format(project_id), body={'billingAccountName': ''}).execute()
        except Exception as e:
            print("Error disabling billing for " + project_id + " " + str(e))