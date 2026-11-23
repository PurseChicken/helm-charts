# snipeit Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

## [v5.0.0] - 2026-11-23

### Added

- `extraInitContainers`. An init container with `restartPolicy: Always` runs as a native sidecar that starts before
  Snipe-IT and stops after it; the README shows the Cloud SQL Auth Proxy set up this way.
- `lifecycle` for the Snipe-IT container (e.g. a `preStop` delay behind a load balancer) and
  `terminationGracePeriodSeconds`.
- README section on running MariaDB as its own Helm release in the cluster (CloudPirates MariaDB chart).
- NOTES warn when `ingress.hosts` or `ingress.tls` is set but `ingress.enabled` is false.

### Changed

- **Breaking:** `ingress.enabled` defaults to `false`. Set it to `true` explicitly to keep an Ingress.
- **Breaking:** default image is now Snipe-IT `v8.8.4` (appVersion). Its Host header check means load balancer and
  ingress health checks must send the `APP_URL` host. Upgrading runs database migrations; back up the database first.

### Removed

- **Breaking:** bundled `mysql` (t3n 1.0.0, MySQL 5.7) and `mysql-backup` (t3n 1.0.1) dependencies, and the `mysql.*`
  and `mysql-backup.*` values. Rendering fails while `mysql.enabled` or `mysql-backup.enabled` is true, so an upgrade
  can't delete the MySQL volume. See "Upgrading to 5.0.0" in the README for moving the data to an external database.
- **Breaking:** `networking.k8s.io/v1beta1` and `extensions/v1beta1` Ingress templates (Kubernetes before 1.19).

## [v4.1.0] - 2026-11-23

### Added

- Configurable `startupProbe`, `livenessProbe` and `readinessProbe` values. Setting `exec`, `tcpSocket` or `grpc` on a
  probe replaces its default `httpGet`.
- Default startup probe that gives the first boot (database migrations) up to 10 minutes before liveness applies.
- httpGet probes send the host of `config.snipeit.url` as their Host header unless they set one. Snipe-IT 8.8.4+
  returns 400 to any other Host.
- `podDisruptionBudget.enabled` / `podDisruptionBudget.maxUnavailable` (off by default).
- `configData.enabled` to skip the config-data init container on storage that rejects chown (e.g. AWS EFS).
- `configData.owner` for the owner the sessions directory is chowned to (`apache:root` for `-alpine` image tags).
- `kubectl.kubernetes.io/default-container` pod annotation so `kubectl logs`/`exec` target Snipe-IT rather than an
  extra container.
- Support for Snipe-IT 8.8.4 (set `image.tag`; the default image stays v8.0.4 until chart 5.0.0).
- README section on running Snipe-IT 8.8+ behind an ingress or load balancer.
- NOTES mention the 8.8.4 Host check and the 8.8.0 trusted-proxy default, warn when `replicaCount` > 1 on a
  ReadWriteOnce volume, and show a deprecation notice when the bundled MySQL is enabled.

### Changed

- Liveness probe checks `/robots.txt` (a static file served by Apache) instead of `/health`. `/health` queries the
  database, so liveness used to restart Snipe-IT during database outages or a restore. Readiness keeps `/health`.
- Probes use the named `http` port.
- config-data init container uses the Snipe-IT image by default instead of `busybox` (latest from Docker Hub), so pods
  pull one image.
- README defaults and Helm 3 commands corrected.

### Fixed

- PodDisruptionBudget: only rendered when `replicaCount` was 0, used the removed `policy/v1beta1` API and a selector
  that matched no pods.
- External database port was written to the Secret with literal quotes (`"3306"`).
- NOTES reported a missing Application Key when `config.externalSecrets` was set.

### Deprecated

- Bundled `mysql` (t3n 1.0.0, MySQL 5.7, end of life) and `mysql-backup` (t3n 1.0.1) dependencies. They are removed in
  5.0.0; see "Bundled MySQL (deprecated)" in the README for moving the data to an external database.

## [v4.0.2] - 2025-04-23

### Added

- Ability to create service account and add annotations.
- Deployment manifest reference to created service account
- serviceAccountName helper
- ReadMe configuration for new service account values spec.

### Fixed

- ReadMe cloud-sql-proxy spec

## [v4.0.1] - 2025-04-22

### Fixed

- Init container chown user/group reference

## [v4.0.0] - 2025-04-22

### Added

- Ability to specify a sidecar container. Added reference to this in values and in ReadMe.
- Ability to specify imagePullSecrets Addresses: https://github.com/t3n/helm-charts/pull/208
- Ability to change config-data (chown command) image if needed
- Ability to set pods securityContext. Also able to override for config-data init container. Addresses: https://github.com/t3n/helm-charts/pull/173

### Changed

- Snipeit App version updated to current build v8.0.4

### Fixed

- Init container proper command to chown sessions. Addresses https://github.com/t3n/helm-charts/issues/205
- ReadMe Formatting
- ReadMe Missing extraAnnotations in Configuration section
- Chart Formatting
- Wrong default value for mysql.enabled. Addresses: https://github.com/t3n/helm-charts/pull/196
- Quote Ingress hosts. Addresses: https://github.com/t3n/helm-charts/pull/191

### Removed

- Trailing Whitespace in template manifests
- Deployment manifest whitespace
- Secret manifest whitespace

## [v3.4.1] - 2025-04-22

### Added

- Initial Version ported from t3n
- This Changelog

### Changed

- N/A