# Gateway API Chart

This chart was created to help you deploy Gateway API resources such as a Service Export, HTTP Route and Gateway.

# Information

This was curated primarily for use in GKE, so some of the resources like Gateway Policy and Backend Policy are specific to GCP. Additionally, the Cloud Armor WAF via Security Policy uses the Config Connector add-on. </br>
PR's and Issues are welcome!

# Prerequisites

Google Cloud (GCP) for use of Gateway Policy and Backend Policy. </br>
Config Connector add-on for use of Cloud Armor.

# Currently supported resources

- Gateway
- HTTPRoute
- ServiceExport
- HealthCheckPolicy
- GCPGatewayPolicy
- GCPBackendPolicy
- ComputeSecurityPolicy (via ConfigConnector)

# Usage

```console
$ helm repo add pursechicken https://pursechicken.github.io/helm-charts
```

Use the chart as a dependency to your own chart:

```Chart.yaml
dependencies:
- name: gateway-api-chart
  version: "1.0.0"
  repository: "https://pursechicken.github.io/helm-charts"
```

Or use the chart as an additional dependency:

```Chart.yaml
dependencies:
- name: zitadel
  version: 8.11.1
  repository: "https://charts.zitadel.com"
- name: gateway-api-chart
  version: "1.0.0"
  repository: "https://pursechicken.github.io/helm-charts"
```

Then pull the dependency chart down

```console
$ helm dep update
```

Specify the values you want to use in your own values file. Use the included values.yaml file as a reference. Lots of comments are included in the values file.

[values.yaml](./values.yaml)

Below is an example of how your values might look:

```values.yaml
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
      backendPolicy:
        securityPolicy:
          enabled: true
          preview: false
          project: my-gcp-project
          sqliConfig:
            sensitivity: 1
            optOutRules:
              - "owasp-crs-v030301-id942190-sqli"
              - "owasp-crs-v030301-id942270-sqli"
              - "owasp-crs-v030301-id942360-sqli"
          xssConfig:
            optOutRules:
              - "owasp-crs-v030301-id941380-xss"
              - "owasp-crs-v030301-id941320-xss"
              - "owasp-crs-v030301-id941340-xss"
              - "owasp-crs-v030301-id941330-xss"
          lfiConfig:
            enabled: true
          rceConfig:
            optOutRules:
              - "owasp-crs-v030301-id932200-rce"
              - "owasp-crs-v030301-id932105-rce"
              - "owasp-crs-v030301-id932130-rce"
          rfiConfig:
            enabled: true
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
          javaConfig:
            enabled: true
          nodejsConfig:
            enabled: true
          cveConfig:
            enabled: true
          jsonsqliConfig:
            optOutRules:
              - "owasp-crs-id942550-sqli"
        logging:
          enabled: true
          sampleRate: 500000
```