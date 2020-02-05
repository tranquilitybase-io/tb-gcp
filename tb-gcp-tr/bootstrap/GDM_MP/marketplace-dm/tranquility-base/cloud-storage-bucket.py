def GenerateConfig(context):

    resources = []
    if context.properties.get('bucket-export-settings'):
        bucket_name = 'None'
        action_dependency = [context.env['project']]
        if context.properties['bucket-export-settings'].get('create-bucket'):
            bucket_name = context.env['project'] + '-export-bucket-1'
            resources.append({
                'name': bucket_name,
                'type': 'gcp-types/storage-v1:buckets',
                'properties': {
                    'project': context.env['project'],
                    'name': bucket_name
                }
            })
            action_dependency.append(bucket_name)
        else:
            bucket_name = context.properties['bucket-export-settings']['bucket-name']
        resources.append({
            'name': 'set-export-bucket',
            'action': 'gcp-types/compute-v1:compute.projects.setUsageExportBucket',
            'properties': {
                'project': context.env['project'],
                'bucketName': 'gs://' + bucket_name
            }
        })

        return {'resources': resources}