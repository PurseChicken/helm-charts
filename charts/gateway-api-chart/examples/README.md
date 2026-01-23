# Gateway API Chart Examples

This directory contains example values files demonstrating different deployment scenarios using the gateway-api-chart. Each example showcases specific patterns and use cases.

## Values Structure

Examples are written for **direct/standalone use** and work with `helm template` and `helm install` as-is.

**When used as a dependency chart:** Nest the entire example under `gateway-api-chart:` in your parent chart's values:

```yaml
# In your parent chart's values.yaml
gateway-api-chart:
  service:        # or gateway:, httpRoute:, serviceExport: as in the example
    - name: my-app-service
      ...
```

---

## Example Files

### 1. Basic Service Configuration (`01-basic-service.yaml`)

**Use Case:** Simple dependency chart setup for exposing a regular Kubernetes Service

**Features:**
- Regular Kubernetes Service (not ServiceImport)
- Basic health check configuration
- Simple backend policy with timeout and logging
- Minimal configuration for quick setup

**When to Use:**
- Dependency chart deployments (e.g., argo-cd, prometheus)
- Services that only need basic Gateway API exposure
- Quick prototypes and testing
- Learning the chart patterns

**Key Patterns Demonstrated:**
- Using the `service` section (primary use case)
- Basic health check configuration
- Simple backend policy settings
- Resources deploy to `Release.Namespace`

---

### 2. Service with Cloud Armor WAF (`02-service-with-waf.yaml`)

**Use Case:** Production services requiring web application firewall protection

**Features:**
- Cloud Armor WAF security policy
- All three WAF rule waves (injection, protocol, language-specific)
- Rate limiting with multiple key types
- Custom rule opt-outs for fine-tuning

**When to Use:**
- Production API endpoints
- Services exposed to the internet
- Applications requiring security protection
- Compliance requirements

**Key Patterns Demonstrated:**
- WAF rule wave configuration
- Sensitivity levels and opt-out rules
- Rate limiting with `enforceOnKeyConfigs`
- Security policy enable/disable patterns

**Prerequisites:**
- Config Connector add-on enabled on GKE cluster
- GCP project ID configured

---

### 3. Complete Gateway Setup (`03-complete-gateway-setup.yaml`)

**Use Case:** Full Gateway API deployment with TLS termination and routing

**Features:**
- Gateway with HTTP and HTTPS listeners
- HTTPRoute with automatic HTTP to HTTPS redirect
- Response header modification filters
- Gateway policy with SSL policy
- Service with session affinity

**When to Use:**
- Complete Gateway API deployments
- Applications requiring TLS termination
- Production environments with full routing control
- Services needing custom response headers

**Key Patterns Demonstrated:**
- Gateway configuration with multiple listeners
- HTTPRoute with redirects and filters
- Gateway policy configuration
- Service backend policy with session affinity
- Cross-resource references (HTTPRoute → Service)

---

### 4. Multi-Cluster ServiceExport (`04-multi-cluster-serviceexport.yaml`)

**Use Case:** Multi-cluster scenarios with cross-cluster service access

**Features:**
- ServiceExport for multi-cluster access
- ServiceImport target configuration
- Complete WAF and rate limiting setup
- Health checks and backend policies

**When to Use:**
- Multi-cluster GKE deployments
- Cross-cluster service access
- Service mesh or multi-cluster architectures
- Regional redundancy requirements

**Key Patterns Demonstrated:**
- ServiceExport configuration
- ServiceImport target references (group: net.gke.io)
- Multi-cluster namespace handling
- Complete security policy setup

**Prerequisites:**
- Multi-cluster GKE setup
- ServiceImport resources created by GKE
- Cross-cluster networking configured

---

## Common Patterns Across Examples

### Resource Naming
All examples follow consistent naming:
- Service names: Use descriptive names matching your application
- Gateway names: Typically `{app-name}-gateway`
- HTTPRoute names: Typically `{app-name}-route`
- Policy names: Auto-generated as `{service-name}-{policy-type}`

### Namespace Handling
- **Dependency charts**: Resources deploy to `Release.Namespace` (parent chart's namespace)
- **ServiceExport**: Resources must be in same namespace as ServiceImport
- **Service**: Resources must be in same namespace as the Service
- **Gateway**: Can be in any namespace (use `namespace` field for shared Gateways)

### Health Checks
All examples show HTTP health checks, but you can use:
- `HTTP` - Standard HTTP health checks
- `HTTPS` - HTTPS health checks
- `TCP` - TCP health checks
- `GRPC` - gRPC health checks
- `HTTP2` - HTTP/2 health checks

### Backend Policies
Common backend policy patterns:
- **Timeouts**: `timeoutSec` for request timeouts
- **Session Affinity**: `GENERATED_COOKIE` or `CLIENT_IP`
- **Connection Draining**: Graceful shutdown support
- **Logging**: Access logging with sample rates
- **IAP**: Identity-Aware Proxy configuration (not shown in examples)

### Security Policies
WAF configuration patterns:
- **Enable/Disable**: Use `enabled: false` to disable without removing config
- **Sensitivity**: Levels 0-4 (lower = more strict)
- **Opt-out Rules**: Disable specific rule signatures
- **Opt-in Rules**: Enable specific rules (requires sensitivity: 0)
- **Rate Limiting**: Configure bans or throttling

## Testing Examples

Examples work directly with `helm template` and `helm install`:

```bash
# From the chart directory (charts/gateway-api-chart)
helm template test-release . -f examples/01-basic-service.yaml
helm template test-release . -f examples/02-service-with-waf.yaml
helm template test-release . -f examples/03-complete-gateway-setup.yaml
helm template test-release . -f examples/04-multi-cluster-serviceexport.yaml
```

## Customization

When adapting these examples:

1. **Replace placeholder values:**
   - Service names
   - Gateway class names
   - Hostnames and domains
   - GCP project IDs
   - Certificate names

2. **Adjust configuration:**
   - Timeout values
   - Health check paths
   - Rate limiting thresholds
   - WAF sensitivity levels

3. **Modify security settings:**
   - WAF rule opt-outs
   - Rate limiting keys
   - SSL policies
   - IAP configuration

4. **Update network configuration:**
   - Gateway classes (global vs regional)
   - Listener ports and protocols
   - TargetRef namespaces

## Best Practices

1. **Start Simple:** Begin with example 1 and add complexity as needed
2. **Use Service Section:** Prefer `service` over `serviceExport` for single-cluster deployments
3. **Test First:** Use `helm template` to validate before deploying
4. **Review Generated Manifests:** Check the output before applying
5. **Enable WAF for Production:** Use example 2 as a starting point for production services
6. **Configure Health Checks:** Always set up health checks for production workloads
7. **Use Rate Limiting:** Protect your services with rate limiting
8. **Monitor Logs:** Enable logging to track access and issues

## When to Use `service` vs `serviceExport`

- **Use `service`** (examples 1-3): 
  - Single-cluster deployments
  - Dependency chart use cases
  - Regular Kubernetes Services
  - Most common scenario

- **Use `serviceExport`** (example 4):
  - Multi-cluster deployments only
  - Cross-cluster service access
  - ServiceImport resources
  - Advanced multi-cluster architectures

## Additional Resources

- [Chart README](../README.md) - Full chart documentation
- [Values File](../values.yaml) - Complete values reference with inline documentation
- [GKE Gateway API Documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/gateway-resources)
- [Cloud Armor WAF Rules](https://cloud.google.com/armor/docs/waf-rules)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)
