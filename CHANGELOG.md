# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### ✨ Agregado

- **Soporte completo para macOS**: Instalación automatizada usando Homebrew
- **Detección automática de macOS**: El script detecta y se adapta automáticamente a macOS
- **Instalación de Homebrew**: Si no está presente, el script ofrece instalarlo automáticamente
- **Tests en macOS**: GitHub Actions con tests en macOS 12, 13 y latest
- **Documentación de macOS**: Instrucciones específicas y tabla de compatibilidad actualizada

### 🔧 Cambiado

- **Nombre del proyecto**: Aunque el repositorio se llama "start-bash-debian", ahora soporta macOS también
- **Sistema de detección**: Mejorado para distinguir entre Linux y macOS
- **Gestión de paquetes**: Soporte automático para Homebrew en macOS

---

## [2.0.0] - 2025-01-17

### 🎉 Reescritura Completa - Versión Profesional

Esta es una reescritura completa del proyecto con enfoque en calidad, mantenibilidad y experiencia del usuario.

### ✨ Agregado

#### Características Principales
- **Modo de Instalación Dual**: Soporte para instalación de sistema (con sudo) e instalación local (sin sudo)
- **Verificación Inteligente de Permisos**: Detección automática de privilegios disponibles
- **Sistema de Logging Profesional**: Logs detallados con niveles (DEBUG, INFO, WARN, ERROR)
- **Dry-Run Mode**: Simular instalación sin realizar cambios
- **Script de Verificación**: Validación post-instalación completa
- **Script de Desinstalación**: Desinstalación limpia y reversible
- **Backups Automáticos**: Respaldo de configuraciones antes de modificar

#### Opciones CLI
- `--local` / `-l`: Instalación local (sin sudo)
- `--system` / `-s`: Instalación de sistema (con sudo)
- `--dry-run` / `-d`: Simular sin ejecutar
- `--verbose` / `-v`: Modo debug
- `--yes` / `-y`: Aceptar todas las confirmaciones
- `--skip-neofetch`: Omitir instalación de Neofetch
- `--skip-starship`: Omitir instalación de Starship
- `--verify`: Verificar instalación existente
- `--help` / `-h`: Mostrar ayuda
- `--version`: Mostrar versión

#### Infraestructura
- **Biblioteca de Utilidades Modular**:
  - `colors.sh`: Sistema de colores y formato
  - `logger.sh`: Sistema de logging profesional
  - `utils.sh`: Funciones utilitarias comunes
- **GitHub Actions CI/CD**:
  - Tests automatizados en Debian 11/12
  - Tests en Ubuntu 20.04/22.04/24.04
  - Validación con ShellCheck
  - Escaneo de seguridad con Gitleaks
  - Validación de configuraciones
- **Workflow de Release Automático**:
  - Generación de checksums
  - Release notes automatizadas
  - Artefactos de distribución

#### Configuraciones
- **Starship**: Configuración optimizada profesional con:
  - Git status avanzado
  - Soporte para múltiples lenguajes (Node, Python, Go, Rust, Java, PHP)
  - Indicadores de cloud (AWS, GCloud, Azure)
  - Docker y Kubernetes context
  - Métricas de git
  - Formato de prompt personalizado
- **Neofetch**: Configuración base optimizada

#### Documentación
- README completo con badges y ejemplos
- CONTRIBUTING.md con guías de desarrollo
- TROUBLESHOOTING.md con soluciones a problemas comunes
- Documentación de API interna
- Ejemplos de uso extensivos

### 🔧 Cambiado

- **Estructura del Proyecto**: Reorganizada de forma profesional
  - Separación de scripts en `scripts/`
  - Configuraciones en `config/`
  - Bibliotecas en `scripts/lib/`
  - Documentación en `docs/`
  - Workflows en `.github/workflows/`

- **Detección de Sistema**: Mejorada para soportar múltiples distribuciones
- **Manejo de Errores**: Sistema robusto con mensajes descriptivos
- **Experiencia de Usuario**:
  - Mensajes de progreso claros
  - Confirmaciones interactivas (omitibles con --yes)
  - Output colorizado y formateado
  - Barra de progreso visual

### 🛠️ Mejorado

- **Seguridad**:
  - Validación de permisos antes de operaciones
  - No más ejecución directa de curl | bash sin opciones
  - Verificación de checksums en releases
  - Escaneo automatizado de secretos

- **Rendimiento**:
  - Instalación optimizada de Starship por arquitectura
  - Descarga directa de binarios cuando sea posible
  - Caché de operaciones

- **Compatibilidad**:
  - Soporte confirmado para Debian 11/12
  - Soporte confirmado para Ubuntu 20.04/22.04/24.04
  - Soporte para Proxmox LXC
  - Detección de shell (bash, zsh, fish)

- **Mantenibilidad**:
  - Código modular y reutilizable
  - Funciones bien documentadas
  - Tests automatizados
  - Análisis estático con ShellCheck

### 🐛 Corregido

- **Error de Permisos**: Ahora detecta y maneja correctamente falta de privilegios
- **PATH no actualizado**: Agrega automáticamente `~/.local/bin` al PATH en instalación local
- **Configuraciones duplicadas**: Verifica antes de agregar líneas a archivos RC
- **Limpieza incompleta**: Script de desinstalación ahora remueve todas las trazas
- **Detección de Shell**: Soporte mejorado para múltiples shells

### 🗑️ Removido

- Código legacy y redundante
- Dependencias innecesarias
- Hardcoded paths problemáticos

### 🔒 Seguridad

- Implementado análisis con ShellCheck
- Agregado scanning de secretos con Gitleaks
- Validación de inputs de usuario
- Manejo seguro de variables y paths
- No más ejecución ciega de scripts remotos

---

## [1.0.0] - 2025-01-15

### Versión Inicial

#### Agregado
- Script básico de instalación de Neofetch
- Script básico de instalación de Starship
- Configuración automática en `.bashrc`
- README básico
- Licencia MIT

#### Características
- Instalación de Neofetch desde repositorio de GitHub
- Instalación de Starship usando instalador oficial
- Configuración automática para ejecutar Neofetch al inicio
- Inicialización de Starship en bash

---

## [Unreleased]

### Planeado para futuras versiones

- [ ] Soporte para más shells (tcsh, ksh)
- [ ] Temas predefinidos para Starship
- [ ] Configuración interactiva durante instalación
- [ ] Instalación de fuentes Nerd Fonts automática
- [ ] Soporte para gestores de paquetes adicionales (snap, flatpak)
- [ ] Script de actualización automática
- [ ] Configuración de Neofetch más personalizada
- [ ] Soporte para macOS y BSD
- [ ] Tests de integración más completos
- [ ] Dashboard web para configuración

---

## Tipos de Cambios

- `Agregado` para nuevas características
- `Cambiado` para cambios en funcionalidad existente
- `Deprecado` para características que serán removidas
- `Removido` para características removidas
- `Corregido` para corrección de bugs
- `Seguridad` para vulnerabilidades corregidas

---

## Versionado

Este proyecto sigue [Semantic Versioning](https://semver.org/):
- **MAJOR**: Cambios incompatibles en la API
- **MINOR**: Funcionalidad agregada de forma compatible
- **PATCH**: Correcciones de bugs compatibles

---

<div align="center">

**[⬆️ Volver arriba](#changelog)**

</div>
