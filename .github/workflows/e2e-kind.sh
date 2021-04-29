#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly CT_VERSION=v3.0.0-rc.1
readonly KIND_VERSION=v0.7.0
readonly CLUSTER_NAME=chart-testing
readonly K8S_VERSION=v1.17.0

# Docker image paths
readonly KONG_EE_REGISTRY=kong
readonly KONG_EE_IMAGE=kong-gateway
readonly KONG_IMMUNITY_REGISTRY=kong
readonly KONG_IMMUNITY_IMAGE=immunity

# Update these on bump
readonly APP_IMAGE_TAG=4.1.0
readonly KONG_IMAGE_TAG=2.2-alpine
readonly KONG_HELM_TAG=1.10.0

run_ct_container() {
    echo 'Running ct container...'
    echo "ci: $CT_CONFIG"
    echo "kong-ee: $KONG_IMAGE_TAG"
    echo "collector: $APP_IMAGE_TAG"
    docker run --rm --interactive --detach --network host --name ct \
        --volume "$(pwd)/$CT_CONFIG:/etc/ct/ct.yaml" \
        --volume "$(pwd)/kong-values.yaml:/etc/ct/kong-values.yaml" \
        --volume "$(pwd):/workdir" \
        --workdir /workdir \
        "quay.io/helmpack/chart-testing:$CT_VERSION" \
        cat
    echo
}

cleanup() {
    echo 'Removing ct container...'
    docker kill ct > /dev/null 2>&1

    echo 'Done!'
}

docker_exec() {
    docker exec --interactive ct "$@"
}

create_kind_cluster() {
    echo 'Installing kind...'

    curl -sSLo kind "https://github.com/kubernetes-sigs/kind/releases/download/$KIND_VERSION/kind-linux-amd64"
    chmod +x kind
    sudo mv kind /usr/local/bin/kind
    kind create cluster --name "$CLUSTER_NAME" --image "kindest/node:$K8S_VERSION" --wait 60s

    echo 'Copying kubeconfig to container...'
    sudo cat $HOME/.kube/config
    sudo ls -al $HOME/.kube
    docker cp $HOME/.kube ct:/root/.kube

    docker_exec kubectl cluster-info
    echo

    docker_exec kubectl get nodes
    echo

    echo 'Cluster ready!'
    echo
}

install_prereqs() {
    docker pull $KONG_EE_REGISTRY/$KONG_EE_IMAGE:$KONG_IMAGE_TAG
    kind load --name $CLUSTER_NAME docker-image $KONG_EE_REGISTRY/$KONG_EE_IMAGE:$KONG_IMAGE_TAG
    docker pull $KONG_IMMUNITY_REGISTRY/$KONG_IMMUNITY_IMAGE:$APP_IMAGE_TAG
    kind load --name $CLUSTER_NAME docker-image $KONG_IMMUNITY_REGISTRY/$KONG_IMMUNITY_IMAGE:$APP_IMAGE_TAG
    docker_exec kubectl create namespace cool-namespace
    echo $KONG_LICENSE_DATA >> license \
    && docker_exec kubectl create secret generic kong-enterprise-license \
        --from-file=./license --namespace=cool-namespace \
    && rm -rf license
    docker_exec kubectl create secret generic kong-admin-token-secret \
        --from-literal=kong-admin-token=handyshake --namespace=cool-namespace
    docker_exec helm repo add kong https://charts.konghq.com
    docker_exec helm repo add bitnami https://charts.bitnami.com/bitnami
    docker_exec helm repo update
    docker_exec helm install my-kong kong/kong --version $KONG_HELM_TAG -f "/etc/ct/kong-values.yaml" \
        -n cool-namespace
}

install_charts() {
    docker_exec kubectl get namespace
    docker_exec kubectl get services --namespace=cool-namespace
    docker_exec kubectl get pods --namespace=cool-namespace
    docker_exec ct install --config /etc/ct/ct.yaml --namespace cool-namespace
    echo
}

main() {
    run_ct_container
    trap cleanup EXIT

    create_kind_cluster
    install_prereqs
    install_charts
}

main