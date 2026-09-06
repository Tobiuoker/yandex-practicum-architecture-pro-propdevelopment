#!/bin/bash

kubectl delete clusterrole viewer \
    configurator \
    security-reader \
    --ignore-not-found

kubectl create clusterrole viewer \
    --verb=get,list,watch \
    --resource=pods,services,configmaps,deployments.apps

kubectl create clusterrole configurator \
    --verb=get,list,watch,create,update,patch,delete \
    --resource=pods,services,configmaps,deployments.apps

kubectl create clusterrole security-reader \
    --verb=get,list,watch \
    --resource=pods,services,configmaps,secrets,deployments.apps

echo "Roles created successfully"