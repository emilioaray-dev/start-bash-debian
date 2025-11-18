#!/bin/bash

# ==============================================================================
# logger.sh - Sistema de logging profesional
# ==============================================================================

# Guard para evitar múltiples cargas
[[ -n "${__LOGGER_SH_LOADED__:-}" ]] && return 0
__LOGGER_SH_LOADED__=1

# Sourcing colors
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${__COLORS_SH_LOADED__:-}" ]] && source "${SCRIPT_DIR}/colors.sh"

# Configuración del logger
LOG_DIR="${LOG_DIR:-/tmp}"
LOG_FILE="${LOG_DIR}/setup_terminal_$(date +%Y%m%d_%H%M%S).log"
LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR

# Función helper para obtener nivel numérico (compatible con bash 3.2+)
get_log_level_value() {
    case "$1" in
        DEBUG) echo 0 ;;
        INFO)  echo 1 ;;
        WARN)  echo 2 ;;
        ERROR) echo 3 ;;
        *)     echo 1 ;;  # Default INFO
    esac
}

# Inicializar sistema de logging
init_logger() {
    local log_dir="$1"

    if [[ -n "$log_dir" ]]; then
        LOG_DIR="$log_dir"
        LOG_FILE="${LOG_DIR}/setup_terminal_$(date +%Y%m%d_%H%M%S).log"
    fi

    # Crear directorio de logs si no existe
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR" 2>/dev/null || {
            LOG_DIR="/tmp"
            LOG_FILE="${LOG_DIR}/setup_terminal_$(date +%Y%m%d_%H%M%S).log"
        }
    fi

    # Crear archivo de log
    touch "$LOG_FILE" 2>/dev/null || {
        echo "⚠️  No se pudo crear archivo de log en $LOG_FILE"
        LOG_FILE="/dev/null"
    }

    log_info "Sistema de logging inicializado"
    log_info "Archivo de log: $LOG_FILE"
    log_info "Nivel de log: $LOG_LEVEL"
}

# Función genérica de logging
_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Verificar si el nivel es suficiente para loguear (compatible bash 3.2+)
    local level_value
    local current_level_value
    level_value=$(get_log_level_value "$level")
    current_level_value=$(get_log_level_value "$LOG_LEVEL")

    if [[ $level_value -ge $current_level_value ]]; then
        # Escribir al archivo de log
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Funciones de logging por nivel
log_debug() {
    _log "DEBUG" "$@"
    if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
        print_color "$COLOR_DIM" "🐛 [DEBUG] $*"
    fi
}

log_info() {
    _log "INFO" "$@"
    print_info "$@"
}

log_warn() {
    _log "WARN" "$@"
    print_warning "$@"
}

log_error() {
    _log "ERROR" "$@"
    print_error "$@"
}

log_success() {
    _log "INFO" "SUCCESS: $*"
    print_success "$@"
}

log_step() {
    _log "INFO" "STEP: $*"
    print_step "$@"
}

log_header() {
    _log "INFO" "HEADER: $*"
    print_header "$@"
}

log_subheader() {
    _log "INFO" "SUBHEADER: $*"
    print_subheader "$@"
}

# Logging de comandos ejecutados
log_command() {
    local cmd="$*"
    log_debug "Ejecutando comando: $cmd"
    _log "INFO" "COMMAND: $cmd"
}

# Logging de errores de comandos
log_command_error() {
    local cmd="$1"
    local exit_code="$2"
    local error_msg="${3:-Error desconocido}"

    log_error "Comando falló (código $exit_code): $cmd"
    log_error "Mensaje: $error_msg"
}

# Exportar variables de entorno al log
log_env() {
    _log "DEBUG" "=== Variables de Entorno ==="
    _log "DEBUG" "USER: $USER"
    _log "DEBUG" "HOME: $HOME"
    _log "DEBUG" "SHELL: $SHELL"
    _log "DEBUG" "PWD: $PWD"
    _log "DEBUG" "PATH: $PATH"
    _log "DEBUG" "DISTRO: $(get_distro_name 2>/dev/null || echo 'Unknown')"
}

# Función para capturar y loguear la salida de un comando
run_and_log() {
    local description="$1"
    shift
    local cmd="$*"

    log_command "$cmd"

    local output
    local exit_code

    output=$($cmd 2>&1)
    exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        log_debug "Comando exitoso: $description"
        [[ -n "$output" ]] && log_debug "Salida: $output"
    else
        log_command_error "$cmd" "$exit_code" "$output"
    fi

    return $exit_code
}

# Resumen de log al finalizar
print_log_summary() {
    local errors
    local warnings

    if [[ -f "$LOG_FILE" && "$LOG_FILE" != "/dev/null" ]]; then
        errors=$(grep -c "\[ERROR\]" "$LOG_FILE" 2>/dev/null || echo "0")
        warnings=$(grep -c "\[WARN\]" "$LOG_FILE" 2>/dev/null || echo "0")

        echo ""
        print_header "📊 Resumen de Ejecución"

        echo -e "${COLOR_BOLD}Archivo de log:${COLOR_RESET} $LOG_FILE"
        echo -e "${COLOR_BOLD}Errores:${COLOR_RESET} $errors"
        echo -e "${COLOR_BOLD}Advertencias:${COLOR_RESET} $warnings"

        if [[ $errors -gt 0 ]]; then
            print_warning "Se encontraron $errors error(es). Revisa el log para más detalles."
        fi

        if [[ $warnings -gt 0 ]]; then
            print_info "Se encontraron $warnings advertencia(s)."
        fi

        if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
            print_success "Ejecución completada sin errores ni advertencias"
        fi

        echo ""
    fi
}

# Limpiar logs antiguos (mantener últimos N días)
cleanup_old_logs() {
    local days="${1:-7}"
    local log_pattern="${LOG_DIR}/setup_terminal_*.log"

    if [[ -d "$LOG_DIR" ]]; then
        find "$LOG_DIR" -name "setup_terminal_*.log" -type f -mtime +"$days" -delete 2>/dev/null
        log_debug "Logs antiguos limpiados (> $days días)"
    fi
}

# Auto-inicializar logger
init_logger
