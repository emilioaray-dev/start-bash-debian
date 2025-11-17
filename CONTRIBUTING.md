# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a Terminal Setup! Este documento proporciona pautas para contribuir al proyecto.

---

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [¿Cómo Puedo Contribuir?](#cómo-puedo-contribuir)
- [Proceso de Desarrollo](#proceso-de-desarrollo)
- [Estándares de Código](#estándares-de-código)
- [Proceso de Pull Request](#proceso-de-pull-request)
- [Reportar Bugs](#reportar-bugs)
- [Sugerir Mejoras](#sugerir-mejoras)

---

## 📜 Código de Conducta

Este proyecto y todos los participantes están regidos por nuestro Código de Conducta. Al participar, se espera que mantengas este código. Por favor reporta comportamiento inaceptable a través de GitHub Issues.

### Nuestros Estándares

- Usar lenguaje acogedor e inclusivo
- Respetar diferentes puntos de vista y experiencias
- Aceptar críticas constructivas con gracia
- Enfocarse en lo que es mejor para la comunidad
- Mostrar empatía hacia otros miembros de la comunidad

---

## 🎯 ¿Cómo Puedo Contribuir?

### Reportar Bugs

Los bugs se rastrean como [GitHub Issues](https://github.com/emilioaray-dev/start-bash-debian/issues). Antes de crear un issue:

1. **Verifica** si el bug ya fue reportado
2. **Usa un título descriptivo** para identificar el problema
3. **Describe los pasos exactos** para reproducir el problema
4. **Proporciona ejemplos específicos**
5. **Describe el comportamiento que observaste** y cuál esperabas
6. **Incluye información del entorno:**
   - Distribución y versión de Linux
   - Versión del shell (bash, zsh, etc.)
   - Versiones de Neofetch y Starship (si aplica)

#### Plantilla para Reportar Bugs

```markdown
**Descripción del Bug**
Una descripción clara y concisa del bug.

**Pasos para Reproducir**
1. Ejecutar '...'
2. Ver error '....'

**Comportamiento Esperado**
Qué esperabas que sucediera.

**Comportamiento Actual**
Qué sucedió realmente.

**Logs**
Si es posible, adjunta el archivo de log (/tmp/setup_terminal_*.log)

**Entorno:**
- OS: [ej. Debian 12]
- Shell: [ej. bash 5.1]
- Modo de instalación: [ej. local/sistema]

**Información Adicional**
Cualquier otra información relevante.
```

### Sugerir Mejoras

Las mejoras también se rastrean como [GitHub Issues](https://github.com/emilioaray-dev/start-bash-debian/issues).

#### Plantilla para Sugerencias

```markdown
**¿Tu sugerencia está relacionada con un problema?**
Descripción clara del problema. Ej. "Estoy frustrado cuando [...]"

**Describe la solución que te gustaría**
Descripción clara y concisa de lo que quieres que suceda.

**Describe alternativas que consideraste**
Descripción de soluciones o características alternativas.

**Contexto Adicional**
Cualquier otro contexto o capturas de pantalla sobre la sugerencia.
```

### Contribuir con Código

1. **Fork** el repositorio
2. **Crea** una rama desde `main`
3. **Implementa** tus cambios
4. **Escribe** o actualiza tests
5. **Asegúrate** de que los tests pasen
6. **Haz commit** de tus cambios
7. **Push** a tu fork
8. **Abre** un Pull Request

---

## 🛠️ Proceso de Desarrollo

### Configuración del Entorno

```bash
# 1. Fork y clonar el repositorio
git clone https://github.com/TU_USUARIO/start-bash-debian.git
cd start-bash-debian

# 2. Crear rama para tu feature
git checkout -b feature/mi-nueva-caracteristica

# 3. Hacer ejecutables los scripts
chmod +x scripts/*.sh scripts/lib/*.sh
```

### Estructura de Ramas

- `main` - Rama principal, siempre estable
- `develop` - Rama de desarrollo (si existe)
- `feature/*` - Nuevas características
- `bugfix/*` - Corrección de bugs
- `hotfix/*` - Correcciones urgentes
- `docs/*` - Actualizaciones de documentación

### Testing Local

```bash
# Test de sintaxis con ShellCheck
shellcheck scripts/*.sh scripts/lib/*.sh

# Test de instalación dry-run
./scripts/setup_terminal.sh --dry-run --verbose

# Test de instalación local
./scripts/setup_terminal.sh --local --yes

# Verificación
./scripts/verify.sh --verbose

# Test de desinstalación
./scripts/uninstall.sh --dry-run
```

---

## 📝 Estándares de Código

### Scripts Bash

#### Shebang y Opciones

```bash
#!/bin/bash

# Siempre incluir estas opciones para scripts principales
set -euo pipefail
```

#### Nomenclatura

- **Variables:** `SNAKE_CASE_MAYUSCULAS` para constantes, `snake_case_minusculas` para variables
- **Funciones:** `snake_case_minusculas` con verbos descriptivos
- **Archivos:** `snake_case.sh`

```bash
# ✅ Bien
INSTALL_MODE="system"
user_home="$HOME"

install_package() {
    local package_name="$1"
    # ...
}

# ❌ Mal
installMode="system"
UserHome="$HOME"

InstallPackage() {
    # ...
}
```

#### Comentarios y Documentación

```bash
# ==============================================================================
# Descripción breve de la sección
# ==============================================================================

# Comentar funciones complejas
#
# Argumentos:
#   $1 - descripción del primer argumento
#   $2 - descripción del segundo argumento
#
# Returns:
#   0 - éxito
#   1 - error
#
mi_funcion() {
    local arg1="$1"
    local arg2="$2"

    # Comentar lógica compleja
    if [[ condicion ]]; then
        # Explicar por qué se hace esto
        comando
    fi
}
```

#### Manejo de Errores

```bash
# ✅ Verificar códigos de salida
if ! comando_importante; then
    log_error "Descripción del error"
    return 1
fi

# ✅ Usar funciones del logger
log_info "Mensaje informativo"
log_error "Mensaje de error"
log_success "Operación exitosa"

# ❌ No ignorar errores silenciosamente
comando_importante || true  # Evitar esto
```

#### Variables y Strings

```bash
# ✅ Bien - Usar comillas dobles
local path="$HOME/.config"
log_info "Installing to $path"

# ✅ Bien - Arrays
local packages=("git" "curl" "make")

# ❌ Mal - Sin comillas
local path=$HOME/.config  # Problemas con espacios

# ❌ Mal - Comillas simples con variables
log_info 'Installing to $path'  # No expande variable
```

### Estilo de Código

#### Indentación

- Usar **4 espacios** (no tabs)
- Indentar bloques de control

```bash
if [[ condicion ]]; then
    comando1
    if [[ otra_condicion ]]; then
        comando2
    fi
fi
```

#### Funciones

```bash
# ✅ Formato preferido
mi_funcion() {
    local var1="$1"
    local var2="$2"

    # Cuerpo de la función
    echo "Resultado"
    return 0
}

# Llamada
mi_funcion "arg1" "arg2"
```

#### Longitud de Línea

- Máximo **100 caracteres** por línea
- Dividir líneas largas con `\`

```bash
# ✅ Bien
comando_largo \
    --opcion1 "valor1" \
    --opcion2 "valor2" \
    --opcion3 "valor3"
```

### Logging

Usar siempre las funciones del logger:

```bash
# Cargar logger
source "${LIB_DIR}/logger.sh"

# Usar funciones apropiadas
log_header "Título de Sección"
log_subheader "Subtítulo"
log_step "Ejecutando paso..."
log_info "Información general"
log_success "Operación exitosa"
log_warn "Advertencia"
log_error "Error crítico"
log_debug "Información de debugging"
```

---

## 🔄 Proceso de Pull Request

### Antes de Enviar

- [ ] Código sigue las guías de estilo del proyecto
- [ ] Comentarios añadidos en áreas difíciles de entender
- [ ] Cambios en documentación reflejan cambios en código
- [ ] Tests agregados/actualizados
- [ ] Todos los tests pasan localmente
- [ ] ShellCheck no reporta warnings

### Creando el PR

1. **Título descriptivo:** `[Tipo] Descripción breve`
   - Tipos: `Feature`, `Bugfix`, `Docs`, `Refactor`, `Test`
   - Ejemplo: `[Feature] Agregar soporte para Fish shell`

2. **Descripción detallada:**

```markdown
## Descripción
Descripción clara de qué hace este PR.

## Tipo de Cambio
- [ ] Bug fix (cambio que soluciona un issue)
- [ ] Nueva característica (cambio que agrega funcionalidad)
- [ ] Breaking change (fix o feature que causa que funcionalidad existente no funcione)
- [ ] Cambio en documentación

## ¿Cómo se ha probado?
Describe las pruebas realizadas.

## Checklist
- [ ] Mi código sigue el estilo de este proyecto
- [ ] He realizado auto-review de mi código
- [ ] He comentado mi código, particularmente en áreas difíciles
- [ ] He realizado cambios correspondientes en documentación
- [ ] Mis cambios no generan nuevos warnings
- [ ] He agregado tests que prueban que mi fix es efectivo
- [ ] Tests unitarios nuevos y existentes pasan localmente
```

### Después de Enviar

- Responde a comentarios de code review
- Realiza cambios solicitados
- Mantén la conversación constructiva
- Sé paciente durante el proceso de revisión

---

## 🧪 Tests

### Ejecutar Suite Completa

```bash
# Instalación
./scripts/setup_terminal.sh --dry-run
./scripts/setup_terminal.sh --local --yes
./scripts/verify.sh

# Desinstalación
./scripts/uninstall.sh --dry-run
./scripts/uninstall.sh --yes

# ShellCheck
shellcheck scripts/*.sh scripts/lib/*.sh
```

### Tests Específicos

```bash
# Test solo de neofetch
./scripts/setup_terminal.sh --skip-starship --dry-run

# Test solo de starship
./scripts/setup_terminal.sh --skip-neofetch --dry-run

# Test con verbose
./scripts/setup_terminal.sh --verbose --dry-run
```

---

## 📚 Recursos

### Documentación

- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

### Herramientas Útiles

- [ShellCheck](https://www.shellcheck.net/) - Análisis estático
- [shfmt](https://github.com/mvdan/sh) - Formateador de shell scripts

---

## 📦 Proceso de Releases

### Control de Versiones

Este proyecto utiliza [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

- MAJOR: Cambios incompatibles en la API (breaking changes)
- MINOR: Nueva funcionalidad compatible con versiones anteriores
- PATCH: Correcciones de bugs compatibles
```

### Fuentes de Versión (Prioridad)

1. **Git Tags** - `git describe --tags` (prioridad máxima)
2. **Archivo VERSION** - Archivo centralizado en la raíz del proyecto
3. **Fallback** - Versión por defecto si no se encuentra ninguna

### Crear un Nuevo Release

#### Opción 1: Usando el Script de Bump Version (Recomendado)

```bash
# 1. Asegúrate de estar en la rama main
git checkout main
git pull origin main

# 2. Ejecuta el script de bump version
cd scripts

# Para un patch (bug fixes)
./bump-version.sh patch "Fix instalación en macOS"

# Para un minor (nuevas características)
./bump-version.sh minor "Agregar soporte para Fish shell"

# Para un major (breaking changes)
./bump-version.sh major "Reescritura completa v3"

# 3. El script automáticamente:
#    - Actualiza archivo VERSION
#    - Actualiza CHANGELOG.md
#    - Crea commit de versión
#    - Crea tag de git

# 4. Push a GitHub
git push origin main
git push origin v<nueva-version>
```

#### Opción 2: Proceso Manual

```bash
# 1. Actualizar VERSION
echo "2.1.0" > VERSION

# 2. Actualizar CHANGELOG.md
# Agregar sección para la nueva versión con fecha

# 3. Commit y tag
git add VERSION CHANGELOG.md
git commit -m "chore: bump version to v2.1.0"
git tag -a v2.1.0 -m "Release v2.1.0"

# 4. Push
git push origin main
git push origin v2.1.0
```

### Workflow Automático

Cuando se hace push de un tag `v*.*.*`, GitHub Actions automáticamente:

1. ✅ Ejecuta todos los tests de CI
2. ✅ Genera checksums del código
3. ✅ Crea el release en GitHub
4. ✅ Sube artefactos (tarball, checksums)
5. ✅ Genera release notes desde CHANGELOG.md

### Formato del CHANGELOG

```markdown
## [2.1.0] - 2025-01-18

### ✨ Agregado
- Nueva característica X
- Soporte para Y

### 🔧 Cambiado
- Mejora en Z

### 🐛 Corregido
- Fix para issue #123

### 🗑️ Removido
- Característica obsoleta W
```

### Pre-Release Checklist

Antes de crear un release:

- [ ] Todos los tests pasan localmente
- [ ] CI/CD en GitHub Actions está verde
- [ ] CHANGELOG.md está actualizado
- [ ] README.md refleja los cambios (si es necesario)
- [ ] Documentación está actualizada
- [ ] No hay issues críticos abiertos
- [ ] Version bump es apropiado (major/minor/patch)

### Post-Release

Después del release:

1. Verifica que el release se creó correctamente en GitHub
2. Verifica que los artefactos están disponibles
3. Cierra los issues que fueron resueltos en este release
4. Anuncia el release (si es major o minor importante)
5. Actualiza sección [Unreleased] en CHANGELOG.md si es necesario

### Ejemplo Completo

```bash
# Estás trabajando en una nueva característica
git checkout -b feature/macos-support
# ... hacer cambios ...
git commit -m "feat: add macOS support"

# Crear PR y mergear a main

# Después del merge, crear release
git checkout main
git pull origin main

# Bump version (esto es un minor porque es nueva funcionalidad)
cd scripts
./bump-version.sh minor "Agregar soporte completo para macOS"

# Push
git push origin main
git push origin v2.1.0

# ✅ GitHub Actions crea el release automáticamente
```

---

## ❓ Preguntas

Si tienes preguntas que no están cubiertas aquí:

1. Revisa la [documentación](README.md)
2. Busca en [Issues existentes](https://github.com/emilioaray-dev/start-bash-debian/issues)
3. Abre un [nuevo Issue](https://github.com/emilioaray-dev/start-bash-debian/issues/new) con tu pregunta

---

## 🙏 Agradecimientos

¡Gracias por contribuir a hacer este proyecto mejor! Tu tiempo y esfuerzo son muy apreciados.

---

<div align="center">

**[⬆️ Volver arriba](#-guía-de-contribución)**

</div>
