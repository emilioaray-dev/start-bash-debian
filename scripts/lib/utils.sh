#!/bin/bash

# ==============================================================================
# utils.sh - Funciones utilitarias comunes
# ==============================================================================

# Guard para evitar múltiples cargas
[[ -n "${__UTILS_SH_LOADED__:-}" ]] && return 0
__UTILS_SH_LOADED__=1

# Sourcing de dependencias
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${__COLORS_SH_LOADED__:-}" ]] && source "${SCRIPT_DIR}/colors.sh"
[[ -z "${__LOGGER_SH_LOADED__:-}" ]] && source "${SCRIPT_DIR}/logger.sh"

# ==============================================================================
# Control de Versiones
# ==============================================================================

# Obtener versión del proyecto
# Prioridad: 1) Git tag, 2) Archivo VERSION, 3) Fallback
get_project_version() {
    local version=""

    # Intentar obtener desde git tag (si estamos en un repo git)
    if git rev-parse --git-dir > /dev/null 2>&1; then
        version=$(git describe --tags --exact-match 2>/dev/null | sed 's/^v//')
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi

        # Si no hay tag exacto, intentar tag más reciente
        version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
        if [[ -n "$version" ]]; then
            # Agregar sufijo -dev si no estamos en un tag exacto
            local commits_since
            commits_since=$(git rev-list $(git describe --tags --abbrev=0)..HEAD --count 2>/dev/null)
            if [[ $commits_since -gt 0 ]]; then
                version="${version}-dev+${commits_since}"
            fi
            echo "$version"
            return 0
        fi
    fi

    # Intentar leer desde archivo VERSION
    local version_file="${SCRIPT_DIR}/../VERSION"
    if [[ -f "$version_file" ]]; then
        version=$(cat "$version_file" | tr -d '[:space:]')
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi

    # Fallback - versión por defecto
    echo "2.1.0-unknown"
    return 1
}

# ==============================================================================
# Detección del Sistema
# ==============================================================================

# Detectar sistema operativo
get_os_type() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Verificar si es macOS
is_macos() {
    [[ "$(get_os_type)" == "macos" ]]
}

# Verificar si es Linux
is_linux() {
    [[ "$(get_os_type)" == "linux" ]]
}

