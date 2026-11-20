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

{{/*
Render a Config Connector object reference (external selfLink/name, or Kubernetes name with project prefix)
Used by templates/computerouternat.yaml (natIps, drainNatIps, rules, subnetworkRef), computedisk.yaml (imageRef, snapshotRef, sourceDiskRef, resourcePolicies, asyncPrimaryDisk), computeinstancetemplate.yaml (disk and network refs, natIpRef), computeinstancegroupmanager.yaml (instanceTemplateRef, healthCheckRef, targetPools), ComputeRoute (network and next-hop refs), computefirewall (sourceServiceAccounts, targetServiceAccounts), monitoring alert policy notificationChannels, and similar patterns.
Input: dict with "projectName" and "ref" keys; ref may contain external, name, and/or namespace
See: https://cloud.google.com/config-connector/docs/reference/resource-docs/compute/computerouternat
*/}}
{{- define "cnrm-chart.gcpObjectRef" -}}
{{- if .ref.external }}
external: {{ .ref.external }}
{{- else if .ref.name }}
name: {{ include "cnrm-chart.resourceName" (dict "projectName" .projectName "name" .ref.name) }}
{{- end }}
{{- if .ref.namespace }}
namespace: {{ .ref.namespace }}
{{- end }}
{{- end }}

{{/*
Single-line / flow-style ref for YAML list items (avoids blank lines from block indentation).
*/}}
{{- define "cnrm-chart.gcpObjectRefFlow" -}}
{{- if .ref.namespace -}}
{ {{- if .ref.external }} external: {{ .ref.external | quote }}{{ else }} name: {{ include "cnrm-chart.resourceName" (dict "projectName" .projectName "name" .ref.name) | quote }}{{ end }}, namespace: {{ .ref.namespace | quote }} }
{{- else if .ref.external -}}
external: {{ .ref.external | quote }}
{{- else -}}
name: {{ include "cnrm-chart.resourceName" (dict "projectName" .projectName "name" .ref.name) }}
{{- end -}}
{{- end }}

{{/*
Project reference.
format "projects" (default) emits external: "projects/<projectID>".
format "id" emits the bare project ID. LoggingLogSink requires the bare ID.
An explicit projectRef is written as given. projectRef.name is the Project
resource's Kubernetes name, which this chart sets to the project ID.
*/}}
{{- define "cnrm-chart.projectRef" -}}
{{- if .projectRef -}}
{{- if and .projectRef.external .projectRef.name -}}
{{- fail "cnrm-chart: projectRef accepts external or name, not both" -}}
{{- end -}}
{{- if not (or .projectRef.external .projectRef.name) -}}
{{- fail "cnrm-chart: projectRef requires external or name" -}}
{{- end -}}
projectRef:
  {{- if .projectRef.external }}
  external: {{ .projectRef.external | quote }}
  {{- else }}
  name: {{ .projectRef.name }}
  {{- end }}
  {{- if .projectRef.namespace }}
  namespace: {{ .projectRef.namespace }}
  {{- end }}
  {{- if .projectRef.kind }}
  kind: {{ .projectRef.kind }}
  {{- end }}
{{- else if eq (.format | default "projects") "id" -}}
projectRef:
  external: {{ .projectName | quote }}
{{- else -}}
projectRef:
  external: {{ printf "projects/%s" .projectName | quote }}
{{- end -}}
{{- end -}}

{{/*
folderRef or organizationRef, or a projectRef when neither is set.
name is not project-prefixed: Folder, Organization, and Project Kubernetes
names are not run through cnrm-chart.resourceName.
*/}}
{{- define "cnrm-chart.parentRef" -}}
{{- $parents := 0 -}}
{{- if .projectRef }}{{ $parents = add $parents 1 }}{{ end -}}
{{- if .folderRef }}{{ $parents = add $parents 1 }}{{ end -}}
{{- if .organizationRef }}{{ $parents = add $parents 1 }}{{ end -}}
{{- if gt $parents 1 -}}
{{- fail (printf "cnrm-chart: %s accepts only one of projectRef, folderRef, or organizationRef" .label) -}}
{{- end -}}
{{- if .folderRef -}}
{{- if not (or .folderRef.external .folderRef.name) -}}
{{- fail (printf "cnrm-chart: %s folderRef requires external or name" .label) -}}
{{- end -}}
folderRef:
  {{- if .folderRef.external }}
  external: {{ .folderRef.external | quote }}
  {{- else }}
  name: {{ .folderRef.name }}
  {{- end }}
  {{- if .folderRef.namespace }}
  namespace: {{ .folderRef.namespace }}
  {{- end }}
{{- else if .organizationRef -}}
{{- if not (or .organizationRef.external .organizationRef.name) -}}
{{- fail (printf "cnrm-chart: %s organizationRef requires external or name" .label) -}}
{{- end -}}
organizationRef:
  {{- if .organizationRef.external }}
  external: {{ .organizationRef.external | quote }}
  {{- else }}
  name: {{ .organizationRef.name }}
  {{- end }}
  {{- if .organizationRef.namespace }}
  namespace: {{ .organizationRef.namespace }}
  {{- end }}
{{- else -}}
{{- include "cnrm-chart.projectRef" (dict "projectName" .projectName "projectRef" .projectRef "format" .format) -}}
{{- end -}}
{{- end -}}

