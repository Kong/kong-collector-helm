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
- Kong Enterprise version 0.35.3+ or later [chart](https://github.com/helm/charts/tree/master/stable/kong)

## Installing the Chart
To install the chart with the release name `my-release`:

- Add docker registry secret eg. `kong-docker-kong-brain-immunity-base.bintray.io`
```console
kubectl create secret docker-registry regcred \
    --docker-server=REGISTRY_URI \
    --docker-username=USERNAME \
    --docker-password=APIKEY
```

- Deploy kong-ee [chart](https://github.com/helm/charts/tree/master/stable/kong#kong-enterprise)
- Ensure kong admin API is available at the kong.host:kong.port specified in values.yaml
- Add collector plugin pointing at the collector host and port initialized in the following step.

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
| `image.tag`                        | Kong-Collector Image tag                                                                                                                                              | `1.1.0`                                                         |
| `imagePullSecrets`                           | Specify Image pull secrets                                                                                                                                                | `- name: regcred` (does not add image pull secrets to deployed pods)                                                         |
| `kong.host`        | Kong admin api host name                                                                                                                     | `my-kong-kong-admin`                                                         |
| `kong.port`        | Kong port                                                                                                                    | `"8001"`                                                         |
| `postgresql.postgresqlDatabase`            | PostgreSQL dataname name                                                                              | `collector`                                                         |
| `postgresql.service.port`            | PostgreSQL port                                                                              | `5432`                                                         |
| `postgresql.postgresqlUsername`            | PostgreSQL user name                                                                              | `collector`                                                         |
| `postgresql.postgresqlPassword`            | PostgreSQL password                                                                              | `collector`                                                         |
| `redis.port`            | Redis port                                                                              | `5432`                                                         |
| `redis.password`            | Redis password                                                                              | `redis`                                                         |


### Tested with the following environment

The following was tested on macos in minikube with the following configuration:
```sh
minikube start --vm-driver hyperkit --memory='6128mb' --cpus=4
```
```sh
helm install k-psql \
  --set postgresqlPassword=kong,postgresqlUsername=kong,postgresqlDatabase=kong \
    stable/postgresql

kubectl create secret generic kong-enterprise-license --from-file=./license 


helm install my-kong stable/kong -f kong-values.yaml

kubectl create secret docker-registry regcred \
    --docker-server=REGISTRY_URI \
    --docker-username=USERNAME \
    --docker-password=APIKEY

helm install collector .
```

*Testing instructions*

1. Create kong service and route then add a collector plugin pointing at the collector host and port.
1. Ensure traffic is being passed to collector by checking the collector logs


## Changelog

### 0.1.2

> PR [#1](https://github.com/Kong/kong-collector-helm/pull/1)
#### Improvements

- Labels on all resources have been updated to adhere to the Helm Chart
  guideline here:
  https://v2.helm.sh/docs/developing_charts/#syncing-your-chart-repository
- Normalized redis and postgres configurations
- Added initContainers
- Bump collector to 1.1.0
- Use helm dependencies
- Add migration job for flask db upgrade