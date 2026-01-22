# CNRM Chart Examples

This directory contains example values files demonstrating different deployment scenarios using the cnrm-chart. Each example showcases specific patterns and use cases.

## Example Files

### 1. Simple Development Environment (`01-simple-dev-environment.yaml`)

**Use Case:** Quick setup for development and testing

**Features:**
- Single region deployment (us-central1)
- Basic VPC network with one subnet
- Single GKE cluster with minimal configuration
- Basic firewall rules
- Cost-optimized node pool (e2-medium)

**When to Use:**
- Development environments
- Testing and experimentation
- Learning the chart patterns
- Quick prototypes

**Key Patterns Demonstrated:**
- Basic VPC network and subnet configuration
- Simple GKE cluster setup
- Basic firewall rules
- Secondary IP ranges for GKE

---

### 2. Production Multi-Region Deployment (`02-production-multi-region.yaml`)

**Use Case:** Production environment with high availability

**Features:**
- Multi-region VPC network (us-central1, us-east1)
- Multiple GKE clusters across regions
- Production-grade security (Shielded Nodes, Binary Authorization)
- Comprehensive monitoring and logging
- Cost management enabled
- GKE Hub (Fleet) configuration for multi-cluster management

**When to Use:**
- Production workloads requiring high availability
- Multi-region deployments
- Environments requiring enhanced security
- Applications needing regional redundancy

**Key Patterns Demonstrated:**
- Multi-region network configuration
- Multiple GKE clusters
- Production security settings
- Monitoring and alerting setup
- GKE Hub/Fleet integration
- Custom annotations for resource tagging

---

### 3. Shared VPC Service Project (`03-shared-vpc-service-project.yaml`)

**Use Case:** Service project that uses Shared VPC from a host project

**Features:**
- Attaches to existing Shared VPC host project
- Creates GKE cluster using shared network
- Cloud SQL with private IP on shared VPC
- Firewall rules on shared network
- IAM service accounts

**When to Use:**
- Organizations using Shared VPC architecture
- Service projects that need to use centralized networking
- Multi-project environments
- When network management is centralized

**Key Patterns Demonstrated:**
- Shared VPC configuration (`sharedVpc.attachToHostProject`)
- Using `sharedVpc` object in cluster configuration
- Network references for shared VPC resources
- Cross-project resource references

**Prerequisites:**
- Host project must exist and have Shared VPC enabled
- Host project must grant necessary permissions to service project

---

### 4. Complete Infrastructure (`04-complete-infrastructure.yaml`)

**Use Case:** Comprehensive infrastructure with all major features

**Features:**
- Multiple VPC networks with peering
- Multiple GKE clusters
- Cloud SQL with read replicas
- DNS zones and records
- Static IP addresses
- Service networking connections
- IAM service accounts and policies
- Security policies (WAF, SSL)
- Monitoring and logging
- Log-based metrics

**When to Use:**
- Reference implementation
- Complex infrastructure requirements
- Learning all chart capabilities
- Production environments with diverse needs

**Key Patterns Demonstrated:**
- VPC peering configuration
- Static IP addresses (external and internal)
- Service networking connections
- Cloud SQL with read replicas
- DNS zone and record management
- Security policies
- Comprehensive IAM setup
- Advanced monitoring and logging

---

## Common Patterns Across Examples

### Resource Naming
All examples follow the chart's naming convention:
- Kubernetes resource names: `{projectName}-{resourceName}`
- GCP resource IDs: Use the name as specified in values

### Annotations
Examples show how to use:
- Standard CNRM annotations (deletion policy, project ID)
- Custom annotations for tagging and metadata

### Network References
Examples demonstrate:
- Local VPC references (`networkRefName`)
- Shared VPC references (`sharedVpc` object)
- Helper functions for network path construction

### Conditional Configuration
Examples show:
- Optional fields using `{{- if }}` blocks
- Nested objects using `{{- with }}` blocks
- Complex structures using `toYaml`

## Testing Examples

To test any example, use Helm template command:

```bash
# Test example 1
helm template test-release . -f examples/01-simple-dev-environment.yaml

# Test example 2
helm template test-release . -f examples/02-production-multi-region.yaml

# Test example 3 (requires host project configuration)
helm template test-release . -f examples/03-shared-vpc-service-project.yaml

# Test example 4
helm template test-release . -f examples/04-complete-infrastructure.yaml
```

## Customization

When adapting these examples:

1. **Replace placeholder values:**
   - Project names and IDs
   - Billing account IDs
   - Organization IDs
   - IP address ranges
   - Email addresses for alerts

2. **Adjust resource sizes:**
   - Node pool machine types
   - Database tiers
   - Disk sizes
   - Cluster sizes

3. **Modify network configuration:**
   - CIDR ranges
   - Regions and zones
   - Subnet configurations

4. **Update security settings:**
   - Firewall rules
   - Source IP ranges
   - IAM roles and permissions

## Best Practices

1. **Start Simple:** Begin with example 1 and add complexity as needed
2. **Use Custom Annotations:** Tag resources for better organization
3. **Protect Production:** Set `allowResourceDeletion: false` for production
4. **Enable Monitoring:** Always configure logging and monitoring for production
5. **Test First:** Use `helm template` to validate before deploying
6. **Review Generated Manifests:** Check the output before applying

## Additional Resources

- [Chart README](../README.md) - Full chart documentation
- [Values File](../values.yaml) - Complete values reference with comments
- [Helm Documentation](https://helm.sh/docs/) - Helm usage guide
- [Config Connector Documentation](https://cloud.google.com/config-connector/docs/overview) - CNRM resource reference
