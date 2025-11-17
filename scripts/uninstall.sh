#!/bin/bash

# ==============================================================================
# Uninstall Script - Desinstalación de Terminal Setup
# Versión: 2.0.0
# Descripción: Desinstalación completa y limpia de Neofetch y Starship
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Configuración
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Sourcing de bibliotecas
source "${LIB_DIR}/colors.sh"
source "${LIB_DIR}/logger.sh"
source "${LIB_DIR}/utils.sh"

# Obtener versión del proyecto
VERSION=$(get_project_version)

# Variables
DRY_RUN=false
REMOVE_CONFIG=false
SKIP_CONFIRMATION=false
UNINSTALL_NEOFETCH=true
UNINSTALL_STARSHIP=true

# Directorios
SYSTEM_BIN_DIR="/usr/local/bin"
LOCAL_BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"

# ==============================================================================
# Funciones de Ayuda
# ==============================================================================

show_help() {
    cat << EOF
Uninstall Terminal Setup v${VERSION}

Desinstala Neofetch y Starship del sistema.

USO:
    $0 [OPCIONES]

OPCIONES:
    --remove-config       Eliminar también archivos de configuración
    --skip-neofetch       No desinstalar Neofetch
    --skip-starship       No desinstalar Starship
    -d, --dry-run         Simular desinstalación sin ejecutar
    -y, --yes             Aceptar todas las confirmaciones
    -h, --help            Mostrar esta ayuda

EJEMPLOS:
    # Desinstalación estándar (mantiene configuraciones)
    sudo $0

    # Desinstalación completa (incluye configuraciones)
    sudo $0 --remove-config

    # Desinstalar solo Starship
    sudo $0 --skip-neofetch

EOF
}

# ==============================================================================
# Funciones de Desinstalación
# ==============================================================================

remove_from_shell_rc() {
    local pattern="$1"
    local description="$2"
    local rc_file
    rc_file=$(get_shell_rc_file)

    if [[ ! -f "$rc_file" ]]; then
        log_warn "Archivo RC no encontrado: $rc_file"
        return 0
    fi

    log_step "Removiendo $description de $rc_file..."

    if grep -q "$pattern" "$rc_file" 2>/dev/null; then
        if [[ "$DRY_RUN" == "false" ]]; then
            # Crear backup antes de modificar
            backup_file "$rc_file"

            # Remover líneas que coincidan con el patrón
            sed -i.uninstall "/$pattern/d" "$rc_file"

            # Limpiar líneas vacías consecutivas
            sed -i.uninstall '/^$/N;/^\n$/D' "$rc_file"

            # Remover archivo de backup temporal
            rm -f "${rc_file}.uninstall"

            log_success "$description removido de $rc_file"
        else
            log_info "[DRY-RUN] Se removería $description de $rc_file"
        fi
    else
        log_info "$description no encontrado en $rc_file"
    fi
}

uninstall_neofetch() {
    log_subheader "Desinstalando Neofetch"

    local found=false

    # Verificar instalación de sistema
    if [[ -f "$SYSTEM_BIN_DIR/neofetch" ]]; then
        found=true
        log_step "Removiendo Neofetch de $SYSTEM_BIN_DIR..."

        if [[ "$DRY_RUN" == "false" ]]; then
            local privilege_cmd
            privilege_cmd=$(get_privilege_cmd) || {
                log_error "Se requieren privilegios de superusuario"
                return 1
            }

            run_cmd "Remover Neofetch (sistema)" "$privilege_cmd rm -f $SYSTEM_BIN_DIR/neofetch"
            log_success "Neofetch removido de $SYSTEM_BIN_DIR"
        else
            log_info "[DRY-RUN] Se removería $SYSTEM_BIN_DIR/neofetch"
        fi
    fi

    # Verificar instalación local
    if [[ -f "$LOCAL_BIN_DIR/neofetch" ]]; then
        found=true
        log_step "Removiendo Neofetch de $LOCAL_BIN_DIR..."

        if [[ "$DRY_RUN" == "false" ]]; then
            rm -f "$LOCAL_BIN_DIR/neofetch"
            log_success "Neofetch removido de $LOCAL_BIN_DIR"
        else
            log_info "[DRY-RUN] Se removería $LOCAL_BIN_DIR/neofetch"
        fi
    fi

    # Verificar instalación via apt
    if package_installed neofetch 2>/dev/null; then
        found=true
        log_step "Removiendo Neofetch instalado via apt..."

        if [[ "$DRY_RUN" == "false" ]]; then
            local privilege_cmd
            privilege_cmd=$(get_privilege_cmd) || {
                log_error "Se requieren privilegios de superusuario"
                return 1
            }

            run_cmd "Desinstalar Neofetch (apt)" "$privilege_cmd apt-get remove -y neofetch"
            log_success "Neofetch desinstalado via apt"
        else
            log_info "[DRY-RUN] Se desinstalaría Neofetch via apt"
        fi
    fi

    if [[ "$found" == "false" ]]; then
        log_info "Neofetch no está instalado"
    fi

    # Remover de shell RC
    remove_from_shell_rc "neofetch" "Neofetch"

    # Remover configuración si se solicita
    if [[ "$REMOVE_CONFIG" == "true" ]]; then
        local neofetch_config_dir="$CONFIG_DIR/neofetch"

        if [[ -d "$neofetch_config_dir" ]]; then
            log_step "Removiendo configuración de Neofetch..."

            if [[ "$DRY_RUN" == "false" ]]; then
                rm -rf "$neofetch_config_dir"
                log_success "Configuración de Neofetch removida"
            else
                log_info "[DRY-RUN] Se removería $neofetch_config_dir"
            fi
        fi
    else
        log_info "Configuración de Neofetch conservada (usa --remove-config para eliminarla)"
    fi
}

