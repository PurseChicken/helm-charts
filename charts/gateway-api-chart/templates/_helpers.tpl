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
