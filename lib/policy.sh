#!/usr/bin/env bash
# BLUMIX policy catalog: capability declaration only; no privileged execution.
# Unknown operations are denied. This module never invokes sudo, systemctl, or a shell.
blumix_policy() {
    local output="${1:-text}"
    case "$output" in
        text)
            printf 'BLUMIX — catálogo de capacidades y privilegios\n\n'
            printf 'Modo: DENY BY DEFAULT · AGENTE NO IMPLEMENTADO · SIN ELEVACIÓN\n\n'
            printf '%-24s %-14s %s\n' 'CAPACIDAD' 'ESTADO' 'LÍMITE'
            printf '%-24s %-14s %s\n' 'inspect_system' 'DISPONIBLE' 'Solo lectura; datos locales.'
            printf '%-24s %-14s %s\n' 'inspect_integrations' 'DISPONIBLE' 'Detecta directorios; no verifica salud.'
            printf '%-24s %-14s %s\n' 'inspect_security' 'DISPONIBLE' 'Diagnóstico local; no aplica cambios.'
            printf '%-24s %-14s %s\n' 'restart_service' 'BLOQUEADA' 'Agente y lista de servicios aún no configurados.'
            printf '%-24s %-14s %s\n' 'apply_system_change' 'BLOQUEADA' 'Requiere política, aprobación y plan de reversión.'
            printf '%-24s %-14s %s\n' 'run_shell' 'DENEGADA' 'No existe ejecución de shell arbitraria en la API.'
            printf '\nNinguna capacidad de este catálogo ejecuta acciones privilegiadas.\n'
            ;;
        json)
            cat <<'JSON'
{
  "schema": "blumix.policy.v1",
  "policy_version": 1,
  "default_deny": true,
  "privileged_agent": {
    "state": "not_implemented",
    "connected": false,
    "elevation_enabled": false
  },
  "operations": [
    {"id":"inspect_system","class":"read_only","status":"available","requires_elevation":false,"requires_approval":false},
    {"id":"inspect_integrations","class":"read_only","status":"available","requires_elevation":false,"requires_approval":false},
    {"id":"inspect_security","class":"read_only","status":"available","requires_elevation":false,"requires_approval":false},
    {"id":"restart_service","class":"privileged","status":"blocked","requires_elevation":true,"requires_approval":true,"service_allowlist_configured":false},
    {"id":"apply_system_change","class":"privileged","status":"blocked","requires_elevation":true,"requires_approval":true,"rollback_required":true},
    {"id":"run_shell","class":"forbidden","status":"denied","requires_elevation":false,"requires_approval":false}
  ],
  "safety": {
    "executes_operations": false,
    "uses_network": false,
    "invokes_sudo": false,
    "accepts_arbitrary_arguments": false
  }
}
JSON
            ;;
        *)
            printf 'Salida de política no admitida.\n' >&2
            return 2
            ;;
    esac
}
