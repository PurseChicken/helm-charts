{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "snipeit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "snipeit.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "snipeit.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for the mysql requirement.
*/}}
{{- define "snipeit.mysqlFullname" -}}
{{- $mysqlContext := dict "Values" .Values.mysql "Release" .Release "Chart" (dict "Name" "mysql") -}}
{{ template "mysql.fullname" $mysqlContext }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "snipeit.labels" -}}
app.kubernetes.io/name: snipeit
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "snipeit.chart" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "snipeit.selector" -}}
app.kubernetes.io/name: snipeit
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "snipeit.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "snipeit.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Snipe-IT image reference. Also the default image of the config-data init container.
*/}}
{{- define "snipeit.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion | toString) -}}
{{- end -}}

{{/*
Render a container probe. An exec, tcpSocket or grpc handler replaces the default httpGet, so a
probe can switch handlers from any values file. An httpGet probe without its own Host header gets
one with the host from config.snipeit.url: Snipe-IT 8.8.4+ returns 400 to requests whose Host
doesn't match APP_URL, and kubelet sends the pod IP and port as Host otherwise.
Usage: include "snipeit.probe" (dict "probe" .Values.livenessProbe "context" $)
*/}}
{{- define "snipeit.probe" -}}
{{- $probe := deepCopy .probe -}}
{{- if or $probe.exec $probe.tcpSocket $probe.grpc -}}
{{- $_ := unset $probe "httpGet" -}}
{{- end -}}
{{- $host := (urlParse (.context.Values.config.snipeit.url | default "" | toString | trim)).host -}}
{{- if and $probe.httpGet $host -}}
{{- $headers := $probe.httpGet.httpHeaders | default list -}}
{{- $hasHost := false -}}
{{- range $headers -}}
{{- if eq (lower .name) "host" -}}
{{- $hasHost = true -}}
{{- end -}}
{{- end -}}
{{- if not $hasHost -}}
{{- $_ := set $probe.httpGet "httpHeaders" (append $headers (dict "name" "Host" "value" $host)) -}}
{{- end -}}
{{- end -}}
{{- toYaml $probe -}}
{{- end -}}