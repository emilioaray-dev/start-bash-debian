#!/bin/bash

# ==============================================================================
# colors.sh - Sistema de colores y formato para terminal
# ==============================================================================

# Guard para evitar múltiples cargas
[[ -n "${__COLORS_SH_LOADED__:-}" ]] && return 0
__COLORS_SH_LOADED__=1

# Verificar si el terminal soporta colores
if [[ -t 1 ]] && command -v tput &> /dev/null && tput setaf 1 &> /dev/null; then
    COLORS_SUPPORTED=true
else
    COLORS_SUPPORTED=false
fi

# Códigos de color
if [[ "$COLORS_SUPPORTED" == "true" ]]; then
    # Colores básicos
    export COLOR_RESET='\033[0m'
    export COLOR_BOLD='\033[1m'
    export COLOR_DIM='\033[2m'
    export COLOR_UNDERLINE='\033[4m'

    # Colores de texto
    export COLOR_BLACK='\033[0;30m'
    export COLOR_RED='\033[0;31m'
    export COLOR_GREEN='\033[0;32m'
    export COLOR_YELLOW='\033[0;33m'
    export COLOR_BLUE='\033[0;34m'
    export COLOR_MAGENTA='\033[0;35m'
    export COLOR_CYAN='\033[0;36m'
    export COLOR_WHITE='\033[0;37m'

    # Colores brillantes
    export COLOR_BRIGHT_BLACK='\033[0;90m'
    export COLOR_BRIGHT_RED='\033[0;91m'
    export COLOR_BRIGHT_GREEN='\033[0;92m'
    export COLOR_BRIGHT_YELLOW='\033[0;93m'
    export COLOR_BRIGHT_BLUE='\033[0;94m'
    export COLOR_BRIGHT_MAGENTA='\033[0;95m'
    export COLOR_BRIGHT_CYAN='\033[0;96m'
    export COLOR_BRIGHT_WHITE='\033[0;97m'

    # Colores de fondo
    export BG_BLACK='\033[40m'
    export BG_RED='\033[41m'
    export BG_GREEN='\033[42m'
    export BG_YELLOW='\033[43m'
    export BG_BLUE='\033[44m'
    export BG_MAGENTA='\033[45m'
    export BG_CYAN='\033[46m'
    export BG_WHITE='\033[47m'
else
    # Sin colores
    export COLOR_RESET=''
    export COLOR_BOLD=''
    export COLOR_DIM=''
    export COLOR_UNDERLINE=''
    export COLOR_BLACK=''
    export COLOR_RED=''
    export COLOR_GREEN=''
    export COLOR_YELLOW=''
    export COLOR_BLUE=''
    export COLOR_MAGENTA=''
    export COLOR_CYAN=''
    export COLOR_WHITE=''
    export COLOR_BRIGHT_BLACK=''
    export COLOR_BRIGHT_RED=''
    export COLOR_BRIGHT_GREEN=''
    export COLOR_BRIGHT_YELLOW=''
    export COLOR_BRIGHT_BLUE=''
    export COLOR_BRIGHT_MAGENTA=''
    export COLOR_BRIGHT_CYAN=''
    export COLOR_BRIGHT_WHITE=''
    export BG_BLACK=''
    export BG_RED=''
    export BG_GREEN=''
    export BG_YELLOW=''
    export BG_BLUE=''
    export BG_MAGENTA=''
    export BG_CYAN=''
    export BG_WHITE=''
fi

# ==============================================================================
# Funciones de impresión con color
# ==============================================================================

# Imprimir texto en color
print_color() {
    local color="$1"
    shift
    echo -e "${color}$*${COLOR_RESET}"
}

# Imprimir con iconos según el tipo de mensaje
print_success() {
    echo -e "${COLOR_GREEN}${COLOR_BOLD}✅ $*${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_RED}${COLOR_BOLD}❌ $*${COLOR_RESET}"
}

print_warning() {
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}⚠️  $*${COLOR_RESET}"
}

print_info() {
    echo -e "${COLOR_BLUE}${COLOR_BOLD}ℹ️  $*${COLOR_RESET}"
}

print_step() {
    echo -e "${COLOR_CYAN}${COLOR_BOLD}▶️  $*${COLOR_RESET}"
}

print_header() {
    echo -e "\n${COLOR_MAGENTA}${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}${COLOR_BOLD}  $*${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}\n"
}

print_subheader() {
    echo -e "\n${COLOR_CYAN}${COLOR_BOLD}── $* ──${COLOR_RESET}\n"
}

# Imprimir banner del script
print_banner() {
    print_header "🚀 Setup de Terminal Profesional - Neofetch + Starship"
}

# Progreso con barra
print_progress() {
    local current=$1
    local total=$2
    local message=$3
    local percentage=$((current * 100 / total))
    local completed=$((percentage / 2))
    local remaining=$((50 - completed))

    printf "\r${COLOR_CYAN}["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' ' '
    printf "] %3d%% - %s${COLOR_RESET}" "$percentage" "$message"

    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Spinner de carga
show_spinner() {
    local pid=$1
    local message=$2
    local spinner='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${COLOR_CYAN}${spinner:$i:1} %s...${COLOR_RESET}" "$message"
        sleep 0.1
    done
    printf "\r%s\r" "$(printf ' %.0s' {1..100})"  # Limpiar línea
}
