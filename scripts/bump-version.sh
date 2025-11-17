#!/bin/bash

# ==============================================================================
# bump-version.sh - Actualizar versión del proyecto
# ==============================================================================
# Uso: ./bump-version.sh [major|minor|patch] [mensaje]
#
# Ejemplos:
#   ./bump-version.sh patch "Fix bug en instalación macOS"
#   ./bump-version.sh minor "Agregar soporte para Fish shell"
#   ./bump-version.sh major "Reescritura completa v3"
# ==============================================================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorio del proyecto
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/VERSION"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

# ==============================================================================
# Funciones de Ayuda
# ==============================================================================

show_help() {
    cat << EOF
$(echo -e "${BLUE}Bump Version${NC}") - Actualizar versión del proyecto

USAGE:
    $0 [TIPO] [MENSAJE]

TIPOS:
    major       Incrementar versión major (1.0.0 -> 2.0.0)
    minor       Incrementar versión minor (1.0.0 -> 1.1.0)
    patch       Incrementar versión patch (1.0.0 -> 1.0.1)

ARGUMENTOS:
    MENSAJE     Mensaje descriptivo del cambio (opcional)

EJEMPLOS:
    $0 patch "Fix instalación en macOS"
    $0 minor "Agregar soporte para Fish shell"
    $0 major "Versión 3.0 - Breaking changes"

PROCESO:
    1. Lee versión actual desde VERSION
    2. Incrementa según tipo especificado
    3. Actualiza archivo VERSION
    4. Actualiza CHANGELOG.md con nueva versión
    5. Crea commit de versión
    6. Crea tag de git (v<version>)
    7. Muestra instrucciones para push

SEMANTIC VERSIONING:
    MAJOR.MINOR.PATCH
    - MAJOR: Cambios incompatibles en la API
    - MINOR: Funcionalidad nueva compatible
    - PATCH: Correcciones de bugs compatibles

EOF
}

error() {
    echo -e "${RED}ERROR:${NC} $*" >&2
    exit 1
}

info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✅${NC} $*"
}

warn() {
    echo -e "${YELLOW}⚠${NC}  $*"
}

# ==============================================================================
# Verificaciones
# ==============================================================================

check_requirements() {
    # Verificar que estamos en un repo git
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "No estás en un repositorio git"
    fi

    # Verificar que no hay cambios sin commitear
    if [[ -n $(git status --porcelain) ]]; then
        warn "Hay cambios sin commitear en el repositorio"
        echo ""
        git status --short
        echo ""
        read -p "¿Continuar de todos modos? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Abortado por el usuario"
        fi
    fi

    # Verificar que existe archivo VERSION
    if [[ ! -f "$VERSION_FILE" ]]; then
        error "No se encontró archivo VERSION en: $VERSION_FILE"
    fi

    # Verificar que existe CHANGELOG.md
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        error "No se encontró archivo CHANGELOG.md en: $CHANGELOG_FILE"
    fi
}

# ==============================================================================
# Manejo de Versiones
# ==============================================================================

get_current_version() {
    cat "$VERSION_FILE" | tr -d '[:space:]'
}

parse_version() {
    local version="$1"

    # Remover prefijo 'v' si existe
    version="${version#v}"

    # Validar formato semver
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Versión inválida: $version (esperado: MAJOR.MINOR.PATCH)"
    fi

    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"

    echo "$major $minor $patch"
}

bump_version() {
    local bump_type="$1"
    local current_version
    current_version=$(get_current_version)

    info "Versión actual: $current_version"

    local major minor patch
    read -r major minor patch <<< "$(parse_version "$current_version")"

    case "$bump_type" in
        major)
            ((major++))
            minor=0
            patch=0
            ;;
        minor)
            ((minor++))
            patch=0
            ;;
        patch)
            ((patch++))
            ;;
        *)
            error "Tipo de bump inválido: $bump_type (usa: major, minor, patch)"
            ;;
    esac

    local new_version="${major}.${minor}.${patch}"
    echo "$new_version"
}

update_version_file() {
    local new_version="$1"

    echo "$new_version" > "$VERSION_FILE"
    success "Archivo VERSION actualizado a: $new_version"
}

update_changelog() {
    local new_version="$1"
    local message="$2"
    local date
    date=$(date +%Y-%m-%d)

    # Crear entrada temporal
    local temp_entry=$(cat << EOF
## [$new_version] - $date

### Cambios

- $message

---

EOF
)

    # Insertar después de la línea "## [Unreleased]"
    if grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
        # Crear archivo temporal
        local temp_file=$(mktemp)

        awk -v entry="$temp_entry" '
        /## \[Unreleased\]/ {
            print
            print ""
            print entry
            next
        }
        {print}
        ' "$CHANGELOG_FILE" > "$temp_file"

        mv "$temp_file" "$CHANGELOG_FILE"
        success "CHANGELOG.md actualizado con versión $new_version"
    else
        warn "No se encontró sección [Unreleased] en CHANGELOG.md"
        warn "Por favor actualiza manualmente el CHANGELOG.md"
    fi
}

# ==============================================================================
# Git Operations
# ==============================================================================

create_version_commit() {
    local new_version="$1"
    local message="$2"

    git add "$VERSION_FILE" "$CHANGELOG_FILE"

    local commit_message="chore: bump version to v${new_version}"
    if [[ -n "$message" ]]; then
        commit_message="${commit_message}

${message}"
    fi

    git commit -m "$commit_message"
    success "Commit creado: v${new_version}"
}

create_version_tag() {
    local new_version="$1"
    local message="$2"

    local tag_name="v${new_version}"
    local tag_message="Release ${tag_name}"

    if [[ -n "$message" ]]; then
        tag_message="${tag_message}: ${message}"
    fi

    git tag -a "$tag_name" -m "$tag_message"
    success "Tag creado: $tag_name"
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    # Parsear argumentos
    if [[ $# -lt 1 ]]; then
        show_help
        exit 0
    fi

    local bump_type="$1"
    local message="${2:-}"

    if [[ "$bump_type" == "-h" || "$bump_type" == "--help" ]]; then
        show_help
        exit 0
    fi

    # Verificar requisitos
    check_requirements

    # Obtener nueva versión
    local new_version
    new_version=$(bump_version "$bump_type")

    echo ""
    info "Nueva versión: ${GREEN}${new_version}${NC}"
    echo ""

    # Confirmación
    read -p "¿Continuar con el bump a v${new_version}? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        error "Abortado por el usuario"
    fi

    echo ""

    # Actualizar archivos
    update_version_file "$new_version"
    update_changelog "$new_version" "$message"

    # Crear commit y tag
    create_version_commit "$new_version" "$message"
    create_version_tag "$new_version" "$message"

    echo ""
    success "¡Versión actualizada exitosamente a v${new_version}!"
    echo ""

    # Mostrar instrucciones
    info "Para publicar la nueva versión:"
    echo ""
    echo "  ${YELLOW}git push origin main${NC}"
    echo "  ${YELLOW}git push origin v${new_version}${NC}"
    echo ""
    info "El workflow de GitHub Actions creará automáticamente el release"
    echo ""
}

main "$@"
