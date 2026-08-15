#!/usr/bin/env bash
blumix_integrations() {
    blx_title "🧩 INTEGRACIONES"
    [[ -d "$BLUMCL_HOME" ]] && blx_row "✅ BLUMCL: $BLUMCL_HOME" || blx_row "❌ BLUMCL: no encontrado"
    [[ -d "$BLUMSEC_HOME" ]] && blx_row "✅ BLUMSEC: $BLUMSEC_HOME" || blx_row "❌ BLUMSEC: no encontrado"
    blx_bottom
}
