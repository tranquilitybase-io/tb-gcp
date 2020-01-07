def GenerateConfig(context):
  """Creates the network with environment variables."""

  resources = []
  for network in context.properties['networks']:
    resources.append({
      'name':  network,
      'type': 'gcp-types/compute-v1:networks',
      'properties': {
          'subnet-mode': 'auto',
          'project': context.properties['project'],
          'routingConfig': {
              'routingMode': 'GLOBAL',
              'autoCreateSubnetworks': True
          },
      'metadata': {
            'dependsOn': ['project'],
            'runtimePolicy': ['CREATE']
          }
      }
    })

  return {'resources': resources}
