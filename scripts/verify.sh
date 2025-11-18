#!/bin/bash

# ==============================================================================
# Verify Script - Verificación de Instalación
# Versión: 2.0.0
# Descripción: Verifica la instalación y configuración de Terminal Setup
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
VERBOSE=false
CHECK_CONFIGS=true
RUN_TESTS=true

# Contadores
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# ==============================================================================
# Funciones de Ayuda
# ==============================================================================

show_help() {
    cat << EOF
Verify Terminal Setup v${VERSION}

Verifica la instalación y configuración de Neofetch y Starship.

USO:
    $0 [OPCIONES]

OPCIONES:
    --skip-configs        No verificar archivos de configuración
    --skip-tests          No ejecutar tests de funcionalidad
    -v, --verbose         Mostrar información detallada
    -h, --help            Mostrar esta ayuda

EOF
}

# ==============================================================================
# Funciones de Verificación
# ==============================================================================

check_pass() {
    ((TOTAL_CHECKS++))
    ((PASSED_CHECKS++))
    log_success "$1"
}

check_fail() {
    ((TOTAL_CHECKS++))
    ((FAILED_CHECKS++))
    log_error "$1"
}

check_warn() {
    ((TOTAL_CHECKS++))
    ((WARNING_CHECKS++))
    log_warn "$1"
}

verify_system_info() {
    log_subheader "Información del Sistema"

    echo "Sistema Operativo: $(get_distro_name) $(get_distro_version)"
    echo "Kernel: $(uname -r)"
    echo "Arquitectura: $(uname -m)"
    echo "Usuario: $USER"
    echo "Home: $HOME"
    echo "Shell: $(get_user_shell)"
    echo "Shell RC: $(get_shell_rc_file)"
    echo ""
}

verify_neofetch_installation() {
    log_subheader "Verificando Neofetch"

    # Verificar si está instalado
    if command_exists neofetch; then
        local version
        version=$(timeout 10s neofetch --version 2>&1 | head -n1 || echo "No se pudo obtener versión")
        if [[ "$version" != "No se pudo obtener versión" ]]; then
            check_pass "Neofetch está instalado: $version"
        else
            # Intentar con otro comando por si --version tiene problemas
            if timeout 5s neofetch --help &> /dev/null || timeout 5s neofetch --stdout &> /dev/null; then
                check_pass "Neofetch está instalado: disponible pero no responde a --version"
            else
                check_fail "Neofetch NO está instalado o no se puede ejecutar"
                return 1
            fi
        fi

        # Verificar ubicación
        local location
        location=$(command -v neofetch)
        log_info "Ubicación: $location"

        # Verificar que se puede ejecutar con un comando básico
        if timeout 5s neofetch --version &> /dev/null; then
            check_pass "Neofetch es ejecutable"
        else
            # Verificar con otro comando por si --help tiene problemas
            if timeout 5s neofetch --stdout &> /dev/null; then
                check_pass "Neofetch es ejecutable"
            else
                check_fail "Neofetch no se puede ejecutar correctamente"
            fi
        fi
    else
        check_fail "Neofetch NO está instalado"
        return 1
    fi
}

verify_starship_installation() {
    log_subheader "Verificando Starship"

    # Verificar si está instalado
    if command_exists starship; then
        local version
        version=$(timeout 10s starship --version 2>&1 | head -n1 || echo "No se pudo obtener versión")
        if [[ "$version" != "No se pudo obtener versión" ]]; then
            check_pass "Starship está instalado: $version"
        else
            # Intentar con otro comando por si --version tiene problemas
            if timeout 5s starship init bash &> /dev/null || timeout 5s starship --help &> /dev/null; then
                check_pass "Starship está instalado: disponible pero no responde a --version"
            else
                check_fail "Starship NO está instalado o no se puede ejecutar"
                return 1
            fi
        fi

        # Verificar ubicación
        local location
        location=$(command -v starship)
        log_info "Ubicación: $location"

        # Verificar que se puede ejecutar con un comando básico
        if timeout 5s starship --version &> /dev/null; then
            check_pass "Starship es ejecutable"
        else
            # Verificar con otro comando por si --help tiene problemas
            if timeout 5s starship init bash &> /dev/null; then
                check_pass "Starship es ejecutable"
            else
                check_fail "Starship no se puede ejecutar correctamente"
            fi
        fi
    else
        check_fail "Starship NO está instalado"
        return 1
    fi
}

