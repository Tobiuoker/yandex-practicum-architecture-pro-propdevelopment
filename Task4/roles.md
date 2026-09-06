# Защита доступа к кластеру Kubernetes

## Роли и полномочия

| Роль | Группа пользователей | Полномочия |
|---|---|---|
| `viewer` | `support` | Только просмотр ресурсов Kubernetes: Pods, Deployments, Services и ConfigMaps |
| `configurator` | `devops` | Просмотр, создание, изменение и удаление Pods, Deployments, Services и ConfigMaps |
| `security-reader` | `security` | Просмотр ресурсов Kubernetes, включая секреты |

### Соответствие пользователей группам

| Пользователь | Группа | Роль |
|---|---|---|
| `support-user` | `support` | `viewer` |
| `devops-user` | `devops` | `configurator` |
| `security-user` | `security` | `security-reader` |

Такое разделение позволяет разграничить доступ в соответствии с обязанностями сотрудников:

- сотрудники поддержки могут только просматривать состояние ресурсов;
- DevOps-инженеры могут настраивать и изменять ресурсы кластера;
- сотрудники информационной безопасности могут просматривать ресурсы, включая секреты.

При этом группы `support` и `devops` не имеют доступа к секретам.

---

## Проверка доступов пользователей

Создаем пользователей, роли и биндим юзеров к ролям:

```bash
bash create_users.sh
bash create_roles.sh
bash bind_users.sh
```

Пользователи добавлены в общий kubeconfig, поэтому отдельные kubeconfig-файлы для проверки не нужны.

Проверить конкретное действие можно с помощью команды:

```bash
kubectl auth can-i <действие> <ресурс> --user=<пользователь>
```

Например, для пользователя поддержки:

```bash
kubectl auth can-i get pods --user=support-user
# yes

kubectl auth can-i delete deployment --user=support-user
# no

kubectl auth can-i get secrets --user=support-user
# no
```

Для DevOps:

```bash
kubectl auth can-i update deployment --user=devops-user
# yes

kubectl auth can-i get secrets --user=devops-user
# no
```

Для сотрудника информационной безопасности:

```bash
kubectl auth can-i get secrets --user=security-user
# yes

kubectl auth can-i delete secrets --user=security-user
# no
```

Посмотреть список всех доступных действий пользователя можно так:

```bash
kubectl auth can-i --list --user=support-user
```

---

## Переключение между пользователями

Чтобы выполнять обычные команды `kubectl` от имени конкретного пользователя, нужно перейти в его контекст:

Переключение:

```bash
kubectl config use-context support
```

После этого команды выполняются от имени `support-user`:

```bash
kubectl auth whoami
kubectl auth can-i get pods
kubectl auth can-i get secrets
```

Вернуться к административному контексту Minikube:

```bash
kubectl config use-context minikube
```
