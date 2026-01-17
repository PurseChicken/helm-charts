# cnrm-chart Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [v1.3.7] - 2026-01-17

- Fixed LoggingLogMetric annotations to exclude project-id (uses projectRef for project context)
- Fixed CloudIDSEndpoint annotations to exclude project-id (uses projectRef for project context)

## [v1.3.6] - 2026-01-17

- Removed resourceID from DNSRecordSet to prevent sync issues with existing DNS records

## [v1.3.5] - 2026-01-17

- Fixed values.yaml nodePool example: moved metadata, oauthScopes, and shieldedInstanceConfig inside nodeConfig block (correct nesting)
- Enhanced values.yaml documentation with section headers, improved comments, and better organization
- Added binaryAuthorization example to GKE cluster configuration
- Added ComputeRouterInterface and ComputeRouterPeer examples for BGP configuration
- Fixed typo in logging metric example (userAgent)
- Updated maintenance window duration to ISO 8601 format

## [v1.3.4] - 2026-01-17

### Changed

- Refactored deletion-policy annotation logic into dedicated helper function (cnrm-chart.deletionPolicy) for better code reusability

### Fixed

- Fixed ContainerCluster enableIntranodeVisibility to render explicit false value (previously only rendered when true)
- Fixed IAMPolicyMember annotations to exclude project-id (uses resourceRef for project context)
- Fixed IAMPolicy annotations to exclude project-id (uses resourceRef for project context)
- Fixed Service (API) annotations to exclude project-id (uses projectRef.name for project context)
- Fixed MonitoringMonitoredProject annotations to exclude project-id (uses metricsScope for project context)
- Fixed GKEHubFeature annotations to exclude project-id (uses projectRef.name for project context)

## [v1.3.3] - 2026-01-17

### Changed

- Updated GitHub Actions workflow to extract version-specific release notes for chart-releaser
- Updated bump-version.py script to handle CHANGELOG updates directly (avoiding bump2version multi-line config corruption)
- Updated bump-version.py with conventional commit keyword support (chore, docs, refactor, perf, test, build, ci)
- Updated bump-version.py with skip keywords support ([skip-bump], [no-bump])
- Updated bump-version.py with breaking change exclamation mark syntax support (feat!:, fix!:)
- Updated bump-version.py to properly write GitHub Actions outputs
- Updated actions/checkout from v5 to v6

### Fixed

- Fixed bumpversion configuration to prevent config file corruption
- Fixed CHANGELOG structure to follow Keep a Changelog standard with proper Unreleased section
- Fixed release notes not appearing in GitHub releases due to extraction issues

## [v1.3.2] - 2026-01-17

### Added

- Added `cnrm-chart.resourceName` helper to generate consistent, sanitized `projectName-resourceName` patterns
- Added `cnrm-chart.cnrmAnnotations` helper to standardize CNRM deletion-policy and project-id annotations
- Added `cnrm-chart.customAnnotations` helper to render user-defined custom annotations consistently
- Added ComputeRouterInterface support for BGP session establishment with VPN tunnels
- Added ComputeRouterPeer support for BGP peer configuration (advertised routes, BFD, MD5 auth)
- Added structured SQL ipConfiguration fields for SSL, private networking, and authorized networks
- Added GKE binaryAuthorization support for container image security enforcement
- Added ComputeSubnetwork flow logs support (aggregationInterval, flowSampling, metadata)
- Added ComputeSubnetwork privateIpGoogleAccess field for Private Google Access
- Added IAMPolicyMember conditional IAM support (title, description, expression)
- Added IAMServiceAccount displayName field for human-readable names
- Added CloudIDSEndpoint resourceID field for naming consistency

### Changed

- Refactored all templates to use `cnrm-chart.resourceName` helper for resource naming (20+ templates)
- All resource names now automatically sanitized to ensure Kubernetes compliance (lowercase, alphanumeric, hyphens)
- Refactored all resource references (networkRef, clusterRef, routerRef, etc.) to use naming helper for consistency
- Refactored all metadata annotations blocks to use `cnrm-chart.cnrmAnnotations` helper (net -185 lines of code)
- Refactored custom annotations rendering to use `cnrm-chart.customAnnotations` helper
- Improved GKE templates to use `{{- with }}` for nested objects (`management`, `nodeConfig`, `shieldedInstanceConfig`)
- Boolean fields in nested objects now render explicit values when parent is defined (e.g., `autoRepair: false`)
- Node pool tags now use captured variables to properly reference original node pool names within `with` blocks
- Consolidated Cloud VPN resources into single `cloudvpn.yaml` file (previously 4 separate files)
- Enhanced SQL ipConfiguration from basic `toYaml` to structured fields with proper resource references
- Updated ComputeAddress to support full networkRef spec (name, external, namespace)
- Updated ServiceNetworkingConnection to use naming helper for all resource references
- Added resourceID fields to DNS resources for consistency with Config Connector best practices
- Improved DNS template variable naming from generic ($name1, $name2) to descriptive ($dotsToHyphens, $dkimCleaned, $k8sName)
- IAMServiceAccount description field now optional (previously required)

