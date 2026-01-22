# snipeit Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

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