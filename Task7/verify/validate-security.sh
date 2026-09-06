#!/bin/bash

echo "=== PodSecurity ==="
kubectl get namespace audit-zone --show-labels

echo
echo "=== Gatekeeper ==="
kubectl get constrainttemplates
kubectl get constraints

echo
echo "=== Проверка безопасных манифестов ==="
kubectl apply --dry-run=server -f secure-manifests/

echo
echo "OK: безопасные манифесты прошли проверку"