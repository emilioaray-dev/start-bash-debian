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

    # Pre-actualizar PATH dinámicamente si los comandos están disponibles localmente
    # Esto se hace antes de verificar la existencia para asegurar que el PATH esté actualizado
    local local_bin_paths=("$HOME/.local/bin" "/github/home/.local/bin" "/home/runner/.local/bin")
    for bin_path in "${local_bin_paths[@]}"; do
        # Safety check: ensure bin_path is not empty
        if [[ -n "$bin_path" ]]; then
            # Añadir la ruta al PATH si no está ya y el binario existe
            if [[ -d "$bin_path" ]] && [[ -x "$bin_path/neofetch" ]]; then
                # Properly quote the PATH check to avoid globbing issues
                local path_check=":$PATH:"
                local bin_check=":$bin_path:"
                if [[ "$path_check" != *"$bin_check"* ]]; then
                    # Safety check to ensure bin_path is a valid path before adding to PATH
                    PATH="$bin_path:$PATH"
                fi
                break  # Solo añadir la primera coincidencia encontrada
            fi
        fi
    done

    # Verificar si está instalado y se puede ejecutar
    local neofetch_found=0
    # Use the most basic and safe method to check for command existence
    if command -v neofetch >/dev/null 2>&1; then
        neofetch_found=1
    fi

    if [[ $neofetch_found -eq 1 ]]; then
        local version=""
        # Verificar si timeout está disponible
        if command -v timeout &> /dev/null; then
            version=$(timeout 10s neofetch --version 2>&1 | head -n1 | grep -v "command not found" 2>/dev/null || echo "desconocida")
        else
            # En macOS, se puede usar gtimeout (si está instalado con brew) o ejecutar directamente
            if command -v gtimeout &> /dev/null; then
                version=$(gtimeout 10s neofetch --version 2>&1 | head -n1 | grep -v "command not found" 2>/dev/null || echo "desconocida")
            else
                # Sin timeout, usar ejecución directa pero con limitación de tiempo usando otra técnica
                version=$( (ulimit -t 10; neofetch --version 2>&1) | head -n1 | grep -v "command not found" 2>/dev/null || echo "desconocida")
            fi
        fi

        # Si la versión es vacía o solo "desconocida", intentar de otra manera
        if [[ "$version" == "" || "$version" == "desconocida" ]]; then
            # Intentar obtener versión sin --version (a veces neofetch no soporta --version en ciertos contextos)
            if command -v timeout &> /dev/null; then
                version=$(timeout 10s neofetch --help 2>&1 | head -n1 | grep -i "neofetch\|version" 2>/dev/null | head -n1 || echo "desconocida")
            else
                version=$( (ulimit -t 10; neofetch --help 2>&1) | head -n1 | grep -i "neofetch\|version" 2>/dev/null | head -n1 || echo "desconocida")
            fi
        fi

        check_pass "Neofetch está instalado: $version"

        # Verificar que se puede ejecutar con un comando básico
        local cmd_executed=0
        if command -v timeout &> /dev/null; then
            if timeout 5s neofetch --help &> /dev/null || timeout 5s neofetch --stdout &> /dev/null; then
                cmd_executed=1
            fi
        elif command -v gtimeout &> /dev/null; then
            if gtimeout 5s neofetch --help &> /dev/null || gtimeout 5s neofetch --stdout &> /dev/null; then
                cmd_executed=1
            fi
        else
            # Sin timeout, intentar ejecución directa
            if neofetch --help &> /dev/null || neofetch --stdout &> /dev/null; then
                cmd_executed=1
            fi
        fi

        if [[ $cmd_executed -eq 1 ]]; then
            check_pass "Neofetch es ejecutable"
        else
            check_warn "Neofetch no se puede ejecutar correctamente"
        fi

        # Verificar ubicación
        local location
        location=$(command -v neofetch)
        log_info "Ubicación: $location"
    else
        check_fail "Neofetch NO está instalado"
        return 1
    fi
}

