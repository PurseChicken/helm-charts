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
{{- $lowercase := lower . }}
{{- $dotsReplaced := mustRegexReplaceAll "\\." $lowercase "-" }}
{{- $underscoresReplaced := mustRegexReplaceAll "_" $dotsReplaced "-" }}
{{- $plusReplaced := mustRegexReplaceAll "\\+" $underscoresReplaced "-" }}
{{- mustRegexReplaceAll "[^a-z0-9-]" $plusReplaced "-" }}
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

{{/*
Validate network reference configuration
Ensures that either local OR shared VPC references are used, not both
Also validates that paired fields are provided together
Input: dict with cluster configuration
Output: none (fails on validation error)
Usage: include "cnrm-chart.validateNetworkRefs" .
*/}}
{{- define "cnrm-chart.validateNetworkRefs" -}}
{{- if or .sharedVpcNetwork .sharedVpc }}
  {{- if or .networkName .subnetName }}
    {{- fail "Cannot use both Shared VPC and local VPC references. Use sharedVpcNetwork/sharedVpcSubnetwork OR sharedVpc object OR networkName/subnetName, not both." }}
  {{- end }}
  {{- if .sharedVpcNetwork }}
    {{- if not .sharedVpcSubnetwork }}
      {{- fail "sharedVpcSubnetwork is required when using sharedVpcNetwork" }}
    {{- end }}
  {{- end }}
  {{- if .sharedVpc }}
    {{- if not .sharedVpc.network }}
      {{- fail "sharedVpc.network is required" }}
    {{- end }}
    {{- if not .sharedVpc.subnetwork }}
      {{- fail "sharedVpc.subnetwork is required" }}
    {{- end }}
  {{- end }}
{{- else if .sharedVpcSubnetwork }}
  {{- fail "sharedVpcNetwork is required when using sharedVpcSubnetwork" }}
{{- else }}
  {{- if not .networkName }}
    {{- fail "networkName is required (or use sharedVpcNetwork/sharedVpcSubnetwork for Shared VPC)" }}
  {{- end }}
  {{- if not .subnetName }}
    {{- fail "subnetName is required (or use sharedVpcNetwork/sharedVpcSubnetwork for Shared VPC)" }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Build Shared VPC network path
Constructs the full GCP resource path for a Shared VPC network
Input: dict with "hostProject" and "network" keys
Output: projects/{hostProject}/global/networks/{network}
Usage: include "cnrm-chart.sharedVpcNetworkPath" (dict "hostProject" "host-proj" "network" "shared-net")
*/}}
{{- define "cnrm-chart.sharedVpcNetworkPath" -}}
projects/{{ .hostProject }}/global/networks/{{ .network }}
{{- end }}

{{/*
Build Shared VPC subnetwork path
Constructs the full GCP resource path for a Shared VPC subnetwork
Input: dict with "hostProject", "region", and "subnetwork" keys
Output: projects/{hostProject}/regions/{region}/subnetworks/{subnetwork}
Usage: include "cnrm-chart.sharedVpcSubnetworkPath" (dict "hostProject" "host-proj" "region" "us-central1" "subnetwork" "shared-subnet")
*/}}
{{- define "cnrm-chart.sharedVpcSubnetworkPath" -}}
projects/{{ .hostProject }}/regions/{{ .region }}/subnetworks/{{ .subnetwork }}
{{- end }}

{{/*
Get Shared VPC host project ID from top-level configuration
Retrieves the host project ID that service projects attach to
Input: root context (.)
Output: host project ID string or empty string
Usage: include "cnrm-chart.sharedVpcHostProject" .
*/}}
{{- define "cnrm-chart.sharedVpcHostProject" -}}
{{- if .Values.sharedVpc }}
{{- if .Values.sharedVpc.attachToHostProject }}
{{- .Values.sharedVpc.attachToHostProject }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Extract region from location (handles both regional and zonal locations)
Converts zone (e.g., "us-central1-a") to region (e.g., "us-central1")
Regional locations (e.g., "us-central1") pass through unchanged
Input: location string (region or zone)
Output: region string
Usage: include "cnrm-chart.extractRegion" "us-central1-a"
*/}}
{{- define "cnrm-chart.extractRegion" -}}
{{- if regexMatch "^[a-z]+-[a-z]+-[0-9]+-[a-z]$" . }}
{{- mustRegexReplaceAll "-[a-z]$" . "" }}
{{- else if regexMatch "^[a-z]+-[a-z]+[0-9]+-[a-z]$" . }}
{{- mustRegexReplaceAll "-[a-z]$" . "" }}
{{- else }}
{{- . }}
{{- end }}
{{- end }}

{{/*
Render networkRef for resources that support it
Supports two patterns:
1. networkRefName (local VPC) - converts to name with project prefix for resources in current project
2. sharedVpc object - auto-builds external path using host project for Shared VPC resources
Context expects: .context (root context), .projectName, .networkRefName, .sharedVpc
*/}}
{{- define "cnrm-chart.networkRef" -}}
{{- $sharedVpcHostProject := include "cnrm-chart.sharedVpcHostProject" .context }}
{{- if .sharedVpc }}
{{- $hostProj := .sharedVpc.hostProject | default $sharedVpcHostProject }}
{{- if not $hostProj }}
{{- fail "sharedVpc.hostProject is required (or set sharedVpc.attachToHostProject at the top level)" }}
{{- end }}
networkRef:
  external: {{ include "cnrm-chart.sharedVpcNetworkPath" (dict "hostProject" $hostProj "network" .sharedVpc.network) }}
{{- else if .networkRefName }}
networkRef:
  name: {{ include "cnrm-chart.resourceName" (dict "projectName" .projectName "name" .networkRefName) }}
{{- end }}
{{- end }}