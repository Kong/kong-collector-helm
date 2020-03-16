# Kong-Collector

[Kong-Collector](https://konghq.com/products/kong-enterprise/kong-immunity) is
an application which enables the use of Kong Brain and Kong Immunity.

Kong Brain and Kong Immunity are installed as add-ons on Kong Enterprise, using
a Collector API and a Collector Plugin to communicate with Kong Enterprise.

## Introduction

This chart bootstraps a
[Kong-Collector](https://docs.konghq.com/enterprise/latest/brain-immunity/install-configure/)
deployment on a [Kubernetes](http://kubernetes.io) cluster using the
[Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.12+
- Kong Enterprise version 1.3.0.2+
  [chart](https://github.com/Kong/charts/tree/master/charts/kong#kong-enterprise)

## Installing the Chart

(If you already have a Kong Admin API, skip to Step 4. )

To install the chart with the release name `my-release`:

1. [Add Kong Enterprise license
   secret](https://github.com/Kong/charts/tree/master/charts/kong#kong-enterprise)

2. [Add Kong Enterprise registry
   secret](https://github.com/Kong/charts/tree/master/charts/kong#kong-enterprise-docker-registry-access)

3. Set up Kong Enterprise with postgresql, overriding postgres host and setting
   a port for kong manager to use the Kong Admin API

```console
$ helm install my-kong kong/kong --version 1.3.0 -f kong-values.yaml --set env.admin_api_uri=$(minikube ip):32001
```

4. Add Kong Brain and Immunity registry secret

```console
$ kubectl create secret docker-registry bintray-kong-brain-immunity \
    --docker-server=kong-docker-kong-brain-immunity-base.bintray.io \
    --docker-username=$BINTRAY_USER \
    --docker-password=$BINTRAY_KEY
```

5. Set up collector, overriding Kong Admin host to allow collector to push 
   swagger specs to Kong

```console
$ helm install my-release . --set kongAdminHost=my-kong-kong-admin
```

6. Add a "Collector Plugin" to Kong, using the Kong Admin API or Kong Manager
   GUI

```console
$ open http://$(minikube ip):32002
```

_OR_

```console
$ curl -s -X POST <NODE_IP>:<KONG_ADMIN_PORT>/<WORKSPACE>/plugins \
  -d name=collector \
  -d config.http_endpoint=http://<COLLECTOR_HOST>:<SERVICE_PORT> \
  -d config.log_bodies=true \
  -d config.queue_size=100 \
  -d config.flush_timeout=1 \
  -d config.connection_timeout=300
```

7. Follow the [Kong Brain & Immunity
   Documentation](https://docs.konghq.com/enterprise/latest/brain-immunity/install-configure/)

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

## Parameters

The following tables lists the configurable parameters of the PostgreSQL chart
and their default .Values.

| Parameter                       | Description                                           | Default                                                                                  |
| ------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `image.repository`              | Kong-Collector Image repository                       | `kong-docker-kong-brain-immunity-base.bintray.io/kong-brain-immunity`                    |
| `image.tag`                     | Kong-Collector Image tag                              | `1.1.0`                                                                                  |
| `imagePullSecrets`              | Specify Image pull secrets                            | `- name: bintray-kong-brain-immunity` (does not add image pull secrets to deployed pods) |
| `kongAdmin.protocol`                 | Protocol on which Kong Admin API can be found            | `http`                                                                     |
| `kongAdmin.host`                 | Hostname where Kong Admin API can be found            | `my-kong-kong-admin`                                                                     |
| `kongAdmin.servicePort`                 | Port where Kong Admin API can be found                | `8001`                                                                                   |
| `kongAdmin.token`                 | Token used for making requests to Kong Admin API                | `my-token`                                                                                   |
| `collector.service.port`                      | TCP port on which the Collector service is exposed | `5000`                                                                                  |
| `collector.containerPort`                      | TCP port on which Collector listens for kong traffic | `5000`                                                                                  |
| `collector.nodePort`                      | Port to access Collector API from outside the cluster | `31555`                                                                                  |
| `postgresql.enabled` | Deploy PostgreSQL server                            | `true`                                                                              |
| `postgresql.postgresqlDatabase` | PostgreSQL dataname name                              | `collector`                                                                              |
| `postgresql.service.port`       | PostgreSQL port                                       | `5432`                                                                                   |
| `postgresql.postgresqlUsername` | PostgreSQL user name                                  | `collector`                                                                              |
| `postgresql.postgresqlPassword` | PostgreSQL password                                   | `collector`                                                                              |
| `redis.enabled` | Deploy Redis server                            | `true`                                                                              |
| `redis.port`                    | Redis port                                            | `6379`                                                                                   |
| `redis.password`                | Redis password                                        | `redis`                                                                                  |
| `testendpoints.enabled`         | Creates a testing service                             | `false`                                                                                  |

### Tested with the following environment

The following was tested on MacOS in minikube with the following configuration:

1. Start local kubernetes cluster

```console
$ minikube start --vm-driver hyperkit --memory='6144mb' --cpus=4
```

2. Install both kong and collector charts then `open http://$(minikube
   ip):32002`

```console
$ helm install my-kong kong/kong --version 1.3.0 -f kong-values.yaml --set env.admin_api_uri=$(minikube ip):32001
$ helm install my-release . --set kongAdmin.host=my-kong-kong-admin
$ kubectl wait --for=condition=complete job --all && helm test my-release
```

3. Create kong service and route then add a collector plugin pointing at the
   collector, if you have access to 
   [kong-collector](https://github.com/kong/kong-collector) you can pull this
   code and run the integration tests using as shown below

```console
$ KONG_ADMIN_URL=$(minikube ip):32001  \
   COLLECTOR_URL=my-release-kong-collectorapi:5000  \
   ENDPOINT_URL=my-release-kong-collectorapi-testendpoints:6000 ./kong-setup.sh

$ KONG_PROXY_URL=$(minikube ip):32000  \
   KONG_PROXY_INTERNAL_URL=$(minikube ip):8000 \
   KONG_ADMIN_URL=$(minikube ip):32001  \
   COLLECTOR_URL=$(minikube ip):31555 pipenv run python integration_test.py

```

## Changelog

### Unreleased

- Exposed RBAC token
- Pinned collector at 1.2.1
- Added dev portal to enable swagger test
- Upgrade kong chart

### 0.1.3

> PR [#2](https://github.com/Kong/kong-collector-helm/pull/2)

#### Improvements

- Pinned versions
- Added testing features
- Added wait for kong
- Remove duplicate values

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

## Seeking help

If you run into an issue, bug or have a question, please reach out to the Kong
community via [Kong Nation](https://discuss.konghq.com).
Please do not open issues in [this](https://github.com/helm/charts) repository
as the maintainers will not be notified and won't respond.
