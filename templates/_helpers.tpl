{{/*
Expand the name of the chart.
*/}}
{{- define "zookeeper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zookeeper.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zookeeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "zookeeper.labels" -}}
helm.sh/chart: {{ include "zookeeper.chart" . }}
{{ include "zookeeper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "zookeeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zookeeper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Prefixes an image with the custom container registry, if provided
*/}}
{{- define "zookeeper.image" -}}
{{- if $.Values.containerRegistry }}
{{- $.Values.containerRegistry }}/
{{- end }}
{{- . }}
{{- end }}

{{/*
Generate a list of servers based on the number of replicas
*/}}
{{- define "zookeeper.servers" -}}
{{- range $i, $e := until (.Values.replicaCount | int) }}
{{- $fullName := ( include "zookeeper.fullname" $ ) }}
{{- $hostName := ( printf "%s-%d.%s.%s" $fullName $i $fullName $.Release.Namespace ) }}
{{- $ports := $.Values.ports }}
{{- printf "server.%d=%s:%d:%d\n" (add $i 1) $hostName ($ports.follower | int) ($ports.election | int) }}
{{- end }}
{{- end }}

{{/*
Zookeeper command whitelist for external clients
*/}}
{{- define "zookeeper.commandWhitelist" -}}
{{- join "," .Values.commandWhitelist }}
{{- end }}