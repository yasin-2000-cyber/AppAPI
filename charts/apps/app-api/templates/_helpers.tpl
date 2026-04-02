{{/*
Expand the name of the chart.
*/}}
{{- define "app-api.name" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app-api.labels" -}}
app.kubernetes.io/name: {{ include "app-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL service hostname (Bitnami subchart)
*/}}
{{- define "app-api.postgresHost" -}}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}

{{/*
Redis service hostname (Bitnami subchart)
*/}}
{{- define "app-api.redisHost" -}}
{{- printf "%s-redis-master" .Release.Name }}
{{- end }}
