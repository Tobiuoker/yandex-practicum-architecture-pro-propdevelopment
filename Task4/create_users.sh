#!/bin/bash

MINIKUBE_HOME="${MINIKUBE_HOME:-$HOME/.minikube}"
CA_CERT="$MINIKUBE_HOME/ca.crt"
CA_KEY="$MINIKUBE_HOME/ca.key"

mkdir -p users

create_user() {
    USER=$1
    GROUP=$2

    echo "Creating user: $USER, group: $GROUP"

    openssl genrsa -out "users/$USER.key" 2048

    openssl req \
        -new \
        -key "users/$USER.key" \
        -out "users/$USER.csr" \
        -subj "/CN=$USER/O=$GROUP"

    openssl x509 \
        -req \
        -in "users/$USER.csr" \
        -CA "$CA_CERT" \
        -CAkey "$CA_KEY" \
        -CAcreateserial \
        -out "users/$USER.crt" \
        -days 365 \
        -sha256

    kubectl config set-credentials "$USER" \
        --client-certificate="users/$USER.crt" \
        --client-key="users/$USER.key" \
        --embed-certs=true

    kubectl config set-context "$USER@minikube" \
        --cluster=minikube \
        --user="$USER"
}

create_user "support-user" "support"
create_user "devops-user" "devops"
create_user "security-user" "security"

echo "Users created successfully"