verify_shell_configuration() {
    log_subheader "Verificando Configuración del Shell"

    local rc_file
    rc_file=$(get_shell_rc_file)

    # Verificar archivo RC existe
    if [[ -f "$rc_file" ]]; then
        check_pass "Archivo RC encontrado: $rc_file"
    else
        check_fail "Archivo RC no encontrado: $rc_file"
        return 1
    fi

    # Verificar Neofetch en RC
    if command_exists neofetch; then
        if grep -q "neofetch" "$rc_file"; then
            check_pass "Neofetch configurado en shell"

            # Verificar formato de configuración
            if grep -q "^neofetch$" "$rc_file" || grep -q "^neofetch " "$rc_file"; then
                log_debug "Configuración de Neofetch es correcta"
            else
                check_warn "Configuración de Neofetch podría estar comentada"
            fi
        else
            check_warn "Neofetch NO configurado en shell RC"
        fi
    fi

    # Verificar Starship en RC
    if command_exists starship; then
        local shell
        shell=$(get_user_shell)

        case "$shell" in
            bash)
                if grep -q 'eval "$(starship init bash)"' "$rc_file"; then
                    check_pass "Starship configurado correctamente para Bash"
                else
                    check_warn "Starship NO configurado en shell RC"
                fi
                ;;
            zsh)
                if grep -q 'eval "$(starship init zsh)"' "$rc_file"; then
                    check_pass "Starship configurado correctamente para Zsh"
                else
                    check_warn "Starship NO configurado en shell RC"
                fi
                ;;
            fish)
                if grep -q "starship init fish" "$rc_file"; then
                    check_pass "Starship configurado correctamente para Fish"
                else
                    check_warn "Starship NO configurado en shell RC"
                fi
                ;;
            *)
                check_warn "Shell no reconocido para verificación de Starship: $shell"
                ;;
        esac
    fi

    # Verificar PATH si hay instalación local
    local local_bin="$HOME/.local/bin"
    if [[ -d "$local_bin" ]] && { [[ -f "$local_bin/neofetch" ]] || [[ -f "$local_bin/starship" ]]; }; then
        if grep -q "$local_bin" "$rc_file" || [[ ":$PATH:" == *":$local_bin:"* ]]; then
            check_pass "PATH incluye directorio local bin"
        else
            check_warn "PATH no incluye $local_bin (podría requerirse reinicio de shell)"
        fi
    fi
}

verify_configurations() {
    if [[ "$CHECK_CONFIGS" == "false" ]]; then
        return 0
    fi

    log_subheader "Verificando Archivos de Configuración"

    local config_dir="$HOME/.config"

    # Verificar configuración de Neofetch
    if command_exists neofetch; then
        local neofetch_config="$config_dir/neofetch/config.conf"

        if [[ -f "$neofetch_config" ]]; then
            check_pass "Configuración de Neofetch existe"

            # Verificar que es válida
            if [[ -r "$neofetch_config" ]]; then
                log_debug "Configuración de Neofetch es legible"
            else
                check_warn "Configuración de Neofetch no es legible"
            fi
        else
            check_warn "Configuración personalizada de Neofetch no existe (usará predeterminada)"
        fi
    fi

    # Verificar configuración de Starship
    if command_exists starship; then
        local starship_config="$config_dir/starship.toml"

        if [[ -f "$starship_config" ]]; then
            check_pass "Configuración de Starship existe"

            # Verificar sintaxis TOML básica
            if grep -q '\[' "$starship_config" 2>/dev/null; then
                log_debug "Configuración de Starship tiene formato TOML válido"

                # Verificar algunas secciones comunes
                local sections=("character" "directory" "git_branch")
                for section in "${sections[@]}"; do
                    if grep -q "\[$section\]" "$starship_config"; then
                        log_debug "Sección [$section] encontrada"
                    fi
                done
            else
                check_warn "Configuración de Starship podría tener formato inválido"
            fi
        else
            check_warn "Configuración personalizada de Starship no existe (usará predeterminada)"
        fi
    fi
}

run_functionality_tests() {
    if [[ "$RUN_TESTS" == "false" ]]; then
        return 0
    fi

    log_subheader "Ejecutando Tests de Funcionalidad"

    # Test Neofetch
    if command_exists neofetch; then
        log_step "Ejecutando Neofetch..."

        if timeout 10s neofetch --stdout &> /dev/null; then
            check_pass "Neofetch ejecuta correctamente"
        else
            check_fail "Neofetch falló al ejecutar"
        fi
    fi

    # Test Starship
    if command_exists starship; then
        log_step "Probando Starship..."

        # Verificar que puede generar prompt
        local shell
        shell=$(get_user_shell)

        case "$shell" in
            bash|zsh)
                if timeout 5s starship prompt &> /dev/null; then
                    check_pass "Starship genera prompt correctamente"
                else
                    check_warn "Starship tardó mucho o falló generando prompt"
                fi
                ;;
            *)
                log_info "Test de prompt omitido para shell: $shell"
                ;;
        esac

        # Verificar configuración
        if starship config &> /dev/null; then
            log_debug "Starship puede leer su configuración"
        else
            check_warn "Problema al leer configuración de Starship"
        fi
    fi
}