{{/*
IAMPolicyMember.
Legacy project bindings (member + external) stay on the Project resource.
resourceRef targets another kind. memberFrom binds an identity that Config
Connector has to read from a referenced resource (log sink writer, service
identity, service account, SQL instance, or BigQuery connection).
defaultResourceRef is used when the member sets neither resourceRef nor external.
requireResourceRef fails instead of falling back to the project.
*/}}
{{- define "cnrm-chart.iamPolicyMember" -}}
{{- $projectName := .projectName -}}
{{- $m := .member -}}
{{- if not $m.name -}}
{{- fail "cnrm-chart: IAMPolicyMember requires name" -}}
{{- end -}}
{{- if not $m.role -}}
{{- fail (printf "cnrm-chart: IAMPolicyMember %s requires role" $m.name) -}}
{{- end -}}
{{- if and $m.member $m.memberFrom -}}
{{- fail (printf "cnrm-chart: IAMPolicyMember %s accepts member or memberFrom, not both" $m.name) -}}
{{- end -}}
{{- if and (not $m.member) (not $m.memberFrom) -}}
{{- fail (printf "cnrm-chart: IAMPolicyMember %s requires member or memberFrom" $m.name) -}}
{{- end -}}
{{- if and $m.resourceRef $m.external -}}
{{- fail (printf "cnrm-chart: IAMPolicyMember %s accepts resourceRef or external, not both" $m.name) -}}
{{- end -}}
{{- $deletion := .allowResourceDeletion -}}
{{- if hasKey $m "allowResourceDeletion" -}}
{{- $deletion = $m.allowResourceDeletion -}}
{{- end -}}
{{- $ref := $m.resourceRef -}}
{{- if and (not $ref) (not $m.external) .defaultResourceRef -}}
{{- $ref = .defaultResourceRef -}}
{{- end -}}
{{- if and .requireResourceRef (not $ref) (not $m.external) -}}
{{- fail (printf "cnrm-chart: IAMPolicyMember %s requires resourceRef" $m.name) -}}
{{- end -}}
{{- $api := "" -}}
{{- if $ref -}}
{{- if not $ref.kind }}{{ fail (printf "cnrm-chart: IAMPolicyMember %s resourceRef.kind is required" $m.name) }}{{ end -}}
{{- if not (or $ref.external $ref.name) }}{{ fail (printf "cnrm-chart: IAMPolicyMember %s resourceRef requires external or name" $m.name) }}{{ end -}}
{{- $api = $ref.apiVersion -}}
{{- if not $api -}}
{{- if eq $ref.kind "Project" }}{{ $api = "resourcemanager.cnrm.cloud.google.com/v1beta1" }}
{{- else if eq $ref.kind "IAMServiceAccount" }}{{ $api = "iam.cnrm.cloud.google.com/v1beta1" }}
{{- else if eq $ref.kind "PubSubTopic" }}{{ $api = "pubsub.cnrm.cloud.google.com/v1beta1" }}
{{- else if eq $ref.kind "PubSubSubscription" }}{{ $api = "pubsub.cnrm.cloud.google.com/v1beta1" }}
{{- else if eq $ref.kind "StorageBucket" }}{{ $api = "storage.cnrm.cloud.google.com/v1beta1" }}
{{- else if eq $ref.kind "SQLInstance" }}{{ $api = "sql.cnrm.cloud.google.com/v1beta1" }}
{{- else if eq $ref.kind "LoggingLogBucket" }}{{ $api = "logging.cnrm.cloud.google.com/v1beta1" }}
{{- else if eq $ref.kind "BigQueryDataset" }}{{ $api = "bigquery.cnrm.cloud.google.com/v1beta1" }}
{{- end -}}
{{- end -}}
{{- end -}}
apiVersion: iam.cnrm.cloud.google.com/v1beta1
kind: IAMPolicyMember
metadata:
  annotations:
    {{- include "cnrm-chart.deletionPolicy" (dict "allowResourceDeletion" $deletion) | nindent 4 }}
  name: {{ include "cnrm-chart.resourceName" (dict "projectName" $projectName "name" $m.name) }}
