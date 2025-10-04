{{/*
Expand the name of the chart.
*/}}
{{- define "cert-manager-certificates.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
For release names following ${component}-certificate-issuer pattern, we use the release name directly.
*/}}
{{- define "cert-manager-certificates.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cert-manager-certificates.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cert-manager-certificates.labels" -}}
helm.sh/chart: {{ include "cert-manager-certificates.chart" . }}
{{ include "cert-manager-certificates.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cert-manager-certificates.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cert-manager-certificates.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
