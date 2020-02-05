def GenerateConfig(context):
    """Creates the subnetwork with environment variables."""

    resources = []
    for network in context.properties['networks']:
        resources.append({
            'name':  'bootstrap-network-subnet',
            'type': 'gcp-types/compute-v1:subnetworks',
            'properties': {
                'project': context.env['project'],
                'routingConfig': {
                    'routingMode': 'REGIONAL',
                },
                'network': context.properties['network'],
                'region': context.properties['region'],
                'ipCidrRange': context.properties['ipCidrRange'],
                'metadata': {
                    'runtimePolicy': ['CREATE']
                }
            }
        })

    return {'resources': resources}



