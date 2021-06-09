{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "collector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "collector.fullname" -}}
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
Return the db hostname
If an external postgresl host is provided, it will use that, otherwise it will fallback
to the service name. Failing a specified service name it will fall back to the default service name.

This overrides the upstream postegresql chart so that we can deterministically
use the name of the service the upstream chart creates
*/}}
{{- define "collector.postgresql.host" -}}
{{- if .Values.postgresql.host -}}
{{- .Values.postgresql.host -}}
{{- else if .Values.postgresql.serviceName -}}
{{- .Values.postgresql.serviceName -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "collector.postgresql.fullname" -}}
{{- template "collector.postgresql.host" . -}}
{{- end -}}


{{/*
Return the redis hostname
If an external redis host is provided, it will use that, otherwise it will fallback
to the service name. Failing a specified service name it will fall back to the default service name.

This overrides the upstream redis chart so that we can deterministically
use the name of the service the upstream chart creates
*/}}
{{- define "collector.redis.host" -}}
{{- if .Values.redis.host -}}
{{- .Values.redis.host -}}
{{- else if .Values.redis.serviceName -}}
{{- .Values.redis.serviceName -}}
{{- else -}}
{{- $name := default "redis" .Values.redis.nameOverride -}}
{{- printf "%s-%s-master" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "collector.redis.fullname" -}}
{{- template "collector.redis.host" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "collector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "collector.metaLabels" -}}
apps.kubernetes.io/app: {{ template "collector.name" . }}
helm.sh/chart: {{ template "collector.chart" . }}
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "collector.labels" -}}
helm.sh/chart: {{ include "collector.chart" . }}
{{ include "collector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "collector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "collector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "collector.wait-for-db" -}}
- name: wait-for-db
  image: "{{ .Values.waitImage.repository }}:{{ .Values.waitImage.tag }}"
  imagePullPolicy: {{ .Values.waitImage.pullPolicy }}
  env:
  - name: COLLECTOR_PG_HOST
    value: {{ template "collector.postgresql.fullname" . }}
  - name: COLLECTOR_PG_PORT
    value: "{{ .Values.postgresql.service.port }}"
  command: [ "/bin/sh", "-c", "until nc -zv $COLLECTOR_PG_HOST $COLLECTOR_PG_PORT -w1; do echo 'waiting for db'; sleep 1; done" ]
{{- end -}}

{{- define "collector.wait-for-redis" -}}
- name: wait-for-redis
  image: "{{ .Values.waitImage.repository }}:{{ .Values.waitImage.tag }}"
  imagePullPolicy: {{ .Values.waitImage.pullPolicy }}
  env:
  - name: REDIS_HOST
    value: "{{ template "collector.redis.fullname" . }}"
  - name: REDIS_PORT
    value: "{{ .Values.redis.port }}"
  command: [ "/bin/sh", "-c", "until nc -zv $REDIS_HOST $REDIS_PORT -w1; do echo 'waiting for db'; sleep 1; done" ]
{{- end -}}
