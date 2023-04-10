# Config Connector Chart

This chart was created to help you deploy Google Cloud Projects and Infrastructure using GCP's [Config Connector](https://cloud.google.com/config-connector/docs/overview) addon.

# Intent

The chart allows you to deploy the majority of your infrastructure using a Infrastructure as Code (IaC) methodology. This allows you to use your CI\CD solution(s) to deploy Infrastructure (E.G. ArgoCD).

# Information

This chart evolved from what was needed in specific use cases for an Organization. This means that the chart does not represent all resources or resource options that can be deployed using config connector.

# Prerequisites

The methodology for the charts use is that you have an existing Kubernetes cluster running Config Connector. This Config Connector instance Service account must have "Project Creator" IAM permissions on the GCP Organization. This will allow you to use that Project\Cluster as your configuration cluster to then deploy all your other projects \ infrastructure from

# Design

<img src="images/cnrmDesign.png" alt="Design"></br>

# Currently supported resources

- Projects
- API's
- VPC networks
- Kubernetes Clusters & Node Pools
- IAM
- Compute Addresses
- Service Networking Connections
- Cloud DNS
- gkeHub (Fleet)
- SSLPolicy
- Cloud Monitoring
- Cloud SQL

# Caveats

- Not all Config Connector options and resources are available yet in the chart. They will be added as needed or if possible when requested.
- The chart assumes that you are deploying projects and resources external to the current project its running in.
- For safety reasons, a lot of the resources are deployed use the "abandon" deletion-policy annotation. This means that the majority of your resources will need to be manually deleted if you delete them from Config Connector.