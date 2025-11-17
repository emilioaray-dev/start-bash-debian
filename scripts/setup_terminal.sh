#!/bin/bash

# ==============================================================================
# Setup Terminal - Script de Instalación Profesional
# Versión: 2.0.0
# Descripción: Instalación automatizada de Neofetch y Starship con soporte
#              para instalación local y de sistema
# ==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ==============================================================================
# Configuración Global
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Sourcing de bibliotecas
source "${LIB_DIR}/colors.sh"
source "${LIB_DIR}/logger.sh"
source "${LIB_DIR}/utils.sh"

# Obtener versión del proyecto
VERSION=$(get_project_version)

# Variables globales
INSTALL_MODE="system"          # system o local
DRY_RUN=false
VERBOSE=false
SKIP_CONFIRMATION=false
CUSTOM_CONFIG=""
INSTALL_NEOFETCH=true
INSTALL_STARSHIP=true

# Directorios según modo de instalación
SYSTEM_BIN_DIR="/usr/local/bin"
LOCAL_BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"

# ==============================================================================
# Funciones de Ayuda
# ==============================================================================

show_version() {
    echo "Setup Terminal v${VERSION}"
    echo "Copyright (c) 2025"
}

show_help() {
    cat << EOF
$(show_version)

Instalación automatizada de herramientas de terminal productivas.

USO:
    $0 [OPCIONES]

OPCIONES:
    -l, --local              Instalación solo para usuario actual (sin sudo)
    -s, --system             Instalación a nivel sistema (requiere sudo) [por defecto]
    -c, --config FILE        Usar archivo de configuración personalizado
    -d, --dry-run            Simular instalación sin ejecutar comandos
    -y, --yes                Aceptar todas las confirmaciones automáticamente
    -v, --verbose            Mostrar salida detallada (modo debug)
    --skip-neofetch          No instalar Neofetch
    --skip-starship          No instalar Starship
    --uninstall              Desinstalar herramientas
    --verify                 Verificar instalación existente
    -h, --help               Mostrar esta ayuda
    --version                Mostrar versión

EJEMPLOS:
    # Instalación estándar en Linux (requiere sudo)
    sudo $0

    # Instalación en macOS (con Homebrew)
    $0

    # Instalación local (sin sudo)
    $0 --local

    # Instalación con dry-run
    $0 --dry-run

    # Instalación solo de Starship
    $0 --skip-neofetch

    # Desinstalación
    sudo $0 --uninstall

    # Verificar instalación
    $0 --verify

NOTAS:
    - En macOS, usa Homebrew automáticamente (lo instala si es necesario)
    - En Linux, usa apt/dnf según la distribución
    - Modo local no requiere permisos de administrador

ARCHIVOS:
    Logs: /tmp/setup_terminal_*.log
    Config Starship: ~/.config/starship.toml
    Config Neofetch: ~/.config/neofetch/config.conf

REPOSITORIO:
    https://github.com/emilioaray-dev/start-bash-debian

EOF
}

# ==============================================================================
# Funciones de Instalación - Neofetch
# ==============================================================================

