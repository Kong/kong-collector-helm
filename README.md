# Kong-Collector

[Kong-Collector](https://konghq.com/products/kong-enterprise/kong-immunity) is an application which enables the use of Kong Brain and Kong Immunity.

Kong Brain and Kong Immunity are installed as add-ons on Kong Enterprise, using a Collector App and a Collector Plugin to communicate with Kong Enterprise.


## TL;DR;

```console
$ helm install collector .
```

## Introduction

This chart bootstraps a [Kong-Collector](https://docs.konghq.com/enterprise/1.3-x/brain-immunity/install-configure/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Prerequisites

- Kubernetes 1.12+
- Helm 2.11+ or Helm 3.0-beta3+
- Kong Enterprise version 0.35.3+ or later
- Postgresql
- Redis

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm install my-release .
```

The command deploys Kong-Collector on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following tables lists the configurable parameters of the PostgreSQL chart and their default values.

|                   Parameter                   |                                                                                Description                                                                                |                            Default                            |
|-----------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| `image.repository`                        | Kong-Collector Image repository                                                                                                                                              | `kong-docker-kong-brain-immunity-base.bintray.io/kong-brain-immunity`                                                         |
| `image.tag`                        | Kong-Collector Image tag                                                                                                                                              | `1.0.0`                                                         |
| `imagePullSecrets`                           | Specify Image pull secrets                                                                                                                                                | `- name: regcred` (does not add image pull secrets to deployed pods)                                                         |
| `kong.host`        | Kong admin api host name                                                                                                                     | `my-kong-kong-admin`                                                         |
| `kong.port`        | Kong port                                                                                                                    | `"8001"`                                                         |
| `postgres.host`            | PostgreSQL host name                                                                              | `my-psql-postgresql`                                                         |
| `postgres.port`            | PostgreSQL port                                                                              | `5432`                                                         |
| `redis.uri`        | Redis URI                                                                                                                | `redis://:redis@my-redis-master:6379/0`                                                         |
| `service.port`               | PostgreSQL port (overrides `service.port`)                                                                                                                                | `5000`                                                         |


### Tested with the following environment

The following was tested on macos in minikube with the following configuration:
```sh
minikube start --vm-driver hyperkit --memory='6128mb' --cpus=4
```
```sh
helm install my-redis \
  --set password=redis \
    stable/redis

helm install my-psql \
  --set postgresqlPassword=collector,postgresqlUsername=collector,postgresqlDatabase=collector \
    stable/postgresql

helm install k-psql \
  --set postgresqlPassword=kong,postgresqlUsername=kong,postgresqlDatabase=kong \
    stable/postgresql

kubectl create secret generic kong-enterprise-license --from-file=./license 

kubectl create secret docker-registry regcred \
    --docker-server=REGISTRY_URI \
    --docker-username=USERNAME \
    --docker-password=APIKEY

helm install my-kong stable/kong -f kong-values.yaml

helm install collector .
```

1. Create kong service and route then add a collector plugin pointing at the collector host and port.
1. Ensure traffic is being passed to collector by checking the collector logs


## TODO

1. normalise the uri for postgres
1. use initcontainers instead of waits
1. set defaults/hide for discard(product) and flask app
1. separate docker images for celery worker and beat (to hide command)
1. use chart appVersion for docker image tag