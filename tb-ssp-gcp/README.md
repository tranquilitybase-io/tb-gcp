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

Run following commands to create docker image

### Build image
```bash
gcloud auth configure-docker
docker build --no-cache -t <name of your repository>:<version number> .
eg.
docker build --no-cache -t self-service-portal:v27 .
```

##### Build arguments

* `tb_repo_url` - URL address to the Tranquility Base repo, the default value is `https://github.com/tranquilitybase-io`. 
  Example invocation can look like: 
 ```bash
  docker build -t <name of your repository>:<version number> --build-arg tb_repo_url=https://<USER>@github.com/<YOUR_REPO_EITH_TB> .
```

### Tag image
```bash

docker tag <name of your repository>:<version number> gcr.io/<project id>/<name of your repository>:<version number>
eg.
docker tag self-service-portal:v27 gcr.io/<project_id>/self-service-portal:v27
```

### Push repository 

```bash
docker push gcr.io/<project id>/<name of your repository>:<version number>
eg.
docker push gcr.io/<project_id>/self-service-portal:v27
```