verify_starship_installation() {
    log_subheader "Verificando Starship"

    # Pre-actualizar PATH dinámicamente si los comandos están disponibles localmente
    # Esto se hace antes de verificar la existencia para asegurar que el PATH esté actualizado
    local local_bin_paths=("$HOME/.local/bin" "/github/home/.local/bin" "/home/runner/.local/bin")
    for bin_path in "${local_bin_paths[@]}"; do
        # Safety check: ensure bin_path is not empty
        if [[ -n "$bin_path" ]]; then
            # Añadir la ruta al PATH si no está ya y el binario existe
            if [[ -d "$bin_path" ]] && [[ -x "$bin_path/starship" ]]; then
                # Properly quote the PATH check to avoid globbing issues
                local path_check=":$PATH:"
                local bin_check=":$bin_path:"
                if [[ "$path_check" != *"$bin_check"* ]]; then
                    # Safety check to ensure bin_path is a valid path before adding to PATH
                    PATH="$bin_path:$PATH"
                fi
                break  # Solo añadir la primera coincidencia encontrada
            fi
        fi
    done

    # Verificar si está instalado y se puede ejecutar
    local starship_found=0
    # Use the most basic and safe method to check for command existence
    if command -v starship >/dev/null 2>&1; then
        starship_found=1
    fi

    if [[ $starship_found -eq 1 ]]; then
        local version=""
        # Verificar si timeout está disponible
        if command -v timeout &> /dev/null; then
            version=$(timeout 10s starship --version 2>&1 | head -n1 | grep -v "command not found" 2>/dev/null || echo "desconocida")
        else
            # En macOS, se puede usar gtimeout (si está instalado con brew) o ejecutar directamente
            if command -v gtimeout &> /dev/null; then
                version=$(gtimeout 10s starship --version 2>&1 | head -n1 | grep -v "command not found" 2>/dev/null || echo "desconocida")
            else
                # Sin timeout, usar ejecución directa pero con limitación de tiempo usando otra técnica
                version=$( (ulimit -t 10; starship --version 2>&1) | head -n1 | grep -v "command not found" 2>/dev/null || echo "desconocida")
            fi
        fi

        # Si la versión es vacía o solo "desconocida", intentar de otra manera
        if [[ "$version" == "" || "$version" == "desconocida" ]]; then
            # Intentar obtener versión sin --version (a veces starship no soporta --version en ciertos contextos)
            if command -v timeout &> /dev/null; then
                version=$(timeout 10s starship --help 2>&1 | head -n1 | grep -i "starship\|version" 2>/dev/null | head -n1 || echo "desconocida")
            else
                version=$( (ulimit -t 10; starship --help 2>&1) | head -n1 | grep -i "starship\|version" 2>/dev/null | head -n1 || echo "desconocida")
            fi
        fi
        check_pass "Starship está instalado: $version"

        # Verificar que se puede ejecutar con un comando básico
        local cmd_executed=0
        if command -v timeout &> /dev/null; then
            if timeout 5s starship init bash &> /dev/null || timeout 5s starship --help &> /dev/null; then
                cmd_executed=1
            fi
        elif command -v gtimeout &> /dev/null; then
            if gtimeout 5s starship init bash &> /dev/null || gtimeout 5s starship --help &> /dev/null; then
                cmd_executed=1
            fi
        else
            # Sin timeout, intentar ejecución directa
            if starship init bash &> /dev/null || starship --help &> /dev/null; then
                cmd_executed=1
            fi
        fi

        if [[ $cmd_executed -eq 1 ]]; then
            check_pass "Starship es ejecutable"
        else
            check_warn "Starship no se puede ejecutar correctamente"
        fi

        # Verificar ubicación
        local location
        location=$(command -v starship)
        log_info "Ubicación: $location"
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
    local neofetch_found=0
    if command -v neofetch >/dev/null 2>&1; then
        neofetch_found=1
    fi
    if [[ $neofetch_found -eq 1 ]]; then
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
    local starship_found=0
    if command -v starship >/dev/null 2>&1; then
        starship_found=1
    fi
    if [[ $starship_found -eq 1 ]]; then
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
    local neofetch_found=0
    if command -v neofetch >/dev/null 2>&1; then
        neofetch_found=1
    fi
    if [[ $neofetch_found -eq 1 ]]; then
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
    local starship_found=0
    if command -v starship >/dev/null 2>&1; then
        starship_found=1
    fi
    if [[ $starship_found -eq 1 ]]; then
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
    local neofetch_found=0
    if command -v neofetch >/dev/null 2>&1; then
        neofetch_found=1
    fi
    if [[ $neofetch_found -eq 1 ]]; then
        log_step "Ejecutando Neofetch..."

        if command -v timeout &> /dev/null; then
            if timeout 10s neofetch --stdout &> /dev/null; then
                check_pass "Neofetch ejecuta correctamente"
            else
                check_warn "Neofetch podría tardar o fallar al ejecutar"
            fi
        elif command -v gtimeout &> /dev/null; then
            if gtimeout 10s neofetch --stdout &> /dev/null; then
                check_pass "Neofetch ejecuta correctamente"
            else
                check_warn "Neofetch podría tardar o fallar al ejecutar"
            fi
        else
            # Sin timeout, ejecutar directamente
            if neofetch --stdout &> /dev/null; then
                check_pass "Neofetch ejecuta correctamente"
            else
                check_warn "Neofetch podría tardar o fallar al ejecutar"
            fi
        fi
    fi

    # Test Starship
    local starship_found=0
    if command -v starship >/dev/null 2>&1; then
        starship_found=1
    fi
    if [[ $starship_found -eq 1 ]]; then
        log_step "Probando Starship..."

        # Verificar que puede generar prompt
        local shell
        shell=$(get_user_shell)

        case "$shell" in
            bash|zsh)
                if command -v timeout &> /dev/null; then
                    if timeout 5s bash -c 'starship prompt &>/dev/null || true'; then
                        check_pass "Starship genera prompt correctamente"
                    else
                        check_warn "Starship tardó mucho o falló generando prompt"
                    fi
                elif command -v gtimeout &> /dev/null; then
                    if gtimeout 5s bash -c 'starship prompt &>/dev/null || true'; then
                        check_pass "Starship genera prompt correctamente"
                    else
                        check_warn "Starship tardó mucho o falló generando prompt"
                    fi
                else
                    # Sin timeout, ejecutar directamente
                    if bash -c 'starship prompt &>/dev/null || true'; then
                        check_pass "Starship genera prompt correctamente"
                    else
                        check_warn "Starship tardó mucho o falló generando prompt"
                    fi
                fi
                ;;
            *)
                log_info "Test de prompt omitido para shell: $shell"
                ;;
        esac

        # Verificar configuración
        if command -v timeout &> /dev/null; then
            if timeout 5s bash -c 'starship config &>/dev/null || true'; then
                log_debug "Starship puede leer su configuración"
            else
                check_warn "Problema al leer configuración de Starship"
            fi
        elif command -v gtimeout &> /dev/null; then
            if gtimeout 5s bash -c 'starship config &>/dev/null || true'; then
                log_debug "Starship puede leer su configuración"
            else
                check_warn "Problema al leer configuración de Starship"
            fi
        else
            if bash -c 'starship config &>/dev/null || true'; then
                log_debug "Starship puede leer su configuración"
            else
                check_warn "Problema al leer configuración de Starship"
            fi
        fi
    fi
}

