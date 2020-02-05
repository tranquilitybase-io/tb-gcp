COMPUTE_URL_BASE = 'https://www.googleapis.com/compute/v1/'
def GenerateConfig(context):
    """Creates configuration."""

    project_id = context.env['project']
    sourceImage = context.properties['sourceImage']
    region = context.properties['region']
    resources = []
    for vm in context.properties['vms']:
        resources.append({
            'name': vm,
            'type': 'gcp-types/compute-v1:instances',
            'properties': {
                'tags': {'items': ['no-ip', 'iap']},
                'project': project_id,
                'region': 'region',
                'zone': context.properties['zone'],
                'machineType': ''.join([COMPUTE_URL_BASE, 'projects/',
                                        context.env['project'], '/zones/',
                                        context.properties['zone'], '/machineTypes/',
                                        context.properties['machineType']]),
                'disks': [{
                    'deviceName': 'boot',
                    'type': 'PERSISTENT',
                    'boot': True,
                    'autoDelete': True,
                    'initializeParams': {
                        'sourceImage': sourceImage
                    }
                }],
                'networkInterfaces': [{
                    'subnetwork': '$(ref.bootstrap-network-subnet.selfLink)',
                }],
                'metadata': {
                    'items': [{
                        'key': 'startup-script',
                        'value': context.properties['bootstrapServerStartupScript'],
                    }],
                    'runtimePolicy': ['CREATE']
                }
            }
        })

    return {'resources': resources}