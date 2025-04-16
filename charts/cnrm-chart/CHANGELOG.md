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

## [v1.2.9] - 2025-04-16

### Fixed

- Proper fix for Lowercase record type in metadata name

## [v1.2.8] - 2025-04-16

### Fixed

- Lowercase record type in metadata name

## [v1.2.7] - 2025-04-16

### Changed

- Changed DNS Record metadata to include type to prevent duplicate resources.

## [v1.2.6] - 2025-03-31

### Fixed

- Fixed DNS Record issue with _domainkey in metadata name.

## [v1.2.5] - 2025-03-20

### Fixed

- Fixed issue with hard-coded backup setting for SQL Instance depending on if MYSQL or POSTGRES

## [v1.2.4] - 2025-01-30

### Added

- Underscore TXT record example in values

### Fixed

- DNS Zone and Record metadata
- Dates in Changelog

## [v1.2.3] - 2025-01-21

### Fixed

- Removed project from values file.

### Removed

- v1.2.2 due to error with left over project in values

## [v1.2.2] - 2025-01-21 DO NOT USE

### Added

- Ability to set Firewall Enforcement Order on VPC
- Ability to set description on VPC

### Updated

- No longer hard code some VPC values. Specifically: "autoCreateSubnetworks", "mtu" and "routingMode".

## [v1.2.1] - 2024-10-18

### Added

- Ability to enable DeletionProtection for SQLInstance.
- Ability to set Deletion Policy on SQL Database resources.
- Automatically generate DNSManagedZone metadata name from name supplied in values.
- Cloud IDS Endpoint resources can now be specified.
- Ability to specify custom Annotations on the following resources:
    - VPC Network
    - Kubernetes Clusters
    - Kubernetes Node Pools
    - IAM Service Accounts
    - Cloud SQL Instances
    - Cloud IDS Endpoints

### Fixed

- Missing yaml extension on Compute Security Policy
- Spacing in ChangeLog
- "End" Templating

### Removed

- DNSManagedZone metadata name

### Updated

- Added Cloud IDS as supported resource in ReadMe.
- Improved ReadMe verbiage.

## [v1.2.0] - 2023-11-7

### Added

- Added the ability to specify locationPreference for SQL Instance.

### Changed

- SQL Users metadata name is generated using project name and instance name instead of just project name.
- SQL Database metadata name is generated using project name and instance name instead of just project name.

### Removed

- SQL Users name key no longer needed.

## [v1.1.5] - 2023-10-16

### Added

- Added the Ability to specify Query Insights Configuration

### Updated

- Updated ReadMe to include snippet about External Secrets.

## [v1.1.4] - 2023-09-13

### Added

- Added the ability to specify ipConfiguration on a SQL Instance.

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