spec:
  {{- if $m.member }}
  member: {{ $m.member }}
  {{- else }}
  memberFrom:
    {{- $mf := $m.memberFrom -}}
    {{- $found := 0 -}}
    {{- range $key := list "logSinkRef" "serviceAccountRef" "serviceIdentityRef" "sqlInstanceRef" "bigQueryConnectionConnectionRef" -}}
    {{- if hasKey $mf $key }}{{ $found = add $found 1 }}{{ end -}}
    {{- end -}}
    {{- if ne $found 1 -}}
    {{- fail (printf "cnrm-chart: IAMPolicyMember %s memberFrom requires exactly one of logSinkRef, serviceAccountRef, serviceIdentityRef, sqlInstanceRef, bigQueryConnectionConnectionRef" $m.name) -}}
    {{- end -}}
    {{- if $mf.logSinkRef }}
    {{- if not $mf.logSinkRef.name }}{{ fail (printf "cnrm-chart: IAMPolicyMember %s logSinkRef.name is required" $m.name) }}{{ end }}
    logSinkRef:
      name: {{ include "cnrm-chart.resourceName" (dict "projectName" $projectName "name" $mf.logSinkRef.name) }}
      {{- if $mf.logSinkRef.namespace }}
      namespace: {{ $mf.logSinkRef.namespace }}
      {{- end }}
    {{- else if $mf.serviceAccountRef }}
    {{- if not $mf.serviceAccountRef.name }}{{ fail (printf "cnrm-chart: IAMPolicyMember %s serviceAccountRef.name is required" $m.name) }}{{ end }}
    serviceAccountRef:
      name: {{ include "cnrm-chart.resourceName" (dict "projectName" $projectName "name" $mf.serviceAccountRef.name) }}
      {{- if $mf.serviceAccountRef.namespace }}
      namespace: {{ $mf.serviceAccountRef.namespace }}
      {{- end }}
    {{- else if $mf.serviceIdentityRef }}
    {{- if not $mf.serviceIdentityRef.name }}{{ fail (printf "cnrm-chart: IAMPolicyMember %s serviceIdentityRef.name is required" $m.name) }}{{ end }}
    serviceIdentityRef:
      name: {{ include "cnrm-chart.resourceName" (dict "projectName" $projectName "name" $mf.serviceIdentityRef.name) }}
      {{- if $mf.serviceIdentityRef.namespace }}
      namespace: {{ $mf.serviceIdentityRef.namespace }}
      {{- end }}
    {{- else if $mf.sqlInstanceRef }}
    {{- if not $mf.sqlInstanceRef.name }}{{ fail (printf "cnrm-chart: IAMPolicyMember %s sqlInstanceRef.name is required" $m.name) }}{{ end }}
    sqlInstanceRef:
      name: {{ include "cnrm-chart.resourceName" (dict "projectName" $projectName "name" $mf.sqlInstanceRef.name) }}
      {{- if $mf.sqlInstanceRef.namespace }}
      namespace: {{ $mf.sqlInstanceRef.namespace }}
      {{- end }}
    {{- else if $mf.bigQueryConnectionConnectionRef }}
    {{- if not $mf.bigQueryConnectionConnectionRef.name }}{{ fail (printf "cnrm-chart: IAMPolicyMember %s bigQueryConnectionConnectionRef.name is required" $m.name) }}{{ end }}
    {{- if not $mf.bigQueryConnectionConnectionRef.type }}{{ fail (printf "cnrm-chart: IAMPolicyMember %s bigQueryConnectionConnectionRef.type is required" $m.name) }}{{ end }}
    bigQueryConnectionConnectionRef:
      name: {{ include "cnrm-chart.resourceName" (dict "projectName" $projectName "name" $mf.bigQueryConnectionConnectionRef.name) }}
      type: {{ $mf.bigQueryConnectionConnectionRef.type | quote }}
      {{- if $mf.bigQueryConnectionConnectionRef.namespace }}
      namespace: {{ $mf.bigQueryConnectionConnectionRef.namespace }}
      {{- end }}
    {{- end }}
  {{- end }}
  role: {{ $m.role }}
  {{- if $ref }}
  resourceRef:
    {{- if $api }}
    apiVersion: {{ $api }}
    {{- end }}
    kind: {{ $ref.kind }}
    {{- if $ref.external }}
    external: {{ $ref.external | quote }}
    {{- else if or (eq $ref.kind "Project") (eq $ref.kind "Folder") (eq $ref.kind "Organization") }}
    name: {{ $ref.name }}
    {{- else if eq $ref.kind "LoggingLogBucket" }}
    name: {{ $projectName }}-{{ $ref.name }}
    {{- else }}
    name: {{ include "cnrm-chart.resourceName" (dict "projectName" $projectName "name" $ref.name) }}
    {{- end }}
    {{- if $ref.namespace }}
    namespace: {{ $ref.namespace }}
    {{- end }}
  {{- else }}
  resourceRef:
    apiVersion: resourcemanager.cnrm.cloud.google.com/v1beta1
    kind: Project
    external: {{ default (printf "projects/%s" $projectName) $m.external | quote }}
  {{- end }}
  {{- with $m.condition }}
  condition:
    title: {{ .title | quote }}
    {{- if .description }}
    description: {{ .description | quote }}
    {{- end }}
    expression: {{ .expression | quote }}
  {{- end }}
{{- end -}}