# General purpose

Project is used for building an activator infrastructure:
It contains 3 HTTP entrypoints: 
 - /isalive [GET] - healthcheck
 - /build [POST] - create an activator infrastructure
 - /destroy [POST] - destroy an activator infrastructure
 
Main flow: 
 - clone activator terraform script
 - find free subnets CIDR
 - use terraform script to create subnets in shared network
 - update terraform activator inputs subnets name 
 - run terraform activator 

To run this application we have to create a docker image and place it in a Kubernetes cluster in deployment.yaml 

## Build docker image 

Make sure you're in the `tb-gcp` directory. Run following commands to create docker image.

### Build image

```bash
gcloud auth configure-docker
docker build --no-cache -f tb-ssp-gcp/Dockerfile -t <name of your repository>:<version number> .
eg.
docker build --no-cache -f tb-ssp-gcp/Dockerfile -t self-service-portal:v33 .
```

### Tag image
```bash

docker tag <name of your repository>:<version number> gcr.io/<project id>/<name of your repository>:<version number>
eg.
docker tag self-service-portal:v33 gcr.io/<project_id>/self-service-portal:v33
```

### Push repository 

```bash
docker push gcr.io/<project id>/<name of your repository>:<version number>
eg.
docker push gcr.io/<project_id>/self-service-portal:v33
```