uninstall_starship() {
    log_subheader "Desinstalando Starship"

    local found=false

    # Verificar instalación de sistema
    if [[ -f "$SYSTEM_BIN_DIR/starship" ]]; then
        found=true
        log_step "Removiendo Starship de $SYSTEM_BIN_DIR..."

        if [[ "$DRY_RUN" == "false" ]]; then
            local privilege_cmd
            privilege_cmd=$(get_privilege_cmd) || {
                log_error "Se requieren privilegios de superusuario"
                return 1
            }

            run_cmd "Remover Starship (sistema)" "$privilege_cmd rm -f $SYSTEM_BIN_DIR/starship"
            log_success "Starship removido de $SYSTEM_BIN_DIR"
        else
            log_info "[DRY-RUN] Se removería $SYSTEM_BIN_DIR/starship"
        fi
    fi

    # Verificar instalación local
    if [[ -f "$LOCAL_BIN_DIR/starship" ]]; then
        found=true
        log_step "Removiendo Starship de $LOCAL_BIN_DIR..."

        if [[ "$DRY_RUN" == "false" ]]; then
            rm -f "$LOCAL_BIN_DIR/starship"
            log_success "Starship removido de $LOCAL_BIN_DIR"
        else
            log_info "[DRY-RUN] Se removería $LOCAL_BIN_DIR/starship"
        fi
    fi

    if [[ "$found" == "false" ]]; then
        log_info "Starship no está instalado"
    fi

    # Remover de shell RC
    remove_from_shell_rc "starship init" "Starship"

    # Remover configuración si se solicita
    if [[ "$REMOVE_CONFIG" == "true" ]]; then
        local starship_config="$CONFIG_DIR/starship.toml"

        if [[ -f "$starship_config" ]]; then
            log_step "Removiendo configuración de Starship..."

            if [[ "$DRY_RUN" == "false" ]]; then
                rm -f "$starship_config"
                log_success "Configuración de Starship removida"
            else
                log_info "[DRY-RUN] Se removería $starship_config"
            fi
        fi

        # Remover cache de Starship
        local starship_cache="$HOME/.cache/starship"
        if [[ -d "$starship_cache" ]]; then
            if [[ "$DRY_RUN" == "false" ]]; then
                rm -rf "$starship_cache"
                log_debug "Cache de Starship removido"
            fi
        fi
    else
        log_info "Configuración de Starship conservada (usa --remove-config para eliminarla)"
    fi
}

