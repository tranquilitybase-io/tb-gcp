COMPUTE_URL_BASE = 'https://www.googleapis.com/compute/v1/'
def GenerateConfig(context):
  """Creates configuration."""

  project_id = context.properties['project']
  resources = []
  for vm in context.properties['vm']:
    resources.append({
      'name': vm,
      'type': 'gcp-types/compute-v1:instances',
      'properties': {
          'tags': {'items': ['no-ip', 'iap']},
          'project': project_id,
          'region': 'europe-west2',
          'zone': context.properties['zone'],
          'machineType': ''.join([COMPUTE_URL_BASE, 'projects/',
                                  context.properties['project'], '/zones/',
                                  context.properties['zone'], '/machineTypes/',
                                  context.properties['machineType']]),
          'disks': [{
              'deviceName': 'boot',
              'type': 'PERSISTENT',
              'boot': True,
              'autoDelete': True,
              'initializeParams': {
                  'sourceImage': ''.join([COMPUTE_URL_BASE, 'projects/',
                                            'bootstrap-dave123',
                                            '/global/images/',
                                            'tb-tr-debian-9--2019-11-19t09-46-43z'])
              }
          }],
          'networkInterfaces': [{
              'subnetwork': '$(ref.bootstrap-network-subnet.selfLink)',
          }],
          'metadata': {
              'dependsOn': [project_id],
              'items': [{
                  'key': 'startup-script',
                  'value': ''.join(['#!/bin/bash\n',
                                    'python -m SimpleHTTPServer 80']),
              }],
              'runtimePolicy': ['CREATE']
          }
      }
    })

  return {'resources': resources}