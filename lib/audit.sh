#!/usr/bin/env bash
# BLUMIX audit: comprobaciones locales, limitadas y de solo lectura.
# No eleva privilegios, no contacta la red y no cambia archivos.
blumix_audit() {
    local output="${1:-text}" config="${BLUMIX_CONFIG:-$BLUMIX_ROOT/config/blumix.conf}"
    local mode=0 config_status="info" secret_status="pass" git_status="info"
    local secret_found=0 git_root=0
    local -a ids=(config_permissions secret_like_files repository_state)
    local -a statuses details
    local i pass_count=0 warn_count=0 info_count=0

    if [[ "$output" != "text" && "$output" != "json" ]]; then
        printf 'Uso: blumix audit [--json]\n' >&2
        return 2
    fi

    if [[ -e "$config" || -L "$config" ]]; then
        if [[ -L "$config" ]]; then
            config_status="warn"
            config_detail="La configuración es un enlace simbólico; revisa su destino antes de cargarla."
        elif [[ ! -f "$config" || ! -r "$config" ]]; then
            config_status="warn"
            config_detail="La configuración existe pero no es un archivo regular legible."
        elif blumix_command_exists stat; then
            mode="$(stat -c '%a' -- "$config" 2>/dev/null || printf '0')"
            if [[ "$mode" =~ ^[0-7]{3,4}$ ]]; then
                if (( (8#$mode & 077) != 0 )); then
                    config_status="warn"
                    config_detail="La configuración permite acceso a grupo u otros; considera chmod 600."
                else
                    config_status="pass"
                    config_detail="Los permisos de la configuración limitan el acceso al propietario."
                fi
            else
                config_status="info"
                config_detail="No se pudieron verificar los permisos de la configuración."
            fi
        else
            config_status="info"
            config_detail="stat no está disponible; no se verificaron permisos."
        fi
    else
        config_status="info"
        config_detail="No existe configuración local; se usan valores predeterminados o variables de entorno."
    fi

    secret_match=""
    for pattern in '.env' 'id_rsa' 'id_ed25519' '*.pem' '*.key' '*.p12' '*.pfx' 'vault.blx'; do
        secret_match="$(find "$BLUMIX_ROOT" -path "$BLUMIX_ROOT/.git" -prune -o -type f -name "$pattern" -print -quit 2>/dev/null)"
        [[ -n "$secret_match" ]] && break
    done
    if [[ -n "$secret_match" ]]; then
        secret_status="warn"
        secret_detail="Se encontró un nombre de archivo que suele contener secretos; revisa manualmente sin imprimir su contenido."
    else
        secret_detail="No se encontraron nombres de archivo de alto riesgo en el repositorio BLUMIX; esto no demuestra que no haya secretos."
    fi

    if [[ -d "$BLUMIX_ROOT/.git" ]]; then
        git_root=1
        git_status="pass"
        git_detail="Existe metadato Git local; revisa el diff y el historial antes de publicar."
    else
        git_status="info"
        git_detail="No se detectó .git (posible copia de distribución); no se evaluó el historial."
    fi

    statuses=("$config_status" "$secret_status" "$git_status")
    details=("$config_detail" "$secret_detail" "$git_detail")
    for status in "${statuses[@]}"; do
        case "$status" in
            pass) pass_count=$((pass_count + 1)) ;;
            warn) warn_count=$((warn_count + 1)) ;;
            *) info_count=$((info_count + 1)) ;;
        esac
    done

    if [[ "$output" == "json" ]]; then
        printf '{\n  "schema": "blumix.audit.v1",\n  "read_only": true,\n  "network_access": false,\n  "checks": [\n'
        for ((i=0; i<${#ids[@]}; i++)); do
            printf '    {"id":"%s","status":"%s","detail":"%s"}' "${ids[$i]}" "${statuses[$i]}" "${details[$i]}"
            (( i + 1 < ${#ids[@]} )) && printf ','
            printf '\n'
        done
        printf '  ],\n  "summary": {"pass": %d, "warn": %d, "info": %d},\n' "$pass_count" "$warn_count" "$info_count"
        printf '  "limitations": "Local heuristics only; not a complete security audit and not proof of system safety."\n}\n'
        return 0
    fi

    blx_title "BLUMIX AUDIT — COMPROBACIONES LOCALES"
    for ((i=0; i<${#ids[@]}; i++)); do
        case "${statuses[$i]}" in
            pass) blx_row "[OK] ${ids[$i]}: ${details[$i]}" ;;
            warn) blx_warn "[REVISAR] ${ids[$i]}: ${details[$i]}" ;;
            *) blx_row "[INFO] ${ids[$i]}: ${details[$i]}" ;;
        esac
    done
    printf '\nResumen: %d OK · %d revisar · %d informativo\n' "$pass_count" "$warn_count" "$info_count"
    printf 'Alcance: heurísticas locales, sin red ni cambios; no es una auditoría completa.\n'
    (( warn_count == 0 ))
}
