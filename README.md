# PurseChicken Helm Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This repository contains a collection of [Helm](https://helm.sh) charts for deploying various applications and infrastructure components.

## Available Charts

### [cnrm-chart](./charts/cnrm-chart/)

Deploy Google Cloud Projects and Infrastructure using GCP's [Config Connector](https://cloud.google.com/config-connector/docs/overview). This chart enables Infrastructure as Code (IaC) deployment of GCP resources, allowing you to manage your entire cloud infrastructure through Kubernetes manifests.

**Key Features:**
- Project creation and management
- VPC networks, firewalls, and peering
- GKE clusters and node pools
- Cloud SQL instances
- IAM service accounts and policies
- DNS zones and records
- Monitoring, logging, and security policies

[View Chart README](./charts/cnrm-chart/README.md)

### [gateway-api-chart](./charts/gateway-api-chart/)

Deploy Gateway API resources for GKE, including Service Exports, HTTP Routes, and Gateways. Includes support for GCP-specific resources like Gateway Policy, Backend Policy, and Cloud Armor WAF via Config Connector.

**Key Features:**
- Gateway and HTTPRoute resources
- ServiceExport for multi-cluster services
- GCP Gateway Policy and Backend Policy
- Cloud Armor security policies
- Health check policies

[View Chart README](./charts/gateway-api-chart/README.md)

### [snipeit](./charts/snipeit/)

Deploy [Snipe-IT](https://snipeitapp.com), a free open source IT asset/license management system on Kubernetes.

**Key Features:**
- Full Snipe-IT deployment
- Optional MySQL database
- Persistent storage
- Ingress support
- External secrets integration

[View Chart README](./charts/snipeit/README.md)

## Usage

[Helm](https://helm.sh) must be installed and initialized to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
$ helm repo add pursechicken https://pursechicken.github.io/helm-charts
$ helm repo update
```

Then you can install any of the charts:

```console
$ helm install my-release pursechicken/<chart-name> -f my-values.yaml
```

Replace `<chart-name>` with one of:
- `cnrm-chart`
- `gateway-api-chart`
- `snipeit`

## Contributing

Contributions are welcome! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:
- How to report issues
- How to suggest enhancements
- Development guidelines and standards
- Pull request process

## Support

For issues, questions, or contributions:
- Open an issue on the [GitHub repository](https://github.com/pursechicken/helm-charts)
- Review individual chart READMEs for chart-specific documentation
- Check the [Contributing Guide](CONTRIBUTING.md) for development guidelines