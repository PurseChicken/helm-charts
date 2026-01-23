# gateway-api-chart Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Added

- Added support for regular Kubernetes Services (via `service` section) in addition to ServiceExport, enabling dependency chart use cases for exposing standard Kubernetes applications via Gateway API
- Added examples directory with comprehensive example configurations for common use cases (basic service, WAF configuration, complete gateway setup, multi-cluster scenarios)
- Added support for advanced GCPBackendPolicy features: optional logging fields (`optionalMode`, `optionalFields`), traffic-based autoscaling (`maxRatePerEndpoint`), backend selection with custom metrics (`backends`), and Identity-Aware Proxy (`iap`) configuration

### Changed

- Refactored templates to use helper functions, significantly reducing code duplication and improving maintainability (backendpolicy.yaml, healthcheck.yaml, computesecuritypolicy.yaml)
- Enhanced Chart.yaml keywords for better discoverability (GKE, GCP, policy types, features)

## [v1.1.5] - 2026-01-23

### Added

- Added default description for ComputeSecurityPolicy (defaults to "Cloud Armor WAF policy for <service-name>" if not specified)
- Added `enabled` flag support for individual WAF rule configurations (sqliConfig, xssConfig, etc.) to allow disabling rules without removing config blocks
- Added comprehensive comments explaining WAF wave structure, priorities, and attack categories

### Changed

- Enhanced code readability and maintainability of `computesecuritypolicy.yaml` template
- Improved documentation in values.yaml for security policy configuration

## [1.1.4] - 2025-10-23

### Fixed

- Fixed issue with using enforceOnKeysConfigs. Must set enforceOnKey to empty value. See: https://github.com/GoogleCloudPlatform/k8s-config-connector/issues/1022

## [1.1.3] - 2025-10-23

### Added

- Ability to specify enforceOnKeys when rate limiting.

## [1.1.2] - 2025-09-11

### Added

- Ability to specify Cloud Armor (WAF) request throttling and/or bans.
- More Chart keywords

## [v1.1.1] - 2025-08-12

### Fixed

- Fixed healthcheck when type is TCP.

## [v1.1.0] - 2025-01-21

### Changed

- Changed to v1 gateway-api resources

## [v1.0.0] - 2025-01-07

### Added

- ReadMe
- Automatically deploy http redirect httpRoute if specified in Values
- Automatic deploy hostname redirect httpRoute if specified in Values

### Updated

- values.yaml documentation
- release version

### Changed

- httpRoute ability to specify gateway namespace

## [v0.0.0] - 2025-01-06

### Added

- Initial Version

### Changed

- N/A