# Detectar distribución Linux o versión de macOS
get_distro_name() {
    if is_macos; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# Detectar versión de la distribución
get_distro_version() {
    if is_macos; then
        sw_vers -productVersion
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$VERSION_ID"
    else
        echo "unknown"
    fi
}

# Verificar si es una distribución basada en Debian
is_debian_based() {
    local distro
    distro=$(get_distro_name)

    case "$distro" in
        debian|ubuntu|linuxmint|pop|kali|proxmox)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Obtener gestor de paquetes
get_package_manager() {
    if is_macos; then
        if command -v brew &> /dev/null; then
            echo "brew"
        else
            echo "none"
        fi
    elif command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Verificar si Homebrew está instalado
has_homebrew() {
    command -v brew &> /dev/null
}

# Instalar Homebrew si no está instalado (solo macOS)
install_homebrew() {
    if ! is_macos; then
        log_error "Homebrew solo se puede instalar en macOS"
        return 1
    fi

    if has_homebrew; then
        log_info "Homebrew ya está instalado"
        return 0
    fi

    log_step "Instalando Homebrew..."

    if [[ "$DRY_RUN" == "false" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Agregar Homebrew al PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            # Apple Silicon
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            # Intel
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        log_success "Homebrew instalado correctamente"
    else
        log_info "[DRY-RUN] Se instalaría Homebrew"
    fi
}

# ==============================================================================
# Verificación de Permisos
# ==============================================================================

# Verificar si el script se ejecuta como root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Verificar si sudo está disponible y el usuario está en sudoers
has_sudo() {
    if ! command -v sudo &> /dev/null; then
        return 1
    fi

    sudo -n true 2>/dev/null
    return $?
}

# Obtener comando con elevación de privilegios si es necesario
get_privilege_cmd() {
    if is_root; then
        echo ""
    elif has_sudo; then
        echo "sudo"
    else
        return 1
    fi
}

# Verificar y solicitar permisos si es necesario
check_privileges() {
    local mode="${1:-system}"  # system o local

    if [[ "$mode" == "system" ]]; then
        if ! is_root && ! has_sudo; then
            log_error "Este script requiere privilegios de superusuario"
            log_info "Opciones:"
            log_info "  1. Ejecuta: sudo $0"
            log_info "  2. Usa modo local: $0 --local"
            return 1
        fi

        if ! is_root && has_sudo; then
            log_warn "Se requieren privilegios sudo. Es posible que se te pida la contraseña."
            sudo -v || return 1
        fi
    fi

    return 0
}

# ==============================================================================
# Verificación de Requisitos
# ==============================================================================

# Verificar conectividad a internet
check_internet() {
    local test_urls=(
        "https://github.com"
        "https://google.com"
        "https://raw.githubusercontent.com"
    )

    for url in "${test_urls[@]}"; do
        if curl -s --connect-timeout 5 --head "$url" &> /dev/null; then
            return 0
        fi
    done

    return 1
}

# Verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Verificar si un paquete está instalado (Debian/Ubuntu)
package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Verificar espacio en disco disponible (en MB)
get_available_space() {
    local path="${1:-.}"
    df -m "$path" | awk 'NR==2 {print $4}'
}

# Verificar requisitos mínimos de espacio
check_disk_space() {
    local required_mb="${1:-100}"
    local available
    available=$(get_available_space)

    if [[ $available -lt $required_mb ]]; then
        log_error "Espacio en disco insuficiente. Requerido: ${required_mb}MB, Disponible: ${available}MB"
        return 1
    fi

    log_debug "Espacio en disco OK: ${available}MB disponible"
    return 0
}

# ==============================================================================
# Gestión de Archivos y Directorios
# ==============================================================================

# Crear directorio de forma segura
safe_mkdir() {
    local dir="$1"
    local mode="${2:-755}"

    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" && chmod "$mode" "$dir"
        log_debug "Directorio creado: $dir"
    fi
}

# Backup de archivo
backup_file() {
    local file="$1"
    local backup_suffix="${2:-.backup.$(date +%Y%m%d_%H%M%S)}"

    if [[ -f "$file" ]]; then
        cp "$file" "${file}${backup_suffix}"
        log_debug "Backup creado: ${file}${backup_suffix}"
        return 0
    fi

    return 1
}

# Agregar línea a archivo si no existe
add_line_to_file() {
    local line="$1"
    local file="$2"
    local create_if_missing="${3:-true}"

    if [[ ! -f "$file" && "$create_if_missing" == "true" ]]; then
        touch "$file"
        log_debug "Archivo creado: $file"
    fi

    if ! grep -qxF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        log_debug "Línea agregada a $file: $line"
        return 0
    else
        log_debug "Línea ya existe en $file: $line"
        return 1
    fi
}

# Remover línea de archivo
remove_line_from_file() {
    local pattern="$1"
    local file="$2"

    if [[ -f "$file" ]]; then
        sed -i.bak "/$pattern/d" "$file"
        log_debug "Línea removida de $file: $pattern"
        return 0
    fi

    return 1
}

# ==============================================================================
# Manejo de Errores
# ==============================================================================

# Ejecutar comando y verificar éxito
run_cmd() {
    local description="$1"
    shift
    local cmd="$*"

    log_debug "Ejecutando: $cmd"

    if eval "$cmd"; then
        log_debug "✓ $description"
        return 0
    else
        local exit_code=$?
        log_error "✗ $description (código de salida: $exit_code)"
        return $exit_code
    fi
}

# Trap para limpiar en caso de error
cleanup_on_error() {
    log_error "Script interrumpido. Ejecutando limpieza..."

    # Agregar aquí lógica de limpieza si es necesaria
    # Por ejemplo, eliminar archivos temporales

    print_log_summary
    exit 1
}

# Configurar trap para errores
setup_error_handling() {
    trap cleanup_on_error INT TERM ERR
}

# ==============================================================================
# Utilidades de Shell
# ==============================================================================

# Detectar shell del usuario
get_user_shell() {
    basename "$SHELL"
}

# Obtener archivo RC del shell
get_shell_rc_file() {
    local shell
    shell=$(get_user_shell)

    case "$shell" in
        bash)
            echo "$HOME/.bashrc"
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Recargar configuración del shell
reload_shell() {
    local rc_file
    rc_file=$(get_shell_rc_file)

    if [[ -f "$rc_file" ]]; then
        # No podemos hacer source directo, solo informar
        log_info "Para aplicar los cambios, ejecuta: source $rc_file"
        log_info "O cierra y abre una nueva terminal"
    fi
}

# ==============================================================================
# Preguntas al Usuario
# ==============================================================================

# Preguntar sí/no al usuario
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    local response

    if [[ "$default" == "y" ]]; then
        printf "%b [S/n]: " "$question"
    else
        printf "%b [s/N]: " "$question"
    fi

    read -r response

    response=${response,,}  # Convertir a minúsculas

    if [[ -z "$response" ]]; then
        response="$default"
    fi

    [[ "$response" =~ ^(s|y|si|yes)$ ]]
}

# Esperar confirmación del usuario
wait_for_confirmation() {
    local message="${1:-Presiona ENTER para continuar...}"

    printf "%b" "$message"
    read -r
}

# ==============================================================================
# Información del Sistema
# ==============================================================================

# Mostrar información del sistema
show_system_info() {
    log_subheader "Información del Sistema"

    echo "Sistema Operativo: $(get_distro_name) $(get_distro_version)"
    echo "Kernel: $(uname -r)"
    echo "Arquitectura: $(uname -m)"
    echo "Usuario: $USER"
    echo "Shell: $(get_user_shell)"
    echo "Home: $HOME"
    echo "Gestor de paquetes: $(get_package_manager)"
    echo "Privilegios root: $(is_root && echo 'Sí' || echo 'No')"
    echo "Sudo disponible: $(has_sudo && echo 'Sí' || echo 'No')"
    echo ""
}

# ==============================================================================
# Utilidades de Versión
# ==============================================================================

# Comparar versiones semánticas
version_compare() {
    local version1="$1"
    local version2="$2"

    if [[ "$version1" == "$version2" ]]; then
        return 0
    fi

    local IFS=.
    local i ver1=($version1) ver2=($version2)

    for ((i=0; i<${#ver1[@]} || i<${#ver2[@]}; i++)); do
        if [[ ${ver1[i]:-0} -gt ${ver2[i]:-0} ]]; then
            return 1
        elif [[ ${ver1[i]:-0} -lt ${ver2[i]:-0} ]]; then
            return 2
        fi
    done

    return 0
}
