![Lint and Test Charts](https://github.com/Kong/kong-collector-helm/workflows/Lint%20and%20Test%20Charts/badge.svg)

# Kong-Collector

[Kong-Collector](https://konghq.com/products/kong-enterprise/kong-immunity) is
an application which enables the use of Kong Immunity.

Kong Immunity is an add-on to Kong Gateway, using
a Collector API and a Collector Plugin to communicate with Kong Gateway.

## Introduction

This chart bootstraps a
[Kong-Collector](https://docs.konghq.com/enterprise/latest/immunity/install-configure/)
deployment on a [Kubernetes](http://kubernetes.io) cluster using the
[Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.12+
- Kong Enterprise version 1.5+
  [chart](https://github.com/Kong/charts/tree/master/charts/kong#kong-enterprise)
  where the IMMUNITY_ENABLED variable has been set to true.
- A Kong workspace to enable traffic collection `<WORKSPACE>`
- Helm 3.1+

## Installing the Chart

To install the chart with the release name `my-release`:

1. When Kong, make sure to set the IMMUNITY_ENABLED to true.  This does have to be done on Kong installation, and it is necessary to see the Immunity page on Kong Manager.
```console
helm install kong/kong --version=$KONG_HELM_VERSION --set IMMUNITY_ENABLED=true
```

2. Add RBAC user token secret.

```console
$ kubectl create secret generic kong-admin-token-secret --from-literal=kong-admin-token=my-token
secret/kong-admin-token-secret created
```

3. Set up collector, overriding Kong Admin host, servicePort and token to ensure
   Kong Admin API is reachable by collector.
```console

$ helm install my-release ./charts/collector --set kongAdmin.host=my-kong-kong-admin
```

4. Check that collector-plugin is reachable by Kong Admin API, and that it isn't already enabled on target workspace
```console
$ curl -s http://kong:8001/<WORKSPACE>/collector/status kong-admin-token:my-token
```

5. If status returns "enabled" = false, add a "Collector Plugin" using the Kong Admin API, this will allow Kong to
connect to collector, this url should be reachable within kubernetes.

```console
$ curl -s -X POST http://kong:8001/<WORKSPACE>/plugins \
  -d name=collector \
  -d config.http_endpoint=http://my-release-collector:5000
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
| `image.repository`              | Kong-Collector Image repository                       | `kong/immunity`                    |

| `image.tag`                     | Kong-Collector Image tag                              | `4.1.0`                                                                                  |
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

### Testing with minikube

The following was tested on MacOS in minikube with the following configuration:

1. Start local kubernetes cluster and create license secret
```console
$echo $KONG_LICENSE_DATA >> license \
    && kubectl create secret generic kong-enterprise-license --from-file=./license \
    && rm -rf license
```

```console
$ minikube start --vm-driver hyperkit --memory='6144mb' --cpus=4
$ helm repo add kong https://charts.konghq.com
$ helm repo update
$ helm dependency update ./charts/collector
```

2. Install both kong and collector charts then `open http://$(minikube ip -n minikube):32002`

```console
$ helm install my-kong kong/kong --version 2.1.0 -f kong-values.yaml --set env.admin_api_uri=$(minikube ip -n minikube):32001

$ helm install my-release ./charts/collector --set kongAdmin.host=my-kong-kong-admin

$ kubectl wait --for=condition=complete job --all && helm test my-release
```

3. [OPTIONAL] Port forward some services so you can easily interact with your Kong and Collector services via localhost.  Each command line will need to be run in separate tabs.

```console
kubectl port-forward svc/my-kong-kong-admin 8001
kubectl port-forward svc/my-kong-kong-manager 8002
kubectl port-forward svc/my-release-kong-collectorapi 5000
```

4. Check to make sure collector is running well
```console
open http://localhost:5000/status
```
You should see this output in your browser:
```
{
  "immunity": {
    "available": true,
    "version": "4.1.0"
  },
  "kong_status": {
    "is_collector_plugin_bundled": true,
    "url": "http://my-kong-kong-admin:8001",
    "version": "2.2.1.3-enterprise-edition"
  }
}

```
The important thing to notice is that the section "kong_status" is not empty.  This signifies that both the kong service and collector service have been successfully installed and they can communicate with each other.

5. Create kong service and route then add a collector plugin pointing at the
   collector service hostname and port reachable within kubernetes.

```console
$ curl -s -X POST http://kong:8001/<WORKSPACE>/plugins \
  -d name=collector \
  -d config.flush_timeout=1 \
  -d config.http_endpoint=http://my-release-collector:5000
```

## Seeking help

If you run into an issue, bug or have a question, please reach out to the Kong
community via [Kong Nation](https://discuss.konghq.com).
Please do not open issues in [this](https://github.com/helm/charts) repository
as the maintainers will not be notified and won't respond.