install_neofetch_system() {
    log_subheader "Instalando Neofetch (modo sistema)"

    local privilege_cmd
    privilege_cmd=$(get_privilege_cmd) || {
        log_error "No se pueden obtener privilegios necesarios"
        return 1
    }

    # Actualizar repositorios
    log_step "Actualizando lista de paquetes..."
    if [[ "$DRY_RUN" == "false" ]]; then
        run_cmd "Actualizar apt" "$privilege_cmd apt-get update -qq"
    else
        log_info "[DRY-RUN] Se ejecutaría: $privilege_cmd apt-get update"
    fi

    # Instalar dependencias
    log_step "Instalando dependencias (git, make)..."
    if [[ "$DRY_RUN" == "false" ]]; then
        run_cmd "Instalar dependencias" "$privilege_cmd apt-get install -y git make"
    else
        log_info "[DRY-RUN] Se ejecutaría: $privilege_cmd apt-get install -y git make"
    fi

    # Clonar e instalar Neofetch
    log_step "Clonando repositorio de Neofetch..."
    local temp_dir="/tmp/neofetch_$$"

    if [[ "$DRY_RUN" == "false" ]]; then
        run_cmd "Clonar Neofetch" "git clone --depth 1 https://github.com/dylanaraps/neofetch '$temp_dir'" || return 1

        cd "$temp_dir" || return 1

        log_step "Instalando Neofetch..."
        run_cmd "Instalar Neofetch" "$privilege_cmd make install" || {
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        }

        cd - > /dev/null
        rm -rf "$temp_dir"

        log_success "Neofetch instalado correctamente en modo sistema"
    else
        log_info "[DRY-RUN] Se clonaría e instalaría Neofetch desde GitHub"
    fi

    return 0
}

install_neofetch_local() {
    log_subheader "Instalando Neofetch (modo local)"

    # Crear directorio local bin si no existe
    safe_mkdir "$LOCAL_BIN_DIR"

    # Descargar script de Neofetch directamente
    log_step "Descargando Neofetch..."

    if [[ "$DRY_RUN" == "false" ]]; then
        run_cmd "Descargar Neofetch" \
            "curl -fsSL https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o '$LOCAL_BIN_DIR/neofetch'" || return 1

        chmod +x "$LOCAL_BIN_DIR/neofetch"

        # Agregar directorio local al PATH si no está
        add_to_path_if_needed "$LOCAL_BIN_DIR"

        log_success "Neofetch instalado correctamente en modo local"
    else
        log_info "[DRY-RUN] Se descargaría Neofetch a $LOCAL_BIN_DIR"
    fi

    return 0
}

install_neofetch_macos() {
    log_subheader "Instalando Neofetch (macOS con Homebrew)"

    # Verificar/Instalar Homebrew
    if ! has_homebrew; then
        log_warn "Homebrew no está instalado"

        if [[ "$SKIP_CONFIRMATION" == "false" ]]; then
            if ask_yes_no "¿Deseas instalar Homebrew ahora?" "y"; then
                install_homebrew || return 1
            else
                log_error "Homebrew es necesario para instalar Neofetch en macOS"
                return 1
            fi
        else
            install_homebrew || return 1
        fi
    fi

    log_step "Instalando Neofetch con Homebrew..."

    if [[ "$DRY_RUN" == "false" ]]; then
        # Neofetch está en el tap principal de Homebrew
        run_cmd "Instalar Neofetch" "brew install neofetch" || return 1

        log_success "Neofetch instalado correctamente con Homebrew"
    else
        log_info "[DRY-RUN] Se ejecutaría: brew install neofetch"
    fi

    return 0
}

# ==============================================================================
# Funciones de Instalación - Starship
# ==============================================================================

install_starship_system() {
    log_subheader "Instalando Starship (modo sistema)"

    local privilege_cmd
    privilege_cmd=$(get_privilege_cmd) || {
        log_error "No se pueden obtener privilegios necesarios"
        return 1
    }

    # Instalar curl si no está disponible
    if ! command_exists curl; then
        log_step "Instalando curl..."
        if [[ "$DRY_RUN" == "false" ]]; then
            run_cmd "Instalar curl" "$privilege_cmd apt-get install -y curl"
        fi
    fi

    log_step "Descargando e instalando Starship..."

    if [[ "$DRY_RUN" == "false" ]]; then
        # Usar instalador oficial de Starship
        run_cmd "Instalar Starship" \
            "curl -sS https://starship.rs/install.sh | $privilege_cmd sh -s -- --yes" || return 1

        log_success "Starship instalado correctamente en modo sistema"
    else
        log_info "[DRY-RUN] Se ejecutaría el instalador oficial de Starship"
    fi

    return 0
}

