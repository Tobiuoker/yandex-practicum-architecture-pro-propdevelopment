# Задание 7 — проверка безопасности Pod

## 1. Создать namespace

```bash
kubectl apply -f 01-create-namespace.yaml
```

Проверить, что включен PodSecurity `restricted`:

```bash
kubectl get namespace audit-zone --show-labels
```

Должна быть метка:

```text
pod-security.kubernetes.io/enforce=restricted
```

## 2. Проверить небезопасные манифесты

```bash
bash verify/verify-admission.sh
```

Все манифесты из `insecure-manifests/` должны быть отклонены, а `secure-manifests/` применены.

Проверяются:

- `privileged: true`;
- использование `hostPath`;
- запуск контейнера от root.

## 3. Установить OPA Gatekeeper

```bash
kubectl apply -f \
  https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.23.1/deploy/gatekeeper.yaml
```

Проверить:

```bash
kubectl get pods -n gatekeeper-system
```

Pod'ы Gatekeeper должны быть в состоянии `Running`.

## 4. Применить правила Gatekeeper

Сначала создать шаблоны правил:

```bash
kubectl apply -f gatekeeper/constraint-templates/
```

Затем включить ограничения:

```bash
kubectl apply -f gatekeeper/constraints/
```

Проверить:

```bash
kubectl get constrainttemplates
kubectl get constraints
```

Gatekeeper проверяет:

- `privileged: true` запрещен;
- `hostPath` запрещен;
- требуется `runAsNonRoot: true`;
- требуется `readOnlyRootFilesystem: true`.

## 5. Проверить безопасные манифесты

```bash
bash verify/validate-security.sh
```

Теперь они не проходят, т.к. добавилась еще одна проверка `readOnlyRootFilesystem: true`, которой нет в дефолтных проверках `podSecurity: restricted`. Добавляем в каждый `secure-manifest` еще `readOnlyRootFilesystem: true` и теперь они снова могут создаться.


При необходимости создать Pod'ы:

```bash
kubectl apply -f secure-manifests/
```

Проверить:

```bash
kubectl get pods -n audit-zone
```