# Gateway API Chart

This chart was created to help you deploy Gateway API resources such as a Service Export, HTTP Route and Gateway.

## Information

This chart was curated primarily for use in GKE, so some of the resources like Gateway Policy and Backend Policy are specific to GCP. Additionally, the Cloud Armor WAF via Security Policy uses the Config Connector add-on.

**Contributions welcome!** PR's and Issues are appreciated.

## Prerequisites

- **Google Cloud (GCP)** - Required for Gateway Policy and Backend Policy
- **Config Connector add-on** - Required for Cloud Armor WAF (ComputeSecurityPolicy)
- **GKE Cluster** - This chart is optimized for Google Kubernetes Engine

## Supported Resources

- **Gateway** - Kubernetes Gateway API resource
- **HTTPRoute** - HTTP routing rules with support for redirects
- **ServiceExport** - Multi-cluster service export for GKE
- **HealthCheckPolicy** - GKE health check configuration
- **GCPGatewayPolicy** - GCP-specific gateway policies (SSL policies, global access)
- **GCPBackendPolicy** - Backend policies (timeouts, session affinity, connection draining)
- **ComputeSecurityPolicy** - Cloud Armor WAF policies (via Config Connector)

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

### As a Chart Dependency

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

### Direct Installation

You can also install directly:

```console
$ helm install my-gateway pursechicken/gateway-api-chart -f values.yaml
```

## Configuration

Specify the values you want to use in your own values file. The included [values.yaml](./values.yaml) file contains comprehensive inline documentation with examples for all configuration options.

## Example Configuration

Below is a comprehensive example showing common configuration patterns:

```yaml
gateway-api-chart:
  gateway:
    - name: some-app-gw
      issuer:
        type: cluster-issuer
        name: cluster-issuer-name
      gatewayClassName: gke-l7-global-external-managed-mc
      listeners:
        - name: http
          hostname: someapp.my.domain
          port: 80
          protocol: HTTP
          allowedRoutes:
            kinds:
              - kind: HTTPRoute
        - name: https
          hostname: someapp.my.domain
          port: 443
          protocol: HTTPS
          allowedRoutes:
            kinds:
            - kind: HTTPRoute
          tls:
            mode: Terminate
            certificateRefs:
              - name: some-app-cert
      gatewayPolicy:
        sslPolicy: modern-policy

  httpRoute:
    - name: some-app-route
      gatewayName: some-app-gw
      redirectHTTP:
        httpListenerName: http
      rules:
        - backendRefs:
          - group: net.gke.io
            kind: ServiceImport
            name: some-app-service
            port: 80
          filters:
            - type: ResponseHeaderModifier
              responseHeaderModifier:
                add:
                  - name: Strict-Transport-Security
                    value: "max-age=31536000; includeSubDomains"

  serviceExport:
    - name: some-app-service
      # Health check configuration
      healthCheck:
        type: HTTP
        httpHealthCheck:
          requestPath: "/healthz"
      backendPolicy:
        # Cloud Armor WAF Security Policy
        securityPolicy:
          enabled: true
          preview: false
          project: my-gcp-project
          # Optional: Custom description (defaults to "Cloud Armor WAF policy for <service-name>")
          # description: "Production WAF policy for API endpoints"
          
          # Wave 1: Core injection attacks
          sqliConfig:
            sensitivity: 1
            optOutRules:
              - "owasp-crs-v030301-id942190-sqli"
              - "owasp-crs-v030301-id942270-sqli"
          xssConfig:
            optOutRules:
              - "owasp-crs-v030301-id941380-xss"
          lfiConfig:
            enabled: true
          rceConfig:
            optOutRules:
              - "owasp-crs-v030301-id932200-rce"
          rfiConfig:
            enabled: true
          
          # Wave 2: Protocol and method-based attacks
          methodConfig:
            optOutRules:
              - "owasp-crs-v030301-id911100-methodenforcement"
          scannerConfig:
            enabled: true
          protocolConfig:
            enabled: true
          phpConfig:
            enabled: true
          sessionConfig:
            enabled: true
          
          # Wave 3: Language-specific and vulnerability-based attacks
          javaConfig:
            enabled: true
          nodejsConfig:
            enabled: true
          cveConfig:
            enabled: true
          jsonsqliConfig:
            optOutRules:
              - "owasp-crs-id942550-sqli"
          
          # Rate limiting configuration
          rateLimitConfig:
            action: "rate_based_ban"
            preview: false
            banDurationSec: 60
            exceedAction: deny(429)
            requests: 500
            interval: 60
            enforceOnKeyConfigs:
              - keyType: IP
              - keyType: HTTP_HEADER
                keyName: "User-Agent"
        
        # Access logging
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