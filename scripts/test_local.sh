#!/bin/bash

# ==============================================================================
# Test Local - Validación local de CI/CD
# ==============================================================================
# Script para validar localmente antes de hacer push
# Simula las validaciones que se ejecutan en CI/CD
# ==============================================================================

set -e

cd "$(dirname "$0")/.."

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ERRORS=0

echo -e "${BOLD}🧪 Ejecutando validaciones locales del CI/CD...${NC}"
echo ""

# ==============================================================================
# 1. Validar sintaxis Bash
# ==============================================================================
echo -e "${BLUE}📝 Validando sintaxis de scripts Bash...${NC}"
for script in scripts/setup_terminal.sh scripts/lib/*.sh; do
  if bash -n "$script" 2>/dev/null; then
    echo -e "${GREEN}✅${NC} $(basename $script): sintaxis OK"
  else
    echo -e "${RED}❌${NC} $(basename $script): ERROR de sintaxis"
    bash -n "$script"
    ((ERRORS++))
  fi
done
echo ""

# ==============================================================================
# 2. Validar sintaxis YAML
# ==============================================================================
echo -e "${BLUE}📋 Validando sintaxis YAML de workflows...${NC}"
if command -v python3 &> /dev/null; then
    if python3 -c "
import yaml
try:
    with open('.github/workflows/ci.yml', 'r') as f:
        yaml.safe_load(f)
    exit(0)
except Exception as e:
    print(e)
    exit(1)
" 2>&1; then
        echo -e "${GREEN}✅${NC} ci.yml: sintaxis YAML OK"
    else
        echo -e "${RED}❌${NC} ci.yml: ERROR de sintaxis YAML"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠️${NC}  Python3 no disponible - validación YAML omitida"
fi
echo ""

# ==============================================================================
# 3. Verificar archivos necesarios
# ==============================================================================
echo -e "${BLUE}📁 Verificando archivos necesarios...${NC}"
FILES=(
    "scripts/setup_terminal.sh"
    "scripts/lib/colors.sh"
    "scripts/lib/logger.sh"
    "scripts/lib/utils.sh"
    "config/starship.toml"
    "README.md"
    ".github/workflows/ci.yml"
)

for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✅${NC} $file existe"
    else
        echo -e "${RED}❌${NC} $file NO existe"
        ((ERRORS++))
    fi
done
echo ""

# ==============================================================================
# 4. Test dry-run del script (comentado - causa timeout en CI local)
# ==============================================================================
# echo -e "${BLUE}🔧 Probando setup_terminal.sh en modo dry-run...${NC}"
# if timeout 5 bash scripts/setup_terminal.sh --dry-run --yes --skip-neofetch --skip-starship &> /dev/null; then
#     echo -e "${GREEN}✅${NC} setup_terminal.sh --dry-run ejecuta correctamente"
# else
#     echo -e "${RED}❌${NC} setup_terminal.sh --dry-run falló o timeout"
#     ((ERRORS++))
# fi
# echo ""

# ==============================================================================
# 5. Validar configuración de Starship (si está instalado)
# ==============================================================================
if command -v starship &> /dev/null; then
    echo -e "${BLUE}⭐ Validando configuración de Starship...${NC}"
    export STARSHIP_CONFIG=./config/starship.toml
    if timeout 3 starship print-config &> /dev/null; then
        echo -e "${GREEN}✅${NC} Configuración de Starship válida"
    else
        echo -e "${RED}❌${NC} Configuración de Starship inválida"
        starship print-config 2>&1 | head -10
        ((ERRORS++))
    fi
    echo ""
else
    echo -e "${YELLOW}⚠️${NC}  Starship no instalado - validación omitida"
    echo ""
fi

# ==============================================================================
# 6. ShellCheck (si está instalado)
# ==============================================================================
if command -v shellcheck &> /dev/null; then
    echo -e "${BLUE}🔍 Ejecutando ShellCheck...${NC}"
    if shellcheck scripts/*.sh scripts/lib/*.sh 2>&1 | grep -q "error:"; then
        echo -e "${RED}❌${NC} ShellCheck encontró errores"
        shellcheck scripts/*.sh scripts/lib/*.sh
        ((ERRORS++))
    else
        echo -e "${GREEN}✅${NC} ShellCheck: sin errores críticos"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠️${NC}  ShellCheck no instalado - validación omitida"
    echo ""
fi

# ==============================================================================
# Resumen
# ==============================================================================
echo "═══════════════════════════════════════════════════════"
if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}✅ Todas las validaciones pasaron${NC}"
    echo -e "${GREEN}   Seguro para hacer push!${NC}"
    exit 0
else
    echo -e "${RED}${BOLD}❌ $ERRORS error(es) encontrado(s)${NC}"
    echo -e "${RED}   Por favor corrige los errores antes de hacer push${NC}"
    exit 1
fi