install_starship_local() {
    log_subheader "Instalando Starship (modo local)"

    safe_mkdir "$LOCAL_BIN_DIR"

    log_step "Descargando Starship..."

    if [[ "$DRY_RUN" == "false" ]]; then
        # Detectar arquitectura
        local arch
        arch=$(uname -m)
        local starship_arch

        case "$arch" in
            x86_64)
                starship_arch="x86_64-unknown-linux-gnu"
                ;;
            aarch64|arm64)
                starship_arch="aarch64-unknown-linux-gnu"
                ;;
            armv7l)
                starship_arch="armv7-unknown-linux-gnueabihf"
                ;;
            *)
                log_error "Arquitectura no soportada: $arch"
                return 1
                ;;
        esac

        local download_url="https://github.com/starship/starship/releases/latest/download/starship-${starship_arch}.tar.gz"
        local temp_file="/tmp/starship_$$.tar.gz"

        run_cmd "Descargar Starship" "curl -fsSL '$download_url' -o '$temp_file'" || return 1
        run_cmd "Extraer Starship" "tar -xzf '$temp_file' -C '$LOCAL_BIN_DIR'" || return 1
        rm -f "$temp_file"

        chmod +x "$LOCAL_BIN_DIR/starship"

        add_to_path_if_needed "$LOCAL_BIN_DIR"

        log_success "Starship instalado correctamente en modo local"
    else
        log_info "[DRY-RUN] Se descargaría Starship a $LOCAL_BIN_DIR"
    fi

    return 0
}

install_starship_macos() {
    log_subheader "Instalando Starship (macOS con Homebrew)"

    # Verificar/Instalar Homebrew
    if ! has_homebrew; then
        log_warn "Homebrew no está instalado"

        if [[ "$SKIP_CONFIRMATION" == "false" ]]; then
            if ask_yes_no "¿Deseas instalar Homebrew ahora?" "y"; then
                install_homebrew || return 1
            else
                log_error "Homebrew es necesario para instalar Starship en macOS"
                return 1
            fi
        else
            install_homebrew || return 1
        fi
    fi

    log_step "Instalando Starship con Homebrew..."

    if [[ "$DRY_RUN" == "false" ]]; then
        run_cmd "Instalar Starship" "brew install starship" || return 1

        log_success "Starship instalado correctamente con Homebrew"
    else
        log_info "[DRY-RUN] Se ejecutaría: brew install starship"
    fi

    return 0
}

# ==============================================================================
# Configuración de Shell
# ==============================================================================

configure_shell() {
    log_subheader "Configurando Shell"

    local rc_file
    rc_file=$(get_shell_rc_file)

    log_info "Archivo de configuración: $rc_file"

    if [[ "$DRY_RUN" == "false" ]]; then
        # Backup del archivo RC
        backup_file "$rc_file"
    fi

    # Configurar Neofetch
    if [[ "$INSTALL_NEOFETCH" == "true" ]]; then
        configure_neofetch "$rc_file"
    fi

    # Configurar Starship
    if [[ "$INSTALL_STARSHIP" == "true" ]]; then
        configure_starship "$rc_file"
    fi
}

configure_neofetch() {
    local rc_file="$1"

    log_step "Configurando Neofetch en shell..."

    local neofetch_line="neofetch"
    local neofetch_comment="# Display system info on startup (Neofetch)"

    if [[ "$DRY_RUN" == "false" ]]; then
        if ! grep -q "$neofetch_line" "$rc_file" 2>/dev/null; then
            {
                echo ""
                echo "$neofetch_comment"
                echo "$neofetch_line"
            } >> "$rc_file"
            log_success "Neofetch agregado a $rc_file"
        else
            log_info "Neofetch ya está configurado en $rc_file"
        fi
    else
        log_info "[DRY-RUN] Se agregaría Neofetch a $rc_file"
    fi

    # Crear configuración personalizada de Neofetch
    create_neofetch_config
}

