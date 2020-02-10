def GenerateConfig(context):

    resources = []
    if context.properties.get('bucket-export-settings'):
        action_dependency = [context.env['project']]
        bucket_name = context.properties['bucket-export-settings']['bucket-name']
        if context.properties['bucket-export-settings'].get('create-bucket'):
            resources.append({
                'name': bucket_name,
                'type': 'gcp-types/storage-v1:buckets',
                'properties': {
                    'project': context.env['project'],
                    'name': bucket_name,
                    'location': context.properties['bucket-location']
                }
            })
            action_dependency.append(bucket_name)

    return {'resources': resources}