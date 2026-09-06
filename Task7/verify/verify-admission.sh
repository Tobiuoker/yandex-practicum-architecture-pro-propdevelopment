#!/bin/bash

for file in insecure-manifests/*.yaml; do
  echo "Проверяем $file"

  if kubectl apply --dry-run=server -f "$file"; then
    echo "ERROR: манифест был разрешен"
  else
    echo "OK: манифест заблокирован"
  fi

  echo
done


for file in secure-manifests/*.yaml; do
  echo "Проверяем $file"

  if kubectl apply --dry-run=server -f "$file"; then
    echo "OK: манифест был разрешен"
  else
    echo "ERROR: манифест заблокирован"
  fi

  echo
done
