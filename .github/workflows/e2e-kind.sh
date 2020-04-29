#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly CT_VERSION=v3.0.0-rc.1
readonly KIND_VERSION=v0.7.0
readonly CLUSTER_NAME=chart-testing
readonly K8S_VERSION=v1.17.0

run_ct_container() {
    echo 'Running ct container...'
    docker run --rm --interactive --detach --network host --name ct \
        --volume "$(pwd)/ct.yaml:/etc/ct/ct.yaml" \
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
    echo "$BINTRAY_KEY" | docker login --username $BINTRAY_USER --password-stdin kong-docker-kong-enterprise-edition-docker.bintray.io
    echo "$BINTRAY_KEY" | docker login --username $BINTRAY_USER --password-stdin kong-docker-kong-brain-immunity-base.bintray.io
    docker pull kong-docker-kong-enterprise-edition-docker.bintray.io/kong-enterprise-edition:1.5.0.0-alpine
    kind load --name $CLUSTER_NAME docker-image kong-docker-kong-enterprise-edition-docker.bintray.io/kong-enterprise-edition:1.5.0.0-alpine
    docker pull kong-docker-kong-brain-immunity-base.bintray.io/kong-brain-immunity:2.0.1
    kind load --name $CLUSTER_NAME docker-image kong-docker-kong-brain-immunity-base.bintray.io/kong-brain-immunity:2.0.1
    docker_exec kubectl create namespace cool-namespace
    echo $KONG_LICENSE_DATA >> license \
    && docker_exec kubectl create secret generic kong-enterprise-license --from-file=./license --namespace=cool-namespace \
    && rm -rf license
    docker_exec kubectl create secret docker-registry kong-enterprise-edition-docker \
        --docker-server=kong-docker-kong-enterprise-edition-docker.bintray.io \
        --docker-username=$BINTRAY_USER \
        --docker-password=$BINTRAY_KEY --namespace=cool-namespace
    docker_exec kubectl create secret docker-registry kong-brain-immunity-docker \
        --docker-server=kong-docker-kong-brain-immunity-base.bintray.io \
        --docker-username=$BINTRAY_USER \
        --docker-password=$BINTRAY_KEY --namespace=cool-namespace
    docker_exec kubectl create secret generic kong-admin-token-secret \
        --from-literal=kong-admin-token=handyshake --namespace=cool-namespace
    docker_exec helm repo add kong https://charts.konghq.com
    docker_exec helm repo add bitnami https://charts.bitnami.com/bitnami
    docker_exec helm repo update
    docker_exec helm install my-kong kong/kong --version 1.5.0 -f "/etc/ct/kong-values.yaml" \
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