cleanup_shell_rc() {
    log_subheader "Limpiando archivos de configuración del shell"

    local rc_file
    rc_file=$(get_shell_rc_file)

    if [[ ! -f "$rc_file" ]]; then
        return 0
    fi

    # Remover comentarios huérfanos
    log_step "Limpiando comentarios y líneas vacías..."

    if [[ "$DRY_RUN" == "false" ]]; then
        # Remover comentarios relacionados con setup terminal si sus comandos fueron removidos
        local temp_file=$(mktemp)

        # Filtrar comentarios huérfanos
        awk '
        /^# Display system info on startup \(Neofetch\)/ {
            if (getline next_line > 0) {
                if (next_line !~ /neofetch/) {
                    next
                }
                print
                print next_line
            }
            next
        }
        /^# Starship Prompt Initialization/ {
            if (getline next_line > 0) {
                if (next_line !~ /starship init/) {
                    next
                }
                print
                print next_line
            }
            next
        }
        /^# Local bin directory/ {
            if (getline next_line > 0) {
                if (next_line !~ /export PATH.*\.local\/bin/) {
                    next
                }
                print
                print next_line
            }
            next
        }
        { print }
        ' "$rc_file" > "$temp_file"

        mv "$temp_file" "$rc_file"

        log_success "Archivo RC limpiado"
    else
        log_info "[DRY-RUN] Se limpiarían comentarios huérfanos"
    fi
}

# ==============================================================================
# Función Principal
# ==============================================================================

run_uninstall() {
    log_header "🗑️  Desinstalación de Terminal Setup"

    # Confirmación
    if [[ "$SKIP_CONFIRMATION" == "false" && "$DRY_RUN" == "false" ]]; then
        echo ""
        log_warn "Esta acción desinstalará las siguientes herramientas:"
        [[ "$UNINSTALL_NEOFETCH" == "true" ]] && echo "  • Neofetch"
        [[ "$UNINSTALL_STARSHIP" == "true" ]] && echo "  • Starship"

        if [[ "$REMOVE_CONFIG" == "true" ]]; then
            echo ""
            log_warn "También se eliminarán las configuraciones personalizadas"
        fi

        echo ""

        if ! ask_yes_no "¿Deseas continuar con la desinstalación?" "n"; then
            log_info "Desinstalación cancelada por el usuario"
            exit 0
        fi
    fi

    # Crear backup de archivos RC
    local rc_file
    rc_file=$(get_shell_rc_file)

    if [[ -f "$rc_file" && "$DRY_RUN" == "false" ]]; then
        backup_file "$rc_file" ".backup.before_uninstall.$(date +%Y%m%d_%H%M%S)"
        log_info "Backup del archivo RC creado"
    fi

    # Desinstalar componentes
    if [[ "$UNINSTALL_NEOFETCH" == "true" ]]; then
        uninstall_neofetch
    fi

    if [[ "$UNINSTALL_STARSHIP" == "true" ]]; then
        uninstall_starship
    fi

    # Limpiar archivos RC
    cleanup_shell_rc

    # Mensaje final
    log_header "✨ Desinstalación Completada"

    if [[ "$DRY_RUN" == "false" ]]; then
        log_success "Herramientas desinstaladas correctamente"
        echo ""
        log_info "Para aplicar los cambios:"
        log_info "  1. Ejecuta: source $rc_file"
        log_info "  2. O cierra y abre una nueva terminal"
        echo ""

        if [[ "$REMOVE_CONFIG" == "false" ]]; then
            log_info "Las configuraciones personalizadas se conservaron"
            log_info "Puedes reinstalar sin perder tus configuraciones"
        fi

        # Mostrar backup creado
        local backup_files
        backup_files=$(find "$(dirname "$rc_file")" -name "$(basename "$rc_file").backup*" 2>/dev/null | tail -1)
        if [[ -n "$backup_files" ]]; then
            log_info "Backup disponible en: $backup_files"
        fi
    else
        log_info "[DRY-RUN] Simulación completada. No se realizaron cambios."
    fi
}

# ==============================================================================
# Parseo de Argumentos
# ==============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --remove-config)
                REMOVE_CONFIG=true
                shift
                ;;
            --skip-neofetch)
                UNINSTALL_NEOFETCH=false
                shift
                ;;
            --skip-starship)
                UNINSTALL_STARSHIP=false
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -y|--yes)
                SKIP_CONFIRMATION=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Usa --help para ver las opciones disponibles"
                exit 1
                ;;
        esac
    done

    # Validación
    if [[ "$UNINSTALL_NEOFETCH" == "false" && "$UNINSTALL_STARSHIP" == "false" ]]; then
        log_error "No hay nada que desinstalar"
        exit 1
    fi
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    # Configurar manejo de errores
    setup_error_handling

    # Parsear argumentos
    parse_arguments "$@"

    # Ejecutar desinstalación
    run_uninstall

    # Mostrar resumen
    print_log_summary

    exit 0
}

main "$@"
