{{/*
Helper templates for gateway-api-chart
*/}}

{{/*
Build a single WAF rule expression component
Input: dict with "ruleSet" (string), "config" (object)
Output: WAF expression string for one rule set
*/}}
{{- define "gateway-api-chart.wafRuleExpression" -}}
{{- $ruleSet := .ruleSet -}}
{{- $config := .config -}}
evaluatePreconfiguredWaf('{{ $ruleSet }}', {'sensitivity': {{ $config.sensitivity | default 2 }}{{- if $config.optOutRules }}, 'opt_out_rule_ids': [{{- range $index, $rule := $config.optOutRules }}{{- if $index }}, {{ end }}'{{ $rule }}'{{- end }}]{{- else if $config.optInRules }}, 'opt_in_rule_ids': [{{- range $index, $rule := $config.optInRules }}{{- if $index }}, {{ end }}'{{ $rule }}'{{- end }}]{{- end -}}})
{{- end -}}

{{/*
Build TargetRef for policies
Input: dict with "group" (string, optional), "kind" (string), "name" (string), "namespace" (string, optional)
Output: TargetRef YAML block
*/}}
{{- define "gateway-api-chart.targetRef" -}}
{{- $group := .group | default "" -}}
{{- $kind := .kind -}}
{{- $name := .name -}}
{{- $namespace := .namespace | default "" -}}
{{- if and $group (ne $group "") }}
group: {{ $group }}
{{- end }}
kind: {{ $kind }}
name: {{ $name }}
{{- if and $namespace (ne $namespace "") }}
namespace: {{ $namespace }}
{{- end }}
{{- end -}}

{{/*
Build GCPBackendPolicy spec.default section
Input: dict with "backendPolicy" (object), "serviceName" (string)
Output: BackendPolicy spec.default YAML block
*/}}
{{- define "gateway-api-chart.backendPolicySpec" -}}
{{- $backendPolicy := .backendPolicy -}}
{{- $serviceName := .serviceName -}}
{{- if $backendPolicy.timeoutSec }}
timeoutSec: {{ $backendPolicy.timeoutSec }}
{{- end }}
{{- if $backendPolicy.sessionAffinity }}
{{- with $backendPolicy.sessionAffinity }}
sessionAffinity:
  type: {{ .type }}
  {{- if eq .type "GENERATED_COOKIE" }}
  cookieTtlSec: {{ .cookieTtlSec }}
  {{- end }}
{{- end }}
{{- end }}
{{- if $backendPolicy.connectionDraining }}
{{- with $backendPolicy.connectionDraining }}
connectionDraining:
  drainingTimeoutSec: {{ .timeoutSec }}
{{- end }}
{{- end }}
{{- if $backendPolicy.logging }}
{{- with $backendPolicy.logging }}
logging:
  enabled: {{ .enabled }}
  sampleRate: {{ .sampleRate }}
  {{- if .optionalMode }}
  optionalMode: {{ .optionalMode }}
  {{- end }}
  {{- if .optionalFields }}
  optionalFields:
    {{- range .optionalFields }}
    - {{ . }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- if $backendPolicy.maxRatePerEndpoint }}
maxRatePerEndpoint: {{ $backendPolicy.maxRatePerEndpoint }}
{{- end }}
{{- if $backendPolicy.backends }}
backends:
  {{- toYaml $backendPolicy.backends | nindent 2 }}
{{- end }}
{{- if $backendPolicy.iap }}
{{- with $backendPolicy.iap }}
iap:
  enabled: {{ .enabled }}
  clientID: {{ .clientID }}
  oauth2ClientSecret:
    name: {{ .oauth2ClientSecret.name }}
{{- end }}
{{- end }}
{{- if $backendPolicy.securityPolicy }}
{{- with $backendPolicy.securityPolicy.enabled }}
securityPolicy: {{ $serviceName }}-ca-waf
{{- end }}
{{- end }}
{{- end -}}

{{/*
Build HealthCheckPolicy spec.default section
Input: dict with "healthCheck" (object)
Output: HealthCheckPolicy spec.default YAML block
*/}}
{{- define "gateway-api-chart.healthCheckSpec" -}}
{{- $healthCheck := .healthCheck -}}
checkIntervalSec: {{ $healthCheck.checkIntervalSec | default "15" }}
timeoutSec: {{ $healthCheck.timeoutSec | default "15" }}
healthyThreshold: {{ $healthCheck.healthyThreshold | default "1" }}
unhealthyThreshold: {{ $healthCheck.unhealthyThreshold | default "2" }}
logConfig:
  enabled: {{ $healthCheck.logConfigEnabled | default "true" }}
