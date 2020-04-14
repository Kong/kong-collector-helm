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
  [chart](https://github.com/Kong/charts/tree/master/charts/kong#kong-enterprise) [Version compatibility](docs/version-compatibility.md)

## Installing the Chart

*This guide assumes you have a Kong Admin API reachable at
   my-kong-kong-admin:8001, for instructions to set up Kong Enterprise Edition
   with helm see the section titled "Tested with the following environment"*

To install the chart with the release name `my-release`:


1. Add Kong Brain and Immunity registry secret and RBAC user token secret

```console
$ kubectl create secret docker-registry kong-brain-immunity-docker \
    --docker-server=kong-docker-kong-brain-immunity-base.bintray.io \
    --docker-username=<your-bintray-username@kong> \
    --docker-password=<your-bintray-api-key>
secret/kong-brain-immunity-docker created

$ kubectl create secret generic kong-admin-token-secret --from-literal=kong-admin-token=my-token
secret/kong-admin-token-secret created
```

2. Set up collector, overriding Kong Admin host, servicePort and token to ensure
   Kong Admin API is reachable by collector, this will allow collector to push
   swagger specs to Kong and can be confirmed by visiting the /status endpoint
   of collector

```console
$ helm dep update ./charts/kong-collectorapi
$ helm install my-release ./charts/kong-collectorapi --set kongAdmin.host=my-kong-kong-admin
```

```console
$ curl -s <KONG_ADMIN_API_HOST>:<KONG_ADMIN_PORT>/<WORKSPACE>/collector/status kong-admin-token:my-token
```

3. Add a "Collector Plugin" using the Kong Admin API, this will allow Kong to
connect to collector.

```console
$ curl -s -X POST <KONG_ADMIN_API_HOST>:<KONG_ADMIN_PORT>/<WORKSPACE>/plugins \
  -d name=collector \
  -d config.http_endpoint=http://<COLLECTOR_HOST>:<SERVICE_PORT>
```

4. Check that collector is reachable by Kong Admin API

```console
$ curl -s <KONG_ADMIN_API_HOST>:<KONG_ADMIN_PORT>/<WORKSPACE>/collector/alerts kong-admin-token:my-token
```

5. Ensure your Kong Manager is reachable and has the Immunity feature flag set

```console
KONG_ADMIN_GUI_FLAGS={"IMMUNITY_ENABLED":true}
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
| `kongAdmin.existingSecret`                 | Name of existing secret to use for Kong Admin API Token/Password               | `nil`                                                                                   |
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

1. Start local kubernetes cluster and create all four required secrets
   (kong-enterprise-license, kong-enterprise-edition-docker,
   kong-brain-immunity-docker, kong-admin-token-secret)

```console
$ minikube start --vm-driver hyperkit --memory='6144mb' --cpus=4
$ helm repo add kong https://charts.konghq.com
$ helm repo update
```

2. Install both kong and collector charts then `open http://$(minikube
   ip):32002`

```console
$ helm install my-kong kong/kong --version 1.3.0 -f kong-values.yaml --set env.admin_api_uri=$(minikube ip):32001
$ helm install my-release ./charts/kong-collectorapi --set kongAdmin.host=my-kong-kong-admin
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
