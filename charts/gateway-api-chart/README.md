# Gateway API Chart

This chart was created to help you deploy Gateway API resources such as a Service Export, HTTP Route and Gateway.

## Information

This chart was curated primarily for use in **GKE (Google Kubernetes Engine)**, so some of the resources like Gateway Policy and Backend Policy are specific to GCP. Additionally, the Cloud Armor WAF via Security Policy uses the Config Connector add-on.

**Primary Use Case**: This chart is designed to be used as a **dependency chart** in other Helm charts. For example, if you're deploying `argo-cd` which only supports Ingress, you can include this chart as a dependency to expose argo-cd via Gateway API instead. The chart will deploy all resources to the same namespace as the parent chart (`.Release.Namespace`).

**Note**: While designed as a dependency chart, this chart can also be installed **standalone** using `helm install`. When installed standalone, resources deploy to the namespace specified during installation (or `default` if not specified). See the [Installation](#installation) section for both installation methods.

**GKE-Specific Requirements**:
- **Policies must be in the same namespace as their targets**: `GCPBackendPolicy`, `HealthCheckPolicy`, and `GCPGatewayPolicy` must be deployed in the same namespace as the Service/ServiceImport/Gateway they target. This is automatically handled for dependency charts.
- **Gateway namespace**: Gateways can be in any namespace. For dependency charts, they typically deploy to the parent chart's namespace, but can be explicitly set for shared Gateways.
- **Cross-namespace routing**: HTTPRoutes can reference Gateways in different namespaces (use `gatewayNamespace` in HTTPRoute config).

**Contributions welcome!** PR's and Issues are appreciated.

## Prerequisites

- **Google Cloud (GCP)** - Required for Gateway Policy and Backend Policy
- **Config Connector add-on** - Required for Cloud Armor WAF (ComputeSecurityPolicy)
- **GKE Cluster** - This chart is optimized for Google Kubernetes Engine

## Supported Resources

- **Gateway** - Kubernetes Gateway API resource
- **HTTPRoute** - HTTP routing rules with support for redirects
- **Service** - Regular Kubernetes Service configuration (primary use case for dependency charts)
- **ServiceExport** - Multi-cluster service export for GKE (use for multi-cluster scenarios only)
- **HealthCheckPolicy** - GKE health check configuration
- **GCPGatewayPolicy** - GCP-specific gateway policies (SSL policies, global access)
- **GCPBackendPolicy** - Backend policies (timeouts, session affinity, connection draining)
- **ComputeSecurityPolicy** - Cloud Armor WAF policies (via Config Connector)

## When to Use `service` vs `serviceExport`

- **Use `service`** (recommended for most cases): When deploying as a dependency chart with regular Kubernetes Services (e.g., argo-cd, any standard Kubernetes application). Resources deploy to the parent chart's namespace.
- **Use `serviceExport`**: Only for multi-cluster scenarios where you need to export a service for cross-cluster access via ServiceImport.

## Cloud Armor WAF Features

This chart includes comprehensive support for Google Cloud Armor Web Application Firewall (WAF):

- **WAF Rule Waves** - WAF rules are grouped into "waves" to minimize rule quota usage:
  - **Wave 1** (Priority 5): Core injection attacks (SQLi, XSS, LFI, RCE, RFI)
  - **Wave 2** (Priority 10): Protocol and method-based attacks (Method Enforcement, Scanner Detection, Protocol Attack, PHP, Session Fixation)
  - **Wave 3** (Priority 15): Language-specific and vulnerability-based attacks (Java, NodeJS, CVE, JSON SQLi)
- **Rule Configuration** - Each WAF rule set supports:
  - Sensitivity levels (0-4)
  - Opt-out specific rule signatures
  - Opt-in specific rule signatures (with sensitivity 0)
  - Enable/disable individual rule sets without removing configuration
- **Rate Limiting** - Configurable rate-based bans or throttling
- **Adaptive Protection** - Optional DDoS protection
- **Custom Rules** - Add your own custom CEL expressions

For detailed WAF configuration options, see the [values.yaml](./values.yaml) file with comprehensive inline documentation.

## Installation

Add the Helm repository:

```console
$ helm repo add pursechicken https://pursechicken.github.io/helm-charts
$ helm repo update
```

### As a Chart Dependency (Recommended)

Add this chart as a dependency to your own chart:

```yaml
# Chart.yaml
dependencies:
- name: gateway-api-chart
  version: "1.1.4"  # Check for latest version
  repository: "https://pursechicken.github.io/helm-charts"
```

Then update dependencies:

```console
$ helm dep update
```

**When to use as a dependency:**
- Exposing an application that only supports Ingress (e.g., argo-cd, prometheus)
- Co-locating Gateway API resources with your application
- Ensuring resources deploy to the same namespace as your application
- Simplifying deployment by bundling everything together

### Direct Installation (Standalone)

You can also install this chart directly as a standalone deployment:

```console
# Install to a specific namespace
$ helm install my-gateway pursechicken/gateway-api-chart \
    --namespace my-namespace \
    --create-namespace \
    -f values.yaml

# Or install to default namespace
$ helm install my-gateway pursechicken/gateway-api-chart -f values.yaml
```

**When to use standalone installation:**
- Deploying Gateway API resources independently
- Managing Gateways, HTTPRoutes, and policies separately from application charts
- Testing and development scenarios
- Shared Gateways across multiple applications

## Configuration

Specify the values you want to use in your own values file. The included [values.yaml](./values.yaml) file contains comprehensive inline documentation with examples for all configuration options.

## Example Configuration

This chart includes comprehensive example configurations in the [`examples/`](./examples/) directory:

- **[01-basic-service.yaml](./examples/01-basic-service.yaml)** - Basic service configuration for dependency charts
- **[02-service-with-waf.yaml](./examples/02-service-with-waf.yaml)** - Service with Cloud Armor WAF security policies
- **[03-complete-gateway-setup.yaml](./examples/03-complete-gateway-setup.yaml)** - Complete Gateway API setup with Gateway, HTTPRoute, and Service
- **[04-multi-cluster-serviceexport.yaml](./examples/04-multi-cluster-serviceexport.yaml)** - Multi-cluster ServiceExport configuration

See the [Examples README](./examples/README.md) for detailed documentation on each example, use cases, and customization guidance.

### Quick Start Example

For a simple dependency chart use case:

```yaml
gateway-api-chart:
  service:
    - name: my-app-service
      healthCheck:
        type: HTTP
        httpHealthCheck:
          requestPath: "/healthz"
      backendPolicy:
        timeoutSec: 30
        logging:
          enabled: true
          sampleRate: 500000
```

## Key Features

### WAF Rule Management

- **Enable/Disable Rules**: Use the `enabled` flag on any WAF config to disable rules without removing configuration:
  ```yaml
  sqliConfig:
    enabled: false  # Disables SQLi rules but keeps config for easy re-enabling
  ```

- **Rule Tuning**: Each rule set supports sensitivity levels and opt-out/opt-in specific signatures
- **Wave Structure**: Rules are automatically grouped into waves to optimize rule quota usage

### Rate Limiting

Configure rate-based bans or throttling with flexible key selection (IP, headers, cookies, etc.)

### Health Checks

Configure custom health check policies for your services

## Documentation Links

- [GKE Gateway API Documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/gateway-resources)
- [Cloud Armor WAF Rules](https://cloud.google.com/armor/docs/waf-rules)
- [Cloud Armor Rate Limiting](https://cloud.google.com/armor/docs/rate-limiting-overview)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)