verify_permissions() {
    log_subheader "Verificando Permisos"

    # Verificar permisos de binarios
    if command_exists neofetch; then
        local neofetch_path
        neofetch_path=$(command -v neofetch)

        if [[ -x "$neofetch_path" ]]; then
            check_pass "Neofetch tiene permisos de ejecución"
        else
            check_fail "Neofetch NO tiene permisos de ejecución"
        fi
    fi

    if command_exists starship; then
        local starship_path
        starship_path=$(command -v starship)

        if [[ -x "$starship_path" ]]; then
            check_pass "Starship tiene permisos de ejecución"
        else
            check_fail "Starship NO tiene permisos de ejecución"
        fi
    fi

    # Verificar permisos de configuraciones
    local rc_file
    rc_file=$(get_shell_rc_file)

    if [[ -f "$rc_file" ]]; then
        if [[ -r "$rc_file" && -w "$rc_file" ]]; then
            log_debug "Archivo RC tiene permisos correctos"
        else
            check_warn "Archivo RC podría tener problemas de permisos"
        fi
    fi
}

check_for_issues() {
    log_subheader "Verificando Problemas Comunes"

    # Verificar shells múltiples
    local user_shell
    user_shell=$(get_user_shell)

    if [[ "$SHELL" != *"$user_shell"* ]]; then
        check_warn "Shell activo ($SHELL) difiere del shell del usuario ($user_shell)"
    fi

    # Verificar conflictos de PATH
    local neofetch_count
    neofetch_count=$(echo "$PATH" | tr ':' '\n' | xargs -I {} find {} -maxdepth 1 -name "neofetch" 2>/dev/null | wc -l)

    if [[ $neofetch_count -gt 1 ]]; then
        check_warn "Múltiples instalaciones de Neofetch encontradas en PATH"
    fi

    local starship_count
    starship_count=$(echo "$PATH" | tr ':' '\n' | xargs -I {} find {} -maxdepth 1 -name "starship" 2>/dev/null | wc -l)

    if [[ $starship_count -gt 1 ]]; then
        check_warn "Múltiples instalaciones de Starship encontradas en PATH"
    fi

    # Verificar backups antiguos
    local rc_file
    rc_file=$(get_shell_rc_file)

    local backup_count
    backup_count=$(find "$(dirname "$rc_file")" -name "$(basename "$rc_file").backup*" 2>/dev/null | wc -l)

    if [[ $backup_count -gt 5 ]]; then
        check_warn "Muchos archivos de backup encontrados ($backup_count). Considera limpiarlos."
    fi
}

# ==============================================================================
# Reporte Final
# ==============================================================================

print_summary() {
    log_header "📊 Resumen de Verificación"

    echo ""
    echo "Total de verificaciones: $TOTAL_CHECKS"
    print_color "$COLOR_GREEN" "  ✅ Pasadas: $PASSED_CHECKS"

    if [[ $FAILED_CHECKS -gt 0 ]]; then
        print_color "$COLOR_RED" "  ❌ Fallidas: $FAILED_CHECKS"
    fi

    if [[ $WARNING_CHECKS -gt 0 ]]; then
        print_color "$COLOR_YELLOW" "  ⚠️  Advertencias: $WARNING_CHECKS"
    fi

    echo ""

    # Calcular porcentaje de éxito
    local success_rate=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    fi

    if [[ $FAILED_CHECKS -eq 0 ]]; then
        log_success "✓ Verificación completada exitosamente (${success_rate}% exitoso)"
        return 0
    elif [[ $FAILED_CHECKS -lt 3 ]]; then
        log_warn "Verificación completada con algunos problemas (${success_rate}% exitoso)"
        return 1
    else
        log_error "Verificación encontró problemas significativos (${success_rate}% exitoso)"
        return 2
    fi
}

# ==============================================================================
# Función Principal
# ==============================================================================

run_verification() {
    log_header "🔍 Verificación de Terminal Setup"

    # Información del sistema
    if [[ "$VERBOSE" == "true" ]]; then
        verify_system_info
    fi

    # Verificar instalaciones
    verify_neofetch_installation
    verify_starship_installation

    # Verificar configuración del shell
    verify_shell_configuration

    # Verificar archivos de configuración
    verify_configurations

    # Verificar permisos
    verify_permissions

    # Tests de funcionalidad
    run_functionality_tests

    # Verificar problemas comunes
    check_for_issues

    # Mostrar resumen
    echo ""
    print_summary
}

# ==============================================================================
# Parseo de Argumentos
# ==============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-configs)
                CHECK_CONFIGS=false
                shift
                ;;
            --skip-tests)
                RUN_TESTS=false
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
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
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    # Configurar manejo de errores
    setup_error_handling

    # Parsear argumentos
    parse_arguments "$@"

    # Ejecutar verificación
    run_verification
    local exit_code=$?

    # Mostrar resumen de logs
    print_log_summary

    exit $exit_code
}

main "$@"