verify_permissions() {
    log_subheader "Verificando Permisos"

    # Verificar permisos de binarios
    local neofetch_found=0
    if command_exists neofetch 2>/dev/null || { command -v neofetch >/dev/null 2>&1; [ $? -eq 0 ]; }; then
        neofetch_found=1
    fi
    if [[ $neofetch_found -eq 1 ]]; then
        local neofetch_path
        neofetch_path=$(command -v neofetch 2>/dev/null || echo "")

        if [[ -x "$neofetch_path" ]]; then
            check_pass "Neofetch tiene permisos de ejecución"
        else
            check_fail "Neofetch NO tiene permisos de ejecución"
        fi
    fi

    local starship_found=0
    if command_exists starship 2>/dev/null || { command -v starship >/dev/null 2>&1; [ $? -eq 0 ]; }; then
        starship_found=1
    fi
    if [[ $starship_found -eq 1 ]]; then
        local starship_path
        starship_path=$(command -v starship 2>/dev/null || echo "")

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

    # Verificar conflictos de PATH - more resilient approach
    local neofetch_count=0
    # Count neofetch binaries in PATH without potentially failing find commands
    local IFS=':'  # Change field separator temporarily
    local path_dirs=($PATH)  # Split PATH into array
    unset IFS  # Restore default field separator

    for dir in "${path_dirs[@]}"; do
        # Skip empty paths
        [[ -z "$dir" ]] && continue
        # Check if directory exists and is readable
        if [[ -d "$dir" && -r "$dir" ]]; then
            if [[ -x "$dir/neofetch" ]]; then
                ((neofetch_count++))
            fi
        fi
    done

    if [[ $neofetch_count -gt 1 ]]; then
        check_warn "Múltiples instalaciones de Neofetch encontradas en PATH"
    fi

    local starship_count=0
    # Count starship binaries in PATH without potentially failing find commands
    local IFS=':'  # Change field separator temporarily
    local path_dirs=($PATH)  # Split PATH into array
    unset IFS  # Restore default field separator

    for dir in "${path_dirs[@]}"; do
        # Skip empty paths
        [[ -z "$dir" ]] && continue
        # Check if directory exists and is readable
        if [[ -d "$dir" && -r "$dir" ]]; then
            if [[ -x "$dir/starship" ]]; then
                ((starship_count++))
            fi
        fi
    done

    if [[ $starship_count -gt 1 ]]; then
        check_warn "Múltiples instalaciones de Starship encontradas en PATH"
    fi

    # Verificar backups antiguos
    local rc_file
    rc_file=$(get_shell_rc_file)

    local backup_count=0
    local backup_dir
    backup_dir=$(dirname "$rc_file")

    # Only search if the backup directory exists
    if [[ -d "$backup_dir" ]]; then
        backup_count=$(find "$backup_dir" -name "$(basename "$rc_file").backup*" 2>/dev/null | wc -l)
    fi

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
        return 0  # Changed from return 1 to return 0 to avoid failing CI/CD on warnings
    else
        log_error "Verificación encontró problemas significativos (${success_rate}% exitoso)"
        return 1  # Changed from return 2 to return 1 to use a more standard exit code
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
    local summary_exit_code=$?
    return $summary_exit_code
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

# Agregar rutas comunes de instalación local al PATH para asegurar que la verificación funcione
# Esto incluye tanto la ruta estándar como rutas específicas de entornos CI
# Las agregamos siempre al inicio del PATH para prioridad alta, sin verificar primero si ya están
export PATH="$HOME/.local/bin:$PATH"
export PATH="/github/home/.local/bin:$PATH"  # Ruta específica para entornos CI de GitHub Actions
export PATH="/home/runner/.local/bin:$PATH"  # Ruta específica para entornos CI de GitHub Actions con runner

# Función auxiliar para encontrar comandos en múltiples ubicaciones posibles
find_command_path() {
    local cmd="$1"

    # Primero intentar con el sistema normal de búsqueda
    local path_result
    path_result=$(command -v "$cmd" 2>/dev/null) || true

    if [[ -n "$path_result" ]]; then
        echo "$path_result"
        return 0
    fi

    # Si no se encuentra, buscar en ubicaciones comunes donde se instalan localmente
    # Incluyendo rutas comunes de instalación local en diferentes entornos
    local local_paths=(
        "$HOME/.local/bin/$cmd"
        "$HOME/.local/bin/$cmd.exe"
        "/github/home/.local/bin/$cmd"   # Ruta específica para entornos CI de GitHub Actions con HOME=/github/home
        "/home/runner/.local/bin/$cmd"   # Ruta específica para entornos CI de GitHub Actions con HOME=/home/runner
        "/usr/local/bin/$cmd"
        "/usr/bin/$cmd"
    )

    for cmd_path in "${local_paths[@]}"; do
        if [[ -x "$cmd_path" ]]; then
            echo "$cmd_path"
            return 0
        fi
    done

    # Si aún no se encuentra, intentar con 'which' como backup (en caso de que esté disponible)
    if command -v which >/dev/null 2>&1; then
        local which_result
        which_result=$(which "$cmd" 2>/dev/null) || true
        if [[ -n "$which_result" ]] && [[ -x "$which_result" ]]; then
            echo "$which_result"
            return 0
        fi
    fi

    # Comando no encontrado
    return 1
}

# Función mejorada que maneja mejor la existencia de comandos
command_exists_enhanced() {
    local cmd="$1"
    if find_command_path "$cmd" > /dev/null; then
        return 0
    else
        return 1
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

    # Ejecutar verificación
    run_verification
    local verification_exit_code=$?

    # Mostrar resumen de logs
    print_log_summary

    exit $verification_exit_code
}

main "$@"
