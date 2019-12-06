def GenerateConfig(context):
  """Creates the subnetwork with environment variables."""

  resources = []
  for network in context.properties['networks']:
    resources.append({
      'name':  'bootstrap-network-subnet',
      'type': 'gcp-types/compute-v1:subnetworks',
      'properties': {
          'project': context.properties['project'],
          'routingConfig': {
              'routingMode': 'REGIONAL',
          },
          'network': context.properties['network'],
          'region': context.properties['region'],
          'ipCidrRange': context.properties['ipCidrRange'],
      'metadata': {
            'dependsOn': ['project'],
            'runtimePolicy': ['CREATE']
          }
      }
    })

  return {'resources': resources}



