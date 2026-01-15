{{/*
Get the project ID to use across all resources
Resolves in order: projectID -> projectName -> Release.Name
Input: root context (.)
Output: project ID string
Usage: include "cnrm-chart.projectID" .
*/}}
{{- define "cnrm-chart.projectID" -}}
{{- .Values.projectID | default (.Values.projectName | default .Release.Name) }}
{{- end }}

{{/*
Validate that both organizationId and projectFolderId are not set
Fails the deployment if both are specified since a project can only have one parent
Input: root context (.)
Output: none (fails on validation error)
Usage: include "cnrm-chart.validateProject" .
*/}}
{{- define "cnrm-chart.validateProject" -}}
{{- if and .Values.organizationId .Values.projectFolderId }}
{{- fail "Cannot specify both organizationId and projectFolderId" }}
{{- end }}
{{- end }}

{{/*
Sanitize a string to be a valid Kubernetes resource name
Input: a string value
Output: lowercase with special characters replaced by hyphens
Usage: include "cnrm-chart.sanitizeName" "My_String.Name"
*/}}
{{- define "cnrm-chart.sanitizeName" -}}
{{- $step1 := lower . }}
{{- $step2 := mustRegexReplaceAll "\\." $step1 "-" }}
{{- $step3 := mustRegexReplaceAll "_" $step2 "-" }}
{{- $step4 := mustRegexReplaceAll "\\+" $step3 "-" }}
{{- mustRegexReplaceAll "[^a-z0-9-]" $step4 "-" }}
{{- end }}

{{/*
Sanitize an email address for use in a Kubernetes resource name
Removes everything after @ and sanitizes the local part
Input: email address string
Output: sanitized string suitable for k8s resource name
Usage: include "cnrm-chart.sanitizeEmail" "user@example.com"
*/}}
{{- define "cnrm-chart.sanitizeEmail" -}}
{{- $removeAt := mustRegexReplaceAll "@.*$" . "" }}
{{- include "cnrm-chart.sanitizeName" $removeAt }}
{{- end }}