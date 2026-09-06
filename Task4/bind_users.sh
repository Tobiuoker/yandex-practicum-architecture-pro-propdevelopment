#!/bin/bash

kubectl delete clusterrolebinding support-viewer-binding \
    devops-configurator-binding \
    security-reader-binding \
    --ignore-not-found

kubectl create clusterrolebinding support-viewer-binding \
    --clusterrole=viewer \
    --group=support

kubectl create clusterrolebinding devops-configurator-binding \
    --clusterrole=configurator \
    --group=devops

kubectl create clusterrolebinding security-reader-binding \
    --clusterrole=security-reader \
    --group=security

echo "Role bindings created successfully"