### Fixed

- Fixed GKE ContainerCluster template to properly handle optional fields with `{{- if }}` checks
- Fixed ContainerNodePool template to prevent nil pointer errors when optional fields are not provided
- Fixed ContainerNodePool to use `{{- with .nodeConfig }}` for cleaner context switching and proper field access
- Fixed nodePool tags to always include default `<nodePoolName>-nodes` tag, with optional custom tags appended
- Fixed `shieldedInstanceConfig` path to correctly reference `.nodeConfig.shieldedInstanceConfig` within node pool context
- Added proper conditionals for: `releaseChannel`, `datapathProvider`, `enableIntranodeVisibility`, `enableShieldedNodes`, `verticalPodAutoscaling`, `management`, `nodeConfig`, `shieldedInstanceConfig`, `initialNodeCount`, `nodeLocation`, `maxPodsPerNode`

## [v1.3.1] - 2026-01-15

### Added

- Added Cloud VPN support with four new resource templates:
  - `computerouter.yaml` - Cloud Router for dynamic (BGP) routing
  - `computevpngateway.yaml` - HA VPN Gateway (Google Cloud side)
  - `computeexternalvpngateway.yaml` - External VPN Gateway (peer side definition)
  - `computevpntunnel.yaml` - VPN Tunnels connecting gateways
- Added comprehensive Cloud VPN configuration examples and documentation to `values.yaml`
- Added Cloud VPN resources to README supported resources list

## [v1.3.0] - 2026-01-15

### Added

- Added `_helpers.tpl` with `cnrm-chart.projectID` helper to consolidate project naming logic across all templates
- Added `cnrm-chart.validateProject` helper to prevent specifying both organizationId and projectFolderId
- Added `cnrm-chart.sanitizeName` helper to convert strings to valid Kubernetes resource names (lowercase, special chars to hyphens)
- Added `cnrm-chart.sanitizeEmail` helper to handle email addresses in resource names (for Cloud SQL IAM users)
- Added comprehensive documentation comments to all helper functions explaining inputs, outputs, and usage

### Changed

- Changed all templates to use `cnrm-chart.projectID` helper for consistent project name/ID resolution
- Changed CloudIDSEndpoint projectRef to use `name` reference instead of `external` for proper Kubernetes resource tracking

### Fixed

- Fixed SQLUser metadata name generation to properly handle dots, underscores, plus signs, and @ symbols in resourceID (e.g., service accounts and email addresses)
- Fixed SQLDatabase metadata name generation to sanitize uppercase letters and special characters
- Fixed IAM resource names (IAMServiceAccount, IAMPolicyMember, IAMPolicy) to sanitize uppercase letters and special characters
- Fixed LoggingLogMetric names to sanitize uppercase letters and special characters
- Fixed API Service names to sanitize dots and special characters (e.g., `container.googleapis.com`)
- Fixed MonitoringNotificationChannel labels field to be conditional, preventing errors when labels are not defined

## [v1.2.20] - 2025-11-13

### Fixed

- Fixed LoggingLogMetric metadata \ name when using underscores.

### Changed

- Changed LoggingLogMetric description to be quoted.

## [v1.2.19] - 2025-11-13

### Added

- Added new logging spec for LoggingLogMetric. See values file for example under logging.

### Changed

- Changed logging spec from a list of lists to maps of lists

## [v1.2.18] - 2025-10-29

### Updated

- Values file documentation about queryInsights

### Added

- Added replicaConfiguration.failoverTarget: false when using a Postgres SQLInstance set as READ_REPLICA_INSTANCE See [Here](https://github.com/GoogleCloudPlatform/k8s-config-connector/issues/5502)

## [v1.2.17] - 2025-10-27

### Fixed

- Fixed issue with SQLInstance updating at every sync interval due to nuances in backupConfiguration spec. See [Here](https://github.com/GoogleCloudPlatform/k8s-config-connector/issues/5502)

## [v1.2.16] - 2025-10-20

### Added

- Added the ability to specify additional SQLInstance parameters. More specifically, those that allow you to setup a Replica to a master instance.

## [v1.2.15] - 2025-09-10

### Fixed

- Only apply DNS fix when DNSRecord type is TXT.

## [v1.2.14] - 2025-09-10

### Fixed

- Escape rrdatas quotes per DNSRecord documentation.

## [v1.2.13] - 2025-09-10

### Fixed

- Issue with DNS records. Use single quote not double.

## [v1.2.12] - 2025-09-10

### Fixed

- Issue with DNS records getting quoted between strings due to using toYaml.

## [v1.2.11] - 2025-08-21

## Added

- Added ability to specify SQL Instance backup retention settings

## Updated

- Updated values comments to reference SQL Instance backup retention settings

## [v1.2.10] - 2025-05-22

### Updated

- Updated External-Secrets manifests to v1 from v1beta1

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