COMPUTE_URL_BASE = 'https://www.googleapis.com/compute/v1/'
def GenerateConfig(context):
    """Creates configuration."""

    project_id = context.env['project']
    resources = []
    for vm in context.properties['vms']:
        resources.append({
            'name': vm,
            'type': 'gcp-types/compute-v1:instances',
            'properties': {
                'tags': {'items': ['no-ip', 'iap']},
                'project': project_id,
                'region': context.properties['region'],
                'zone': context.properties['zone'],
                'serviceAccounts': [
                    {"email": context.properties['bootstrapServerServiceAccount']}
                ],
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
                        'sourceImage': (context.properties['sourceImage'])
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