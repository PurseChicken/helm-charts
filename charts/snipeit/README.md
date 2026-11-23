# Snipe-IT

[Snipe-IT](https://snipeitapp.com) is a free open source IT asset/license management system.

## Generate config.snipeit.key

Snipe-IT needs an application key, which you have to set *before deploying* this chart. It must be a base64 key:
```
$ docker run --rm snipe/snipe-it php artisan key:generate --show
```
Then pass the output with `--set config.snipeit.key=...`, or put it in the secret named by `config.externalSecrets`
as `APP_KEY`.

## TL;DR;
```
$ helm repo add pursechicken https://pursechicken.github.io/helm-charts
$ helm install snipeit pursechicken/snipeit \
    --set config.snipeit.url=https://snipeit.example.com \
    --set config.snipeit.key="base64:....." \
    --set config.mysql.externalDatabase.host=mysql.example.com \
    --set config.mysql.externalDatabase.pass=...
```

Or use the chart as a dependency of your own chart:

```yaml
dependencies:
- name: snipeit
  version: "4.1.0"
  repository: "https://pursechicken.github.io/helm-charts"
```

## Introduction

This chart bootstraps a [Snipe-IT](https://github.com/grokability/snipe-it)
deployment on a [Kubernetes](https://kubernetes.io) cluster using the
[Helm](https://helm.sh) package manager.

Snipe-IT needs a MySQL or MariaDB database. Run one separately (a managed database, an operator, or another chart)
and point `config.mysql.externalDatabase` or `config.externalSecrets` at it. The bundled MySQL (`mysql.enabled`) is
deprecated and is removed in chart 5.0.0; see [Bundled MySQL (deprecated)](#bundled-mysql-deprecated).

The default image is Snipe-IT v8.0.4. To run Snipe-IT 8.8.4, set `image.tag: v8.8.4` and read
[Running behind an ingress or load balancer](#running-behind-an-ingress-or-load-balancer-snipe-it-88).

## Installing the Chart

To install the chart with the release name `my-release`:

```
$ helm install my-release pursechicken/snipeit \
    --set config.snipeit.url=https://snipeit.example.com \
    --set config.snipeit.key="base64:....." \
    --set config.mysql.externalDatabase.host=mysql.example.com \
    --set config.mysql.externalDatabase.pass=...
```

Set `config.snipeit.url` to the address people open Snipe-IT on: Snipe-IT builds its links from it, and from 8.8.4 on
it only answers requests for that host.

The command deploys Snipe-IT on the Kubernetes cluster in the default
configuration. The [configuration](#configuration) section lists the parameters
that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall the `my-release` deployment:

```
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

## Configuration

The following table lists the configurable parameters of the Snipe-IT chart
and their default values.

| Parameter                            | Description                                                   | Default                        |
|--------------------------------------|---------------------------------------------------------------|--------------------------------|
| `nameOverride`                       | Override the chart name                                       | `""`                           |
| `fullnameOverride`                   | Override the full resource name                               | `""`                           |
| `config.mysql.externalDatabase.user` | Database user                                                 | `snipeit`                      |
| `config.mysql.externalDatabase.pass` | Database password                                             | `""`                           |
| `config.mysql.externalDatabase.name` | Database name                                                 | `db-snipeit`                   |
| `config.mysql.externalDatabase.host` | Hostname/IP of the MySQL or MariaDB server                    | `mysql`                        |
| `config.mysql.externalDatabase.port` | Port of the MySQL or MariaDB server                           | `3306`                         |
| `config.snipeit.env`                 | Snipe-IT Environment to use                                   | `production`                   |
| `config.snipeit.debug`               | Whether to enable Debug mode or not                           | `false`                        |
| `config.snipeit.url`                 | URL of Snipe-IT (APP_URL). Its host is sent as the probes' Host header | `http://example.local` |
| `config.snipeit.key`                 | Application-Key for Snipe-IT                                  | `""`                           |
| `config.snipeit.timezone`            | Snipe-IT Timezone                                             | `America/Los_Angeles`          |
| `config.snipeit.locale`              | Snipe-IT Locale                                               | `en`                           |
| `config.snipeit.envConfig`           | Extra environment values (stored in the chart's Secret)       | `{}`                           |
| `config.externalSecrets`             | Existing secret with the database settings and APP_KEY; replaces `config.mysql.externalDatabase.*` and `config.snipeit.key` | `""` |
| `configData.enabled`                 | Run the config-data init container (disable on storage that rejects chown) | `true`        |
| `configData.owner`                   | Owner the sessions directory is chowned to (`apache:root` for `-alpine` tags) | `10000:0`  |
| `configData.image`                   | Image of the config-data init container                       | The Snipe-IT image             |
| `configData.securityContext`         | Override securityContext for config-data init                 | `{}`                           |
| `image.repository`                   | Image Repository                                              | `snipe/snipe-it`               |
| `image.tag`                          | Image Tag                                                     | Chart `appVersion`             |
| `image.pullPolicy`                   | Image Pull Policy                                             | `IfNotPresent`                 |
| `imagePullSecrets`                   | Image Pull Secrets                                            | `[]`                           |
| `ingress.enabled`                    | Whether or not to enable Ingress                              | `true`                         |
| `ingress.className`                  | Ingress Class Name                                            | `""`                           |
| `ingress.annotations`                | Custom Ingress Annotations                                    | `{}`                           |
| `ingress.path`                       | Root Path for the Ingress Resource                            | `/`                            |
| `ingress.pathType`                   | Path type for the Ingress Resource                            | `ImplementationSpecific`       |
| `ingress.hosts`                      | URL where Snipe-IT will be accessed                           | `example.local`                |
| `ingress.tls`                        | Configuration for SecretName and TLS-Hosts                    | `[]`                           |
| `mysql.enabled`                      | Deploy the bundled MySQL (deprecated, removed in 5.0.0)       | `false`                        |
| `mysql.mysqlUser`                    | MySQL User to create                                          | `snipeit`                      |
| `mysql.mysqlPassword`                | MySQL Password for the User                                   | `snipeit`                      |
| `mysql.mysqlDatabase`                | Name of MySQL Database to create                              | `db-snipeit`                   |
| `mysql.persistence.enabled`          | Whether or not to enable Persistence                          | `true`                         |
| `mysql.persistence.storageClass`     | StorageClass for MySQL Deployment persistence                 | `""`                           |
| `mysql.persistence.accessMode`       | Access Mode of PV                                             | `ReadWriteOnce`                |
| `mysql.persistence.size`             | Size of the PV                                                | `8Gi`                          |
| `mysql-backup.enabled`               | Deploy the bundled mysql-backup (deprecated, removed in 5.0.0) | `false`                       |
| `persistence.enabled`                | Whether or not Snipe-IT Data should be persisted              | `true`                         |
| `persistence.annotations`            | Annotations for the PVC                                       | `{}`                           |
| `persistence.accessMode`             | Access Mode of the PVC                                        | `ReadWriteOnce`                |
| `persistence.existingClaim`          | Use an existing PVC instead of creating one                   | `""`                           |
| `persistence.storageClass`           | StorageClass of the PVC (`-` for none)                        | `nil`                          |
| `persistence.size`                   | Size of the persistent Snipe-IT Volume                        | `2Gi`                          |
| `persistence.www.mountPath`          | Mount path of the Snipe-IT data directory                     | `/var/lib/snipeit`             |
| `persistence.www.subPath`            | Sub path in the volume for the data directory                 | `www`                          |
| `persistence.sessions.mountPath`     | Mount path of the PHP sessions directory                      | `/var/www/html/storage/framework/sessions` |
| `persistence.sessions.subPath`       | Sub path in the volume for sessions                           | `sessions`                     |
| `replicaCount`                       | Number of Snipe-IT Pods to run                                | `1`                            |
| `deploymentStrategy`                 | Deployment strategy                                           | `{ "type": "RollingUpdate" }`  |
| `revisionHistoryLimit`               | The number of old ReplicaSets to keep to allow rollback       | `0`                            |
| `podDisruptionBudget.enabled`        | Create a PodDisruptionBudget                                  | `false`                        |
| `podDisruptionBudget.maxUnavailable` | maxUnavailable of the PodDisruptionBudget                     | `1`                            |
| `securityContext`                    | SnipeIT Pod(s) securityContext                                | `{}`                           |
| `serviceAccount.create`              | Create kubernetes service account                             | `false`                        |
| `serviceAccount.name`                | Change the name of the service account                        | Full name if `create`, else `default` |
| `serviceAccount.annotations`         | Add any annotations to the created service account            | `{}`                           |
| `service.type`                       | Type of service to create                                     | `ClusterIP`                    |
| `service.annotations`                | Annotations of service to create                              | `{}`                           |
| `service.clusterIP`                  | Internal cluster service IP                                   | `nil`                          |
| `service.loadBalancerIP`             | IP address to assign to load balancer (if supported)          | `nil`                          |
| `service.loadBalancerSourceRanges`   | list of IP CIDRs allowed access to lb (if supported)          | `[]`                           |
| `service.externalIPs`                | service external IP addresses                                 | `[]`                           |
| `resources`                          | CPU/Memory resource requests/limits                           | `{}`                           |
| `startupProbe`                       | Startup probe for the Snipe-IT container                      | `httpGet /health`, up to 10 min |
| `livenessProbe`                      | Liveness probe for the Snipe-IT container                     | `httpGet /robots.txt` every 15s |
| `readinessProbe`                     | Readiness probe for the Snipe-IT container                    | `httpGet /health` every 15s    |
| `nodeSelector`                       | Node labels for pod assignment                                | `{}`                           |
| `tolerations`                        | Toleration labels for pod assignment                          | `[]`                           |
| `affinity`                           | Affinity settings for pod assignment                          | `{}`                           |
| `extraContainers`                    | Add additional containers to deploy                           | `[]`                           |
| `extraAnnotations`                   | Extra Annotations added to the SnipeIT Pod(s)                 | `{}`                           |
| `extraManifests`                     | Add additional manifests to deploy                            | `[]`                           |
| `extraVolumeMounts`                  | Additional volumeMounts to the container                      | `[]`                           |
| `extraVolumes`                       | Additional volumes to the pod                                 | `[]`                           |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```
$ helm install my-release \
  --set service.type=LoadBalancer \
    pursechicken/snipeit
```

The above command sets the service type LoadBalancer.

Alternatively, a YAML file that specifies the values for the above parameters
can be provided while installing the chart. For example,

```
$ helm install my-release -f values.yaml pursechicken/snipeit
```

> **Tip**: You can use the default [values.yaml](values.yaml)

### Persistence

The Snipe-IT image stores persistence under `/var/lib/snipeit` path of the
container. A dynamically managed Persistent Volume Claim is used to keep the
data across deployments, by default. This is known to work in GCE, AWS, and
minikube.
Alternatively, a previously configured Persistent Volume Claim can be used.

With the default `ReadWriteOnce` access mode every replica has to run on the node that has the volume
attached. A rolling update or a second replica that is scheduled on another node will fail to start
(`Multi-Attach error`). Run more than one replica only with `ReadWriteMany` storage, or use
`deploymentStrategy: {type: Recreate}` with a single replica.

#### Existing PersistentVolumeClaim

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart

```bash
$ helm install my-release \
    --set persistence.existingClaim=PVC_NAME \
    pursechicken/snipeit
```

### Custom Environment Values

Snipe-IT uses `.env` file to store configuration variables. This includes
Email configuration, advanced configurations like proxy, login throttling etc.
To override the default values for these variables, use the `config.snipeit.envConfig`.

```yaml
config:
  snipeit:
    envConfig:
      MAIL_HOST: smtp.example.com
      MAIL_PORT: 25
      MAIL_USERNAME: username
      MAIL_PASSWORD: password
      MAIL_FROM_ADDR: snipeit@example.com
      MAIL_FROM_NAME: Snipe-IT
```

### External Secrets

To use manually created secrets for the database configuration, use the `config.externalSecrets`.
You can create a secret with the following command:

```bash
kubectl create secret generic my-db-secret \
  --from-literal=MYSQL_USER=<your_mysql_user> \
  --from-literal=MYSQL_DATABASE=<your_mysql_database> \
  --from-literal=MYSQL_PASSWORD=<your_mysql_password> \
  --from-literal=MYSQL_PORT_3306_TCP_ADDR=<your_mysql_host> \
  --from-literal=MYSQL_PORT_3306_TCP_PORT=<your_mysql_port> \
  --from-literal=APP_KEY=<your_app_key>
```

## Running behind an ingress or load balancer (Snipe-IT 8.8+)

Two Snipe-IT changes matter when it runs behind a reverse proxy:

- **Host header check (8.8.4+).** Snipe-IT only answers requests whose `Host` header is the host of `APP_URL`
  (or a subdomain of it), and returns `400 Bad Request` to everything else. Static files such as `/robots.txt`
  are served by Apache and skip the check. The chart's probes send the host from `config.snipeit.url`
  automatically. Health checks run by your ingress or load balancer must send that host too. For example,
  set `host` on a GKE `HealthCheckPolicy`, or the matching setting of your ingress controller. Every hostname
  users reach Snipe-IT on must match `APP_URL`; redirect other hostnames at the proxy instead.
- **Trusted proxies (8.8.0+).** Snipe-IT no longer trusts any proxy or `X-Forwarded-*` header unless you opt in.
  When TLS terminates at the proxy, set `APP_TRUSTED_PROXIES` to the addresses the proxy connects from, so
  Snipe-IT sees the original scheme and client IP:
  - an ingress controller running in the cluster (ingress-nginx, Traefik): `PRIVATE_SUBNETS`
  - a Google Cloud global external Application Load Balancer (GKE Ingress, or a GKE Gateway with a global external
    class): `35.191.0.0/16,130.211.0.0/22`. This load balancer also adds its own IP address to `X-Forwarded-For`;
    add that address too if Snipe-IT should log the client's IP rather than the load balancer's.

```yaml
config:
  snipeit:
    url: https://snipeit.example.com
    envConfig:
      APP_FORCE_TLS: true
      APP_TRUSTED_PROXIES: "PRIVATE_SUBNETS"
      APP_TRUSTED_HEADERS: "HEADER_X_FORWARDED_FOR,HEADER_X_FORWARDED_PROTO"
```

`APP_TRUSTED_HEADERS` is meant to limit which `X-Forwarded-*` headers Snipe-IT trusts, but in Snipe-IT 8.8.4 it
has no effect: Laravel's own proxy middleware still runs after Snipe-IT's and trusts its default set
(`X-Forwarded-For`, `-Host`, `-Port`, `-Proto`, `-Prefix`) from any address in `APP_TRUSTED_PROXIES`. Keep
`APP_TRUSTED_PROXIES` as narrow as you can.

## Bundled MySQL (deprecated)

The `mysql` and `mysql-backup` dependencies come from the t3n chart repository and are pinned to old versions:
`mysql` 1.0.0 (2021) deploys MySQL 5.7, which is end of life, and `mysql-backup` 1.0.1 dates from 2019. Chart 5.0.0
removes both, and refuses to render while `mysql.enabled` or `mysql-backup.enabled` is true: upgrading without them
would delete the MySQL Deployment and its PersistentVolumeClaim, and with the default reclaim policy the disk with
your data.

To move off the bundled MySQL while on this chart version:

1. Dump the database from the running MySQL. Its Deployment is `<release>-mysql`, or just `<release>` if the release
   name already contains `mysql`:
   ```bash
   kubectl exec deploy/<release>-mysql -- sh -c \
     'mysqldump --single-transaction --no-tablespaces --default-character-set=utf8mb4 \
       -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' > snipeit.sql
   ```
2. Restore `snipeit.sql` into a MySQL 8 or MariaDB server that you run separately (a managed database, an operator,
   or another chart).
3. Point `config.mysql.externalDatabase` (or the secret named by `config.externalSecrets`) at that server, set
   `mysql.enabled: false` (and `mysql-backup.enabled: false` if you use it), and upgrade. The upgrade deletes the old
   MySQL Deployment and its volume, so keep the dump until Snipe-IT runs on the new database.

Back up the new database with its own tooling, or with Snipe-IT's built-in backups.

## Upgrading to 4.1.0

- **Upgrade with your values file (`-f`) or `--reset-then-reuse-values`,** not `--reuse-values`. `--reuse-values`
  keeps the previous chart's defaults, which have no probe settings, so the pods would run without probes.
- **Probes.** A startup probe was added, and the liveness probe checks `/robots.txt` instead of `/health`. Review any
  probe overrides you had.
- **PodDisruptionBudget** settings moved to `podDisruptionBudget.*`. The old template never rendered for
  `replicaCount` above 0.
- **Init container** uses the Snipe-IT image instead of `busybox`. Set `configData.image` to keep another image.

## Additional manifests
It is possible to add additional manifests into a deployment, to extend the chart. One of the reason is to deploy a manifest specific to a cloud provider ( BackendConfig on GKE for example ).

```yaml
extraManifests:
  - apiVersion: cloud.google.com/v1beta1
    kind: BackendConfig
    metadata:
      name: "{{ .Release.Name }}-test"
    spec:
      securityPolicy:
        name: "gcp-cloud-armor-policy-test"
```

## Extra Containers
It is possible to add additional containers into a deployment, to extend the chart. One of the reasons is to deploy a sidecar container like CloudSQLProxy.
Extra containers are listed before the Snipe-IT container, so a sidecar with a `postStart` hook (like `cloud-sql-proxy wait` below) is ready before Snipe-IT starts.
The pod's `kubectl.kubernetes.io/default-container` annotation points `kubectl logs`/`exec` at the Snipe-IT container.

```yaml
extraContainers:
  - name: cloud-sql-proxy
    image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.15.3
    command:
      - /cloud-sql-proxy
    args:
      - my-project:my-region:my-instance
      - --port=3306
      - --health-check
      - "--http-address=0.0.0.0"
    ports:
      - containerPort: 3306
    startupProbe:
      httpGet:
          path: /startup
          port: 9090
      periodSeconds: 1
      timeoutSeconds: 5
    livenessProbe:
      httpGet:
          path: /liveness
          port: 9090
      initialDelaySeconds: 0
      periodSeconds: 60
      timeoutSeconds: 30
      failureThreshold: 5
    securityContext:
      runAsNonRoot: true
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
    lifecycle:
      postStart:
        exec:
          command: ["/cloud-sql-proxy", "wait"]
```

## Original Chart Credit
Special thanks to t3n for the original chart that this is built off of. It seemed they stopped merging in PR's and/or addressing issues, so this was born.