configure_starship() {
    local rc_file="$1"

    log_step "Configurando Starship en shell..."

    local shell
    shell=$(get_user_shell)

    local starship_init
    case "$shell" in
        bash)
            starship_init='eval "$(starship init bash)"'
            ;;
        zsh)
            starship_init='eval "$(starship init zsh)"'
            ;;
        fish)
            starship_init='starship init fish | source'
            ;;
        *)
            log_warn "Shell no soportado para Starship: $shell"
            return 1
            ;;
    esac

    local starship_comment="# Starship Prompt Initialization"

    if [[ "$DRY_RUN" == "false" ]]; then
        if ! grep -q "starship init" "$rc_file" 2>/dev/null; then
            {
                echo ""
                echo "$starship_comment"
                echo "$starship_init"
            } >> "$rc_file"
            log_success "Starship agregado a $rc_file"
        else
            log_info "Starship ya está configurado en $rc_file"
        fi
    else
        log_info "[DRY-RUN] Se agregaría Starship a $rc_file"
    fi

    # Crear configuración personalizada de Starship
    create_starship_config
}

add_to_path_if_needed() {
    local dir="$1"
    local rc_file
    rc_file=$(get_shell_rc_file)

    if [[ ":$PATH:" != *":$dir:"* ]]; then
        log_step "Agregando $dir al PATH..."

        if [[ "$DRY_RUN" == "false" ]]; then
            local path_line="export PATH=\"$dir:\$PATH\""
            local path_comment="# Local bin directory"

            if ! grep -q "$path_line" "$rc_file" 2>/dev/null; then
                {
                    echo ""
                    echo "$path_comment"
                    echo "$path_line"
                } >> "$rc_file"
                log_success "PATH actualizado en $rc_file"
            fi
        else
            log_info "[DRY-RUN] Se agregaría $dir al PATH"
        fi
    fi
}

# ==============================================================================
# Creación de Configuraciones
# ==============================================================================

create_neofetch_config() {
    log_step "Creando configuración de Neofetch..."

    local neofetch_config_dir="$CONFIG_DIR/neofetch"
    local neofetch_config_file="$neofetch_config_dir/config.conf"

    if [[ -f "$neofetch_config_file" ]]; then
        log_info "Configuración de Neofetch ya existe, omitiendo..."
        return 0
    fi

    if [[ "$DRY_RUN" == "false" ]]; then
        safe_mkdir "$neofetch_config_dir"

        # Generar configuración básica ejecutando neofetch
        neofetch --config none --print_config > "$neofetch_config_file" 2>/dev/null || {
            log_warn "No se pudo generar configuración de Neofetch"
            return 1
        }

        log_success "Configuración de Neofetch creada en $neofetch_config_file"
    else
        log_info "[DRY-RUN] Se crearía configuración de Neofetch"
    fi
}

