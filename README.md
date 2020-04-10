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
- Kong Enterprise version 1.5+
  [chart](https://github.com/Kong/charts/tree/master/charts/kong#kong-enterprise)

## Installing the Chart

(If you already have a Kong Admin API, skip to Step 4. )

To install the chart with the release name `my-release`:

1. [Add Kong Enterprise license
   secret](https://github.com/Kong/charts/tree/master/charts/kong#kong-enterprise)

2. [Add Kong Enterprise registry
   secret](https://github.com/Kong/charts/tree/master/charts/kong#kong-enterprise-docker-registry-access)

3. Set up Kong Enterprise, it will need to set a reachable env.admin_api_uri to
   Kong Admin API in order for Kong Manager to make requests

```console
$ helm install my-kong kong/kong --version 1.3.0 -f kong-values.yaml \
   --set env.admin_api_uri=$(minikube ip):32001
```

4. Add Kong Brain and Immunity registry secret and RBAC user token secret

```console
$ kubectl create secret docker-registry bintray-kong-brain-immunity \
    --docker-server=kong-docker-kong-brain-immunity-base.bintray.io \
    --docker-username=$BINTRAY_USER \
    --docker-password=$BINTRAY_KEY

$ kubectl create secret generic kong-admin-token-secret --from-literal=kong-admin-token=my-token
```

5. Set up collector, overriding Kong Admin host, servicePort and token to ensure
   Kong Admin API is reachable by collector, this will allow collector to push
   swagger specs to Kong

```console
$ helm install my-release ./charts/kong-collectorapi --set kongAdmin.host=my-kong-kong-admin
```

6. Add a "Collector Plugin" using the Kong Admin API, this will allow Kong to
connect to collector.

```console
$ curl -s -X POST <NODE_IP>:<KONG_ADMIN_PORT>/<WORKSPACE>/plugins \
  -d name=collector \
  -d config.http_endpoint=http://<COLLECTOR_HOST>:<SERVICE_PORT> \
  -d config.log_bodies=true \
  -d config.queue_size=100 \
  -d config.flush_timeout=1 \
  -d config.connection_timeout=300
```

7. Check that collector is reachable by Kong Admin API

```console
$ curl -s <NODE_IP>:<KONG_ADMIN_PORT>/<WORKSPACE>/collector/alerts kong-admin-token:my-token
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

## Parameters

The following tables lists the configurable parameters of the Collector chart
and their default .Values.

| Parameter                       | Description                                           | Default                                                                                  |
| ------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `image.repository`              | Kong-Collector Image repository                       | `kong-docker-kong-brain-immunity-base.bintray.io/kong-brain-immunity`                    |
| `image.tag`                     | Kong-Collector Image tag                              | `1.1.0`                                                                                  |
| `imagePullSecrets`              | Specify Image pull secrets                            | `- name: bintray-kong-brain-immunity` (does not add image pull secrets to deployed pods) |
| `kongAdmin.protocol`                 | Protocol on which Kong Admin API can be found            | `http`                                                                     |
| `kongAdmin.host`                 | Hostname where Kong Admin API can be found            | `my-kong-kong-admin`                                                                     |
| `kongAdmin.servicePort`                 | Port where Kong Admin API can be found                | `8001`                                                                                   |
| `kongAdmin.token`                 | Token/Password used for making requests to Kong Admin API                | `my-token`                                                                                   |
| `collector.service.port`                      | TCP port on which the Collector service is exposed | `5000`                                                                                  |
| `collector.containerPort`                      | TCP port on which Collector listens for kong traffic | `5000`                                                                                  |
| `collector.nodePort`                      | Port to access Collector API from outside the cluster | `31555`                                                                                  |
| `postgresql.enabled` | Deploy PostgreSQL server as subchart                            | `true`                                                                              |
| `postgresql.host` | PostgreSQL hostname for connecting to existing instance                              | `collector-database`                                                                              |
| `postgresql.postgresqlDatabase` | PostgreSQL dataname name                              | `collector`                                                                              |
| `postgresql.service.port`       | PostgreSQL port                                       | `5432`                                                                                   |
| `postgresql.postgresqlUsername` | PostgreSQL user name                                  | `collector`                                                                              |
| `postgresql.postgresqlPassword` | PostgreSQL password                                   | `collector`                                                                              |
| `redis.enabled` | Deploy Redis server as subchart                            | `true`                                                                              |
| `redis.host` | Redis hostname for connecting to existing instance                              | `collector-database`                                                                              |
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

## Seeking help

If you run into an issue, bug or have a question, please reach out to the Kong
community via [Kong Nation](https://discuss.konghq.com).
Please do not open issues in [this](https://github.com/helm/charts) repository
as the maintainers will not be notified and won't respond.
