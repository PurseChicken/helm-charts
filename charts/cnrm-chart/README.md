# Config Connector Chart

This chart helps you deploy Google Cloud Projects and Infrastructure using GCP's [Config Connector](https://cloud.google.com/config-connector/docs/overview) addon.

## Overview

The chart enables Infrastructure as Code (IaC) deployment of GCP resources, allowing you to manage your entire cloud infrastructure through Kubernetes manifests. This integrates seamlessly with CI/CD pipelines (e.g., ArgoCD, Flux) for automated infrastructure deployment.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Examples](#examples)
- [Supported Resources](#currently-supported-resources)
- [Configuration](#configuration)
- [Important Notes](#important-notes)

## Intent

This chart evolved from specific organizational use cases. While it covers the majority of common infrastructure needs, it does not represent all resources or resource options available in Config Connector. Contributions via PRs and Issues are welcome!

## Prerequisites

Before using this chart, ensure you have:

1. **Config Connector installed and running**
   - An existing Kubernetes cluster with Config Connector installed, OR
   - A working Config Connector instance that can deploy resources

2. **Required IAM Permissions**
   - The Config Connector service account must have **Project Creator** IAM permissions on the GCP Organization where projects and resources will be deployed
   - This allows the source Config Connector instance to create and manage GCP projects and infrastructure

3. **External Secrets Operator (Optional)**
   - This chart supports secrets via the [external-secrets operator](https://external-secrets.io/latest/)
   - If using external secrets, ensure the operator is installed and configured correctly

## Architecture

<img src="images/cnrmDesign.png" alt="Config Connector Architecture Diagram">

> **Note:** The diagram may not be visible in packaged charts. See the repository for the full documentation.

## Currently Supported Resources

- Projects
- API's
- VPC Networks
- VPC Network Peering
- Firewall Rules
- Shared VPC (Host and Service Projects)
- Kubernetes Clusters
- Kubernetes Node Pools
- IAM Service Accounts
- IAM Policies
- Compute Addresses
- Service Networking Connections
- Cloud DNS
- gkeHub (Fleet)
- SSL Policies
- Cloud Monitoring
- Cloud SQL
- Logging Buckets
- Security Policies
- Cloud IDS
- Cloud VPN (Compute Router, VPN Gateway, External VPN Gateway, VPN Tunnel)

## Quick Start

1. **Add the Helm repository:**
   ```console
   $ helm repo add pursechicken https://pursechicken.github.io/helm-charts
   $ helm repo update
   ```

2. **Install the chart:**
   ```console
   $ helm install my-infrastructure pursechicken/cnrm-chart -f my-values.yaml
   ```

## Usage

### As a Chart Dependency

Use the chart as a dependency in your own chart:

```yaml
# Chart.yaml
dependencies:
- name: cnrm-chart
  version: "1.3.11"  # Use the latest version
  repository: "https://pursechicken.github.io/helm-charts"
```

Then update dependencies:

```console
$ helm dep update
```

### Configuration

Specify your configuration in a values file. The included [values.yaml](./values.yaml) contains comprehensive documentation with comments explaining each option.

**Key configuration areas:**
- Project settings (name, ID, organization, billing)
- VPC networks and subnets
- GKE clusters and node pools
- Cloud SQL instances
- IAM service accounts and policies
- DNS zones and records
- Monitoring and logging
- Security policies

See the [Examples](#examples) section for ready-to-use configurations.

## Examples

The chart includes example values files demonstrating different deployment scenarios:

- **[Simple Development Environment](./examples/01-simple-dev-environment.yaml)** - Minimal setup for development and testing
- **[Production Multi-Region](./examples/02-production-multi-region.yaml)** - Production setup with high availability across regions
- **[Shared VPC Service Project](./examples/03-shared-vpc-service-project.yaml)** - Service project using Shared VPC from a host project
- **[Complete Infrastructure](./examples/04-complete-infrastructure.yaml)** - Comprehensive reference implementation with all major features

See the [examples README](./examples/README.md) for detailed documentation on each example, use cases, and patterns demonstrated.

### Testing Examples

Validate example configurations before deploying:

```console
$ helm template my-release . -f examples/01-simple-dev-environment.yaml
```

## Configuration

The [values.yaml](./values.yaml) file contains all configurable options with detailed comments. Key sections include:

- **Project Configuration** - Project creation, organization, billing
- **VPC Networks** - Network and subnet configuration
- **GKE Clusters** - Kubernetes cluster and node pool settings
- **Cloud SQL** - Database instance configuration
- **IAM** - Service accounts and policy bindings
- **DNS** - Managed zones and record sets
- **Monitoring & Logging** - Alert policies and log buckets
- **Security** - Firewall rules, security policies, SSL policies

## Important Notes

### Resource Coverage

- Not all Config Connector resources and options are available in this chart
- Resources are added based on organizational needs
- PRs and feature requests are welcome

### Deployment Scope

- The chart assumes you are deploying projects and resources **external** to the project where Config Connector is running
- Resources are managed by Config Connector in the target project(s)

### Deletion Policy

- **By default**, resources use the `"abandon"` deletion policy for safety
- This means deleting resources from Config Connector **does not delete them in GCP**
- You can enable deletion by setting `allowResourceDeletion: true` in your values
- ⚠️ **CAUTION**: Enabling deletion means resources will be permanently deleted in GCP when removed from Config Connector

### Testing & Compatibility

- The chart has been tested with Config Connector running in a GCP Kubernetes cluster with Workload Identity
- It may work with other Config Connector deployments, but the service account must have proper permissions
- The most important requirement is that the Config Connector service account has the necessary IAM permissions

## Upgrading

When upgrading the chart:

1. Review the [CHANGELOG.md](./CHANGELOG.md) for breaking changes
2. Test the upgrade in a non-production environment first
3. Backup your values file before upgrading
4. Use `helm upgrade` with your values file:

   ```console
   $ helm upgrade my-infrastructure pursechicken/cnrm-chart -f my-values.yaml
   ```

## Uninstalling

To uninstall the chart:

```console
$ helm uninstall my-infrastructure
```

**Important:** Due to the default `"abandon"` deletion policy, GCP resources will **not** be automatically deleted. You must manually delete them in the GCP Console or via `gcloud` CLI if you want to remove the infrastructure.

If you have `allowResourceDeletion: true` enabled, resources will be deleted when the Helm release is removed.

## Contributing

Contributions are welcome! Please:

- Open an issue to discuss major changes
- Submit PRs for new resources or features
- Follow existing code patterns and conventions
- Update documentation as needed

## Support

For issues, questions, or contributions:
- Open an issue on the [GitHub repository](https://github.com/pursechicken/helm-charts)
- Review the [examples](./examples/README.md) for common patterns
- Check the [values.yaml](./values.yaml) for configuration options