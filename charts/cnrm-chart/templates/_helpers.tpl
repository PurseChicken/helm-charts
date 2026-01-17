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

{{/*
Deletion policy annotation only
Generates just the deletion-policy annotation based on allowResourceDeletion
Input: dict with "allowResourceDeletion" key
Output: deletion-policy annotation (not indented)
Usage: include "cnrm-chart.deletionPolicy" (dict "allowResourceDeletion" $allowResourceDeletion)
*/}}
{{- define "cnrm-chart.deletionPolicy" -}}
{{- if .allowResourceDeletion }}
cnrm.cloud.google.com/deletion-policy: "none"
{{- else }}
cnrm.cloud.google.com/deletion-policy: "abandon"
{{- end }}
{{- end }}

{{/*
Standard CNRM annotations (deletion policy + project ID)
Generates the common Config Connector annotations used by most resources
Input: dict with "projectName" and "allowResourceDeletion" keys
Output: CNRM annotations block (not indented)
Usage: include "cnrm-chart.cnrmAnnotations" (dict "projectName" $projectName "allowResourceDeletion" $allowResourceDeletion)
*/}}
{{- define "cnrm-chart.cnrmAnnotations" -}}
{{- include "cnrm-chart.deletionPolicy" (dict "allowResourceDeletion" .allowResourceDeletion) }}
cnrm.cloud.google.com/project-id: {{ .projectName }}
{{- end }}

{{/*
Custom annotations from user configuration
Renders user-provided custom annotations with proper quoting
Input: dict with "annotations" key containing map of annotations
Output: custom annotations block (not indented)
Usage: include "cnrm-chart.customAnnotations" (dict "annotations" .customAnnotations)
*/}}
{{- define "cnrm-chart.customAnnotations" -}}
{{- if .annotations }}
{{- range $key, $value := .annotations }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate a sanitized resource name with project prefix
Applies sanitization to ensure Kubernetes-compliant resource names
Input: dict with "projectName" and "name" keys
Output: formatted resource name (projectName-sanitizedName)
Usage: include "cnrm-chart.resourceName" (dict "projectName" $projectName "name" .clusterName)
Note: Sanitization is safe for all names - valid names remain unchanged, invalid names are fixed
*/}}
{{- define "cnrm-chart.resourceName" -}}
{{- $sanitized := include "cnrm-chart.sanitizeName" .name -}}
{{ .projectName }}-{{ $sanitized }}
{{- end }}