def GenerateConfig(context):
  """Creates the network with environment variables."""

  resources = []
  for network in context.properties['networks']:
    resources.append({
      'name':  'bootstrap-network3',
      'type': 'gcp-types/compute-v1:networks',
      'properties': {
          'project': context.properties['project'],
          'routingConfig': {
              'routingMode': 'REGIONAL',
          },
          'autoCreateSubnetworks': False,
      'metadata': {
            'dependsOn': ['project']
          }
      }
    })

  return {'resources': resources}
