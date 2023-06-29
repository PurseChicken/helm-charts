# cnrm-chart Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

<!-- ## [vX.Y.Z] - UNRELEASED
### Highlights
### All Changes
- Added
- Updated
- Changed
- Fixed
- Deprecated
- Removed -->

## [v1.1.3] - 2023-06-28

### Fixed

- Changelog version match

## [v1.1.2] - 2023-06-28

### Changed

- Reverted chart-releaser back to v1.5.0

## [v1.1.1] - 2023-06-28

### Added

- Added the ability to use external-secrets operator to make secrets available in the cluster namespace. See 'externalSecrets' in the values file for comments.
- Added release-notes-file to chart-releaser config so that release notes show up on builds.

### Changed

- Modified MonitoringNotificationChannel to be able to use sensitiveLabels for labels that need values from a secret.
- chart-releaser to v1.6.0

## [v1.1.0] - 2023-06-14

### Added

- Added the configuration setting to not manage or create the GCP project. (createOrManageProject)
- Added ability to create Security Policies. (securityPolicy)

### Changed

- Added the ability to configure whether or not you want to keep resources when deleting. (allowResourceDeletion)

## [v1.0.10] - 2023-06-01

### Changed

- Changed hardcoded stackType to be specified in values (defaults to 'IPV4_ONLY') in ComputeSubnetwork (VPC subnet)
- stackType is omitted if setting purpose to 'INTERNAL_HTTPS_LOAD_BALANCER' or 'REGIONAL_MANAGED_PROXY'
## [v1.0.9] - 2023-06-01

### Added

- Added Purpose and Role to ComputeSubnetwork (VPC subnet)

## [v1.0.8] - 2023-05-16

### Added

- Added ability to configure cloud logging buckets (Org, Billing and Project levels)
## [v1.0.7] - 2023-04-10

### Changed

- Added more comments to values.yaml

## [v1.0.6] - 2023-04-10

### Added

- Removed bump config from helm

## [v1.0.5] - 2023-04-10

### Changed

- Added chart description
- Updated Chart Readme

## [v1.0.4] - 2023-04-10

### Changed

- Fixed some files and aligned versions.
- Added SkipBump Flag to bumpVersionAction

## [v1.0.2] - 2023-04-10

### Added

- Published helm repo using github pages \ releases

### Changed

- N/A


## [v1.0.0] - 2023-03-01

### Added

- Initial Version

### Changed

- N/A