create_starship_config() {
    log_step "Creando configuración de Starship..."

    local starship_config_file="$CONFIG_DIR/starship.toml"

    if [[ -f "$starship_config_file" ]]; then
        log_info "Configuración de Starship ya existe, omitiendo..."
        return 0
    fi

    if [[ "$DRY_RUN" == "false" ]]; then
        safe_mkdir "$CONFIG_DIR"

        # Copiar configuración personalizada si existe
        local custom_config="${SCRIPT_DIR}/../config/starship.toml"
        if [[ -f "$custom_config" ]]; then
            cp "$custom_config" "$starship_config_file"
            log_success "Configuración personalizada de Starship copiada"
        else
            # Crear configuración básica
            cat > "$starship_config_file" << 'EOF'
# Configuración de Starship - Terminal Profesional
# Documentación: https://starship.rs/config/

format = """
[╭─](bold green)$username$hostname$directory$git_branch$git_status$git_state
[╰─](bold green)$character"""

[username]
show_always = true
format = "[$user]($style)@"
style_user = "bold cyan"
style_root = "bold red"

[hostname]
ssh_only = false
format = "[$hostname]($style) "
style = "bold cyan"

[directory]
truncation_length = 3
truncate_to_repo = true
format = "in [$path]($style)[$read_only]($read_only_style) "
style = "bold yellow"

[git_branch]
format = "on [$symbol$branch]($style) "
symbol = " "
style = "bold purple"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "bold red"

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[cmd_duration]
min_time = 500
format = "took [$duration]($style) "
style = "bold yellow"

[time]
disabled = false
format = "🕙 [$time]($style) "
style = "bold white"
time_format = "%T"

[nodejs]
format = "via [ $version](bold green) "

[python]
format = 'via [ $version](bold yellow) '

[rust]
format = "via [ $version](bold red) "

[golang]
format = "via [ $version](bold cyan) "

[docker_context]
format = "via [ $context](bold blue) "
EOF
            log_success "Configuración básica de Starship creada"
        fi
    else
        log_info "[DRY-RUN] Se crearía configuración de Starship"
    fi
}

# ==============================================================================
# Verificación de Instalación
# ==============================================================================

verify_installation() {
    log_header "Verificando Instalación"

    local all_ok=true

    # Verificar Neofetch
    if [[ "$INSTALL_NEOFETCH" == "true" ]]; then
        if command_exists neofetch; then
            local version
            version=$(neofetch --version 2>&1 | head -n1)
            log_success "Neofetch instalado: $version"
        else
            log_error "Neofetch NO encontrado"
            all_ok=false
        fi
    fi

    # Verificar Starship
    if [[ "$INSTALL_STARSHIP" == "true" ]]; then
        if command_exists starship; then
            local version
            version=$(starship --version 2>&1 | head -n1)
            log_success "Starship instalado: $version"
        else
            log_error "Starship NO encontrado"
            all_ok=false
        fi
    fi

    # Verificar configuraciones
    local rc_file
    rc_file=$(get_shell_rc_file)

    if [[ -f "$rc_file" ]]; then
        log_success "Archivo RC encontrado: $rc_file"

        if [[ "$INSTALL_NEOFETCH" == "true" ]]; then
            if grep -q "neofetch" "$rc_file"; then
                log_success "Neofetch configurado en shell"
            else
                log_warn "Neofetch NO configurado en shell"
            fi
        fi

        if [[ "$INSTALL_STARSHIP" == "true" ]]; then
            if grep -q "starship init" "$rc_file"; then
                log_success "Starship configurado en shell"
            else
                log_warn "Starship NO configurado en shell"
            fi
        fi
    fi

    echo ""
    if [[ "$all_ok" == "true" ]]; then
        log_success "✓ Verificación completada exitosamente"
        return 0
    else
        log_error "✗ Verificación encontró problemas"
        return 1
    fi
}

# ==============================================================================
# Función Principal de Instalación
# ==============================================================================

run_installation() {
    log_header "🚀 Instalación de Terminal Profesional"

    # Mostrar información del sistema
    if [[ "$VERBOSE" == "true" ]]; then
        show_system_info
        log_env
    fi

    # Verificar requisitos previos
    log_subheader "Verificando Requisitos"

    # Verificar distribución/OS
    if is_macos; then
        log_info "Sistema detectado: macOS $(get_distro_version)"
        # En macOS, forzar modo local si no se especificó system
        if [[ "$INSTALL_MODE" == "system" && ! "$*" =~ "--system" ]]; then
            log_info "Usando Homebrew para instalación en macOS"
        fi
    elif ! is_debian_based; then
        log_warn "Esta distribución podría no ser totalmente compatible"
        log_info "Distribución detectada: $(get_distro_name)"

        if [[ "$SKIP_CONFIRMATION" == "false" ]]; then
            if ! ask_yes_no "¿Deseas continuar de todos modos?" "n"; then
                log_info "Instalación cancelada por el usuario"
                exit 0
            fi
        fi
    fi

    # Verificar permisos (solo necesario en Linux)
    if ! is_macos; then
        if ! check_privileges "$INSTALL_MODE"; then
            exit 1
        fi
    fi

    # Verificar conectividad
    log_step "Verificando conectividad a internet..."
    if ! check_internet; then
        log_error "No hay conexión a internet"
        exit 1
    fi
    log_success "Conexión a internet OK"

    # Verificar espacio en disco
    if ! check_disk_space 200; then
        exit 1
    fi

    # Confirmación antes de continuar
    if [[ "$SKIP_CONFIRMATION" == "false" && "$DRY_RUN" == "false" ]]; then
        echo ""
        log_info "Modo de instalación: $INSTALL_MODE"
        [[ "$INSTALL_NEOFETCH" == "true" ]] && log_info "  • Neofetch: Sí"
        [[ "$INSTALL_STARSHIP" == "true" ]] && log_info "  • Starship: Sí"
        echo ""

        if ! ask_yes_no "¿Continuar con la instalación?" "y"; then
            log_info "Instalación cancelada por el usuario"
            exit 0
        fi
    fi

    # Instalar componentes
    log_header "Instalando Componentes"

    if [[ "$INSTALL_NEOFETCH" == "true" ]]; then
        if is_macos; then
            install_neofetch_macos || {
                log_error "Error instalando Neofetch"
                return 1
            }
        elif [[ "$INSTALL_MODE" == "system" ]]; then
            install_neofetch_system || {
                log_error "Error instalando Neofetch"
                return 1
            }
        else
            install_neofetch_local || {
                log_error "Error instalando Neofetch"
                return 1
            }
        fi
    fi

    if [[ "$INSTALL_STARSHIP" == "true" ]]; then
        if is_macos; then
            install_starship_macos || {
                log_error "Error instalando Starship"
                return 1
            }
        elif [[ "$INSTALL_MODE" == "system" ]]; then
            install_starship_system || {
                log_error "Error instalando Starship"
                return 1
            }
        else
            install_starship_local || {
                log_error "Error instalando Starship"
                return 1
            }
        fi
    fi

    # Configurar shell
    configure_shell

    # Verificar instalación
    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        verify_installation
    fi

    # Mensaje final
    log_header "✨ Instalación Completada"

    if [[ "$DRY_RUN" == "false" ]]; then
        log_success "¡Terminal configurada exitosamente!"
        echo ""
        log_info "Para aplicar los cambios:"
        log_info "  1. Ejecuta: source $(get_shell_rc_file)"
        log_info "  2. O cierra y abre una nueva terminal"
        echo ""
        log_info "Archivo de log: $LOG_FILE"
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
            -l|--local)
                INSTALL_MODE="local"
                shift
                ;;
            -s|--system)
                INSTALL_MODE="system"
                shift
                ;;
            -c|--config)
                CUSTOM_CONFIG="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -y|--yes)
                SKIP_CONFIRMATION=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            --skip-neofetch)
                INSTALL_NEOFETCH=false
                shift
                ;;
            --skip-starship)
                INSTALL_STARSHIP=false
                shift
                ;;
            --uninstall)
                "${SCRIPT_DIR}/uninstall.sh"
                exit $?
                ;;
            --verify)
                verify_installation
                exit $?
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Usa --help para ver las opciones disponibles"
                exit 1
                ;;
        esac
    done

    # Validación de argumentos
    if [[ "$INSTALL_NEOFETCH" == "false" && "$INSTALL_STARSHIP" == "false" ]]; then
        log_error "No hay nada que instalar (todas las opciones fueron omitidas)"
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

    # Ejecutar instalación
    run_installation

    # Mostrar resumen de logs
    print_log_summary

    exit 0
}

# Ejecutar main con todos los argumentos
main "$@"
