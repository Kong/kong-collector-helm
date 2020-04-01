{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kong-collectorapi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kong-collectorapi.fullname" -}}
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
{{- define "kong-collectorapi.postgresql.host" -}}
{{- if .Values.postgresql.host -}}
{{- .Values.postgresql.host -}}
{{- else if .Values.postgresql.serviceName -}}
{{- .Values.postgresql.serviceName -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "kong-collectorapi.postgresql.fullname" -}}
{{- template "kong-collectorapi.postgresql.host" . -}}
{{- end -}}


{{/*
Return the redis hostname
If an external redis host is provided, it will use that, otherwise it will fallback
to the service name. Failing a specified service name it will fall back to the default service name.

This overrides the upstream redis chart so that we can deterministically
use the name of the service the upstream chart creates
*/}}
{{- define "kong-collectorapi.redis.host" -}}
{{- if .Values.redis.host -}}
{{- .Values.redis.host -}}
{{- else if .Values.redis.serviceName -}}
{{- .Values.redis.serviceName -}}
{{- else -}}
{{- $name := default "redis" .Values.redis.nameOverride -}}
{{- printf "%s-%s-master" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "kong-collectorapi.redis.fullname" -}}
{{- template "kong-collectorapi.redis.host" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kong-collectorapi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kong-collectorapi.metaLabels" -}}
apps.kubernetes.io/app: {{ template "kong-collectorapi.name" . }}
helm.sh/chart: {{ template "kong-collectorapi.chart" . }}
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "kong-collectorapi.labels" -}}
helm.sh/chart: {{ include "kong-collectorapi.chart" . }}
{{ include "kong-collectorapi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "kong-collectorapi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kong-collectorapi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "kong-collectorapi.wait-for-db" -}}
- name: wait-for-db
  image: "{{ .Values.waitImage.repository }}:{{ .Values.waitImage.tag }}"
  imagePullPolicy: {{ .Values.waitImage.pullPolicy }}
  env:
  - name: COLLECTOR_PG_HOST
    value: {{ template "kong-collectorapi.postgresql.fullname" . }}
  - name: COLLECTOR_PG_PORT
    value: "{{ .Values.postgresql.service.port }}"
  command: [ "/bin/sh", "-c", "until nc -zv $COLLECTOR_PG_HOST $COLLECTOR_PG_PORT -w1; do echo 'waiting for db'; sleep 1; done" ]
{{- end -}}

{{- define "kong-collectorapi.wait-for-kong" -}}
- name: wait-for-kong
  image: "{{ .Values.waitImage.repository }}:{{ .Values.waitImage.tag }}"
  imagePullPolicy: {{ .Values.waitImage.pullPolicy }}
  env:
  - name: KONG_ADMIN_HOST
    value: "{{ .Values.kongAdmin.host }}"
  - name: KONG_ADMIN_PORT
    value: "{{ .Values.kongAdmin.servicePort }}"
  - name: KONG_ADMIN_TOKEN
    valueFrom:
      secretKeyRef:
        name: kong-admin-token-secret
        key: kong-admin-token
  command: [ "/bin/sh", "-c", "wget $KONG_ADMIN_HOST:$KONG_ADMIN_PORT --header=kong-admin-token:$KONG_ADMIN_TOKEN" ]
{{- end -}}

{{- define "kong-collectorapi.wait-for-redis" -}}
- name: wait-for-redis
  image: "{{ .Values.waitImage.repository }}:{{ .Values.waitImage.tag }}"
  imagePullPolicy: {{ .Values.waitImage.pullPolicy }}
  env:
  - name: REDIS_HOST
    value: "{{ template "kong-collectorapi.redis.fullname" . }}"
  - name: REDIS_PORT
    value: "{{ .Values.redis.port }}"
  command: [ "/bin/sh", "-c", "until nc -zv $REDIS_HOST $REDIS_PORT -w1; do echo 'waiting for db'; sleep 1; done" ]
{{- end -}}