config:
  {{- include "gateway-api-chart.healthCheckConfig" (dict "healthCheck" $healthCheck) | nindent 2 }}
{{- end -}}

{{/*
Build HealthCheckPolicy spec.default.config section
Input: dict with "healthCheck" (object)
Output: Health check config YAML block
*/}}
{{- define "gateway-api-chart.healthCheckConfig" -}}
{{- $healthCheck := .healthCheck -}}
type: {{ $healthCheck.type }}
{{- if $healthCheck.tcpHealthCheck }}
tcpHealthCheck:
  {{- toYaml $healthCheck.tcpHealthCheck | nindent 2 }}
{{- else if (or (eq $healthCheck.type "TCP") (eq $healthCheck.type "tcp")) }}
tcpHealthCheck: {}
{{- else if $healthCheck.httpHealthCheck }}
httpHealthCheck:
  {{- toYaml $healthCheck.httpHealthCheck | nindent 2 }}
{{- else if $healthCheck.httpsHealthCheck }}
httpsHealthCheck:
  {{- toYaml $healthCheck.httpsHealthCheck | nindent 2 }}
{{- else if $healthCheck.grpcHealthCheck }}
grpcHealthCheck:
  {{- toYaml $healthCheck.grpcHealthCheck | nindent 2 }}
{{- else if $healthCheck.http2HealthCheck }}
http2HealthCheck:
  {{- toYaml $healthCheck.http2HealthCheck | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Build ComputeSecurityPolicy rules section (WAF waves, rate limiting, custom rules)
Input: dict with "securityPolicy" (object)
Output: Rules YAML block
*/}}
{{- define "gateway-api-chart.securityPolicyRules" -}}
{{- $securityPolicy := .securityPolicy -}}
{{- /* Default allow rule - lowest priority, matches all traffic */}}
- description: "Default allow rule."
  action: allow
  preview: false
  priority: 2147483647
  match:
    versionedExpr: SRC_IPS_V1
    config:
      srcIpRanges:
        - '*'
{{- /* WAF rules are grouped into "waves" to minimize rule quota usage.
     Each wave combines multiple WAF rule sets into a single rule using OR operators.
     This reduces the total number of rules from 12+ to just 3-4 rules. */}}
{{- /* Wave 1: Core injection attacks (SQLi, XSS, LFI, RCE, RFI) - Priority 5 (highest) */}}
{{- $wave1Enabled := or (and $securityPolicy.sqliConfig (ne $securityPolicy.sqliConfig.enabled false)) (and $securityPolicy.xssConfig (ne $securityPolicy.xssConfig.enabled false)) (and $securityPolicy.lfiConfig (ne $securityPolicy.lfiConfig.enabled false)) (and $securityPolicy.rceConfig (ne $securityPolicy.rceConfig.enabled false)) (and $securityPolicy.rfiConfig (ne $securityPolicy.rfiConfig.enabled false)) }}
{{- if $wave1Enabled }}
- description: "waf-rules-wave-1"
  action: {{ $securityPolicy.action | default "deny(403)" }}
  preview: {{ $securityPolicy.preview | default false }}
  priority: 5
  match:
    expr:
      expression: "{{- if and $securityPolicy.sqliConfig (ne $securityPolicy.sqliConfig.enabled false) -}}{{ with $securityPolicy.sqliConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "sqli-v33-stable" "config" .) }}{{ end }}{{- if or (and ($securityPolicy.xssConfig) (ne $securityPolicy.xssConfig.enabled false)) (and ($securityPolicy.lfiConfig) (ne $securityPolicy.lfiConfig.enabled false)) (and ($securityPolicy.rceConfig) (ne $securityPolicy.rceConfig.enabled false)) (and ($securityPolicy.rfiConfig) (ne $securityPolicy.rfiConfig.enabled false)) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.xssConfig (ne $securityPolicy.xssConfig.enabled false) -}}{{ with $securityPolicy.xssConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "xss-v33-stable" "config" .) }}{{ end }}{{- if or (and ($securityPolicy.lfiConfig) (ne $securityPolicy.lfiConfig.enabled false)) (and ($securityPolicy.rceConfig) (ne $securityPolicy.rceConfig.enabled false)) (and ($securityPolicy.rfiConfig) (ne $securityPolicy.rfiConfig.enabled false)) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.lfiConfig (ne $securityPolicy.lfiConfig.enabled false) -}}{{ with $securityPolicy.lfiConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "lfi-v33-stable" "config" .) }}{{ end }}{{- if or (and ($securityPolicy.rceConfig) (ne $securityPolicy.rceConfig.enabled false)) (and ($securityPolicy.rfiConfig) (ne $securityPolicy.rfiConfig.enabled false)) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.rceConfig (ne $securityPolicy.rceConfig.enabled false) -}}{{ with $securityPolicy.rceConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "rce-v33-stable" "config" .) }}{{ end }}{{- if and ($securityPolicy.rfiConfig) (ne $securityPolicy.rfiConfig.enabled false) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.rfiConfig (ne $securityPolicy.rfiConfig.enabled false) -}}{{ with $securityPolicy.rfiConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "rfi-v33-stable" "config" .) }}{{ end }}{{- end -}}"
{{- end }}
{{- /* Wave 2: Protocol and method-based attacks - Priority 10 */}}
{{- $wave2Enabled := or (and $securityPolicy.methodConfig (ne $securityPolicy.methodConfig.enabled false)) (and $securityPolicy.scannerConfig (ne $securityPolicy.scannerConfig.enabled false)) (and $securityPolicy.protocolConfig (ne $securityPolicy.protocolConfig.enabled false)) (and $securityPolicy.phpConfig (ne $securityPolicy.phpConfig.enabled false)) (and $securityPolicy.sessionConfig (ne $securityPolicy.sessionConfig.enabled false)) }}
{{- if $wave2Enabled }}
- description: "waf-rules-wave-2"
  action: {{ $securityPolicy.action | default "deny(403)" }}
  preview: {{ $securityPolicy.preview | default false }}
  priority: 10
  match:
    expr:
      expression: "{{- if and $securityPolicy.methodConfig (ne $securityPolicy.methodConfig.enabled false) -}}{{ with $securityPolicy.methodConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "methodenforcement-v33-stable" "config" .) }}{{ end }}{{- if or (and ($securityPolicy.scannerConfig) (ne $securityPolicy.scannerConfig.enabled false)) (and ($securityPolicy.protocolConfig) (ne $securityPolicy.protocolConfig.enabled false)) (and ($securityPolicy.phpConfig) (ne $securityPolicy.phpConfig.enabled false)) (and ($securityPolicy.sessionConfig) (ne $securityPolicy.sessionConfig.enabled false)) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.scannerConfig (ne $securityPolicy.scannerConfig.enabled false) -}}{{ with $securityPolicy.scannerConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "scannerdetection-v33-stable" "config" .) }}{{ end }}{{- if or (and ($securityPolicy.protocolConfig) (ne $securityPolicy.protocolConfig.enabled false)) (and ($securityPolicy.phpConfig) (ne $securityPolicy.phpConfig.enabled false)) (and ($securityPolicy.sessionConfig) (ne $securityPolicy.sessionConfig.enabled false)) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.protocolConfig (ne $securityPolicy.protocolConfig.enabled false) -}}{{ with $securityPolicy.protocolConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "protocolattack-v33-stable" "config" .) }}{{ end }}{{- if or (and ($securityPolicy.phpConfig) (ne $securityPolicy.phpConfig.enabled false)) (and ($securityPolicy.sessionConfig) (ne $securityPolicy.sessionConfig.enabled false)) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.phpConfig (ne $securityPolicy.phpConfig.enabled false) -}}{{ with $securityPolicy.phpConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "php-v33-stable" "config" .) }}{{ end }}{{- if and ($securityPolicy.sessionConfig) (ne $securityPolicy.sessionConfig.enabled false) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.sessionConfig (ne $securityPolicy.sessionConfig.enabled false) -}}{{ with $securityPolicy.sessionConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "sessionfixation-v33-stable" "config" .) }}{{ end }}{{- end -}}"
{{- end }}
{{- /* Wave 3: Language-specific and vulnerability-based attacks - Priority 15 (lowest) */}}
{{- $wave3Enabled := or (and $securityPolicy.javaConfig (ne $securityPolicy.javaConfig.enabled false)) (and $securityPolicy.nodejsConfig (ne $securityPolicy.nodejsConfig.enabled false)) (and $securityPolicy.cveConfig (ne $securityPolicy.cveConfig.enabled false)) (and $securityPolicy.jsonsqliConfig (ne $securityPolicy.jsonsqliConfig.enabled false)) }}
{{- if $wave3Enabled }}
- description: "waf-rules-wave-3"
  action: {{ $securityPolicy.action | default "deny(403)" }}
  preview: {{ $securityPolicy.preview | default false }}
  priority: 15
  match:
    expr:
      expression: "{{- if and $securityPolicy.javaConfig (ne $securityPolicy.javaConfig.enabled false) -}}{{ with $securityPolicy.javaConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "java-v33-stable" "config" .) }}{{ end }}{{- if or (and ($securityPolicy.nodejsConfig) (ne $securityPolicy.nodejsConfig.enabled false)) (and ($securityPolicy.cveConfig) (ne $securityPolicy.cveConfig.enabled false)) (and ($securityPolicy.jsonsqliConfig) (ne $securityPolicy.jsonsqliConfig.enabled false)) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.nodejsConfig (ne $securityPolicy.nodejsConfig.enabled false) -}}{{ with $securityPolicy.nodejsConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "nodejs-v33-stable" "config" .) }}{{ end }}{{- if or (and ($securityPolicy.cveConfig) (ne $securityPolicy.cveConfig.enabled false)) (and ($securityPolicy.jsonsqliConfig) (ne $securityPolicy.jsonsqliConfig.enabled false)) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.cveConfig (ne $securityPolicy.cveConfig.enabled false) -}}{{ with $securityPolicy.cveConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "cve-canary" "config" .) }}{{ end }}{{- if and ($securityPolicy.jsonsqliConfig) (ne $securityPolicy.jsonsqliConfig.enabled false) }} || {{ end -}}{{ end -}}{{- if and $securityPolicy.jsonsqliConfig (ne $securityPolicy.jsonsqliConfig.enabled false) -}}{{ with $securityPolicy.jsonsqliConfig }}{{ include "gateway-api-chart.wafRuleExpression" (dict "ruleSet" "json-sqli-canary" "config" .) }}{{ end }}{{- end -}}"
{{- end }}
{{- if $securityPolicy.rateLimitConfig }}
{{- with $securityPolicy.rateLimitConfig }}
- description: "default-rate-limiting"
  action: {{ .action | quote }}
  preview: {{ .preview | default false }}
  priority: 2147483646
  rateLimitOptions:
    {{- if eq .action "rate_based_ban" }}
    banDurationSec: {{ .banDurationSec }}
    banThreshold:
      count: {{ .requests }}
      intervalSec: {{ .interval }}
    {{- end }}
    conformAction: allow
    {{- if .enforceOnKeyConfigs }}
    enforceOnKey: ""
    enforceOnKeyConfigs:
      {{- range .enforceOnKeyConfigs }}
      - enforceOnKeyType: {{ .keyType }}
        {{- if or (eq .keyType "HTTP_HEADER") (eq .keyType "HTTP_COOKIE") }}
        enforceOnKeyName: {{ .keyName }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if not .enforceOnKeyConfigs }}
    enforceOnKey: {{ .enforceOnKey | default "ALL" }}
    {{- if and .enforceOnKeyName (or (eq .enforceOnKey "HTTP_HEADER") (eq .enforceOnKey "HTTP_COOKIE")) }}
    enforceOnKeyName: {{ .enforceOnKeyName }}
    {{- end }}
    {{- end }}
    exceedAction: {{ .exceedAction }}
    rateLimitThreshold:
      count: {{ .requests }}
      intervalSec: {{ .interval }}
  match:
    versionedExpr: SRC_IPS_V1
    config:
      srcIpRanges:
        - "*"
{{- end }}
{{- end }}
{{- if $securityPolicy.customRules }}
{{- toYaml $securityPolicy.customRules | nindent 0 }}
{{- end }}
{{- end -}}