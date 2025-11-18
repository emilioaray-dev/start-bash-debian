# 🚀 Terminal Setup - Neofetch + Starship

[![CI Status](https://github.com/emilioaray-dev/start-bash-debian/workflows/CI%20-%20Test%20%26%20Validate/badge.svg)](https://github.com/emilioaray-dev/start-bash-debian/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/github/v/release/emilioaray-dev/start-bash-debian)](https://github.com/emilioaray-dev/start-bash-debian/releases)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

Script profesional de instalación automatizada para configurar un entorno de terminal productivo en sistemas **Linux** (Debian/Ubuntu) y **macOS**, incluyendo **Neofetch** y **Starship**.

Ideal para:
- 🍎 **macOS** (con Homebrew)
- 🏠 Templates de Proxmox
- 🐧 Contenedores LXC
- 💻 Máquinas Virtuales
- 🖥️ Servidores Debian/Ubuntu
- 👨‍💻 Entornos de desarrollo

---

## ✨ Características

### 🎯 Herramientas Incluidas

| Herramienta | Descripción |
|-------------|-------------|
| **Neofetch** | Muestra información del sistema de forma atractiva (OS, Kernel, CPU, RAM, etc.) |
| **Starship** | Prompt minimalista, rápido y rico en funciones (git status, versiones de lenguajes, etc.) |

### 🔥 Características del Script

- ✅ **Soporte Multi-Plataforma**: Linux (Debian/Ubuntu) y macOS
- ✅ **Instalación con/sin privilegios**: Modo sistema (sudo) o modo local (sin sudo)
- ✅ **Homebrew en macOS**: Instalación y configuración automática de Homebrew
- ✅ **Verificación inteligente de permisos**: Detecta automáticamente los permisos disponibles
- ✅ **Multi-distribución**: Debian 11/12, Ubuntu 20.04/22.04/24.04, Proxmox, macOS
- ✅ **Logging profesional**: Registro detallado de todas las operaciones
- ✅ **Dry-run mode**: Simula la instalación sin realizar cambios
- ✅ **Configuraciones personalizadas**: Setup optimizado de Starship y Neofetch
- ✅ **Desinstalación limpia**: Script de desinstalación completo
- ✅ **Verificación post-instalación**: Validación automática de la instalación
- ✅ **Backups automáticos**: Respaldo de configuraciones antes de modificar
- ✅ **CI/CD integrado**: Tests automatizados en múltiples distribuciones y macOS

---

## 📋 Requisitos

### Linux (Debian/Ubuntu)
- Sistema operativo basado en Debian (Debian, Ubuntu, Proxmox LXC)
- Conexión a Internet
- Para instalación de sistema: acceso `sudo` o `root`
- Para instalación local: no requiere privilegios especiales

### macOS
- macOS 10.15 (Catalina) o superior
- Conexión a Internet
- Homebrew (se instala automáticamente si no está presente)
- No requiere privilegios de administrador para instalación con Homebrew

---

## 🚀 Instalación Rápida

### 🍎 macOS

**Opción 1: Instalación directa (Recomendada para macOS)**

```bash
curl -fsSL https://raw.githubusercontent.com/emilioaray-dev/start-bash-debian/main/scripts/setup_terminal.sh | bash
```

**Opción 2: Clonar repositorio**

```bash
git clone https://github.com/emilioaray-dev/start-bash-debian.git
```

```bash
cd start-bash-debian/scripts
```

```bash
./setup_terminal.sh
```

**Nota**: En macOS, el script usa Homebrew automáticamente. Si no lo tienes instalado, el script te ofrecerá instalarlo.

### 🐧 Linux (Debian/Ubuntu)

**Instalación de sistema (requiere sudo)**

```bash
curl -fsSL https://raw.githubusercontent.com/emilioaray-dev/start-bash-debian/main/scripts/setup_terminal.sh | sudo bash
```

**Instalación local (sin sudo)**

```bash
curl -fsSL https://raw.githubusercontent.com/emilioaray-dev/start-bash-debian/main/scripts/setup_terminal.sh | bash -s -- --local
```

### Opción 2: Instalación Manual (Más Seguro)

**1. Clonar el repositorio**

```bash
git clone https://github.com/emilioaray-dev/start-bash-debian.git
```

```bash
cd start-bash-debian
```

**2. Dar permisos de ejecución**

```bash
chmod +x scripts/*.sh
```

**3. Ejecutar instalación**

```bash
cd scripts
```

**Instalación de sistema**

```bash
sudo ./setup_terminal.sh
```

**O instalación local**

```bash
./setup_terminal.sh --local
```

### Opción 3: Descarga Directa

**Descargar script**

```bash
wget https://raw.githubusercontent.com/emilioaray-dev/start-bash-debian/main/scripts/setup_terminal.sh
```

**Dar permisos**

```bash
chmod +x setup_terminal.sh
```

**Ejecutar**

```bash
sudo ./setup_terminal.sh
```

---

## 📖 Uso del Script

### Sintaxis General

```bash
./setup_terminal.sh [OPCIONES]
```

### Opciones Disponibles

| Opción | Descripción |
|--------|-------------|
| `-l, --local` | Instalación solo para usuario actual (sin sudo) |
| `-s, --system` | Instalación a nivel sistema (requiere sudo) **[por defecto]** |
| `-c, --config FILE` | Usar archivo de configuración personalizado |
| `-d, --dry-run` | Simular instalación sin ejecutar comandos |
| `-y, --yes` | Aceptar todas las confirmaciones automáticamente |
| `-v, --verbose` | Mostrar salida detallada (modo debug) |
| `--skip-neofetch` | No instalar Neofetch |
| `--skip-starship` | No instalar Starship |
| `--verify` | Verificar instalación existente |
| `-h, --help` | Mostrar ayuda |
| `--version` | Mostrar versión |

### Ejemplos de Uso

**Instalación estándar con confirmación**

```bash
sudo ./setup_terminal.sh
```

**Instalación automática sin confirmaciones**

```bash
sudo ./setup_terminal.sh --yes
```

**Instalación local (sin sudo)**

```bash
./setup_terminal.sh --local
```

**Simular instalación (no hace cambios)**

```bash
./setup_terminal.sh --dry-run
```

**Instalar solo Starship**

```bash
sudo ./setup_terminal.sh --skip-neofetch
```

**Instalación verbose para debugging**

```bash
sudo ./setup_terminal.sh --verbose
```

**Verificar instalación existente**

```bash
./setup_terminal.sh --verify
```

---

## 🗑️ Desinstalación

### Script de Desinstalación

```bash
cd scripts
```

**Desinstalación estándar (mantiene configuraciones)**

```bash
sudo ./uninstall.sh
```

**Desinstalación completa (elimina también configuraciones)**

```bash
sudo ./uninstall.sh --remove-config
```

**Desinstalar solo Starship**

```bash
sudo ./uninstall.sh --skip-neofetch
```

**Simular desinstalación**

```bash
./uninstall.sh --dry-run
```

### Opciones de Desinstalación

| Opción | Descripción |
|--------|-------------|
| `--remove-config` | Eliminar también archivos de configuración |
| `--skip-neofetch` | No desinstalar Neofetch |
| `--skip-starship` | No desinstalar Starship |
| `-d, --dry-run` | Simular desinstalación sin ejecutar |
| `-y, --yes` | Aceptar todas las confirmaciones |
| `-h, --help` | Mostrar ayuda |

---

## ✅ Verificación

### Script de Verificación

```bash
cd scripts
```

**Verificación estándar**

```bash
./verify.sh
```

**Verificación verbose**

```bash
./verify.sh --verbose
```

**Verificar sin tests de funcionalidad**

```bash
./verify.sh --skip-tests
```

El script de verificación comprueba:
- ✅ Instalación de Neofetch y Starship
- ✅ Configuración del shell (.bashrc, .zshrc)
- ✅ Archivos de configuración
- ✅ Permisos de ejecución
- ✅ Tests de funcionalidad
- ✅ Problemas comunes

---

## 📁 Estructura del Proyecto

```
start-bash-debian/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI/CD - Tests automatizados
│       └── release.yml         # Automatización de releases
├── config/
│   ├── starship.toml           # Configuración optimizada de Starship
│   └── neofetch.conf           # Configuración de Neofetch
├── scripts/
│   ├── setup_terminal.sh       # 🔧 Script principal de instalación
│   ├── uninstall.sh            # 🗑️ Script de desinstalación
│   ├── verify.sh               # ✅ Script de verificación
│   └── lib/
│       ├── colors.sh           # Sistema de colores
│       ├── logger.sh           # Sistema de logging
│       └── utils.sh            # Utilidades comunes
├── tests/
│   └── test_installation.sh    # Tests de instalación
├── docs/
│   └── TROUBLESHOOTING.md      # Solución de problemas
├── README.md                    # Esta documentación
├── CONTRIBUTING.md              # Guía para contribuidores
├── LICENSE                      # Licencia MIT
└── CHANGELOG.md                 # Registro de cambios
```

---

## 🎨 Configuración Personalizada

### Starship

El script instala una configuración optimizada de Starship. Puedes editarla con nano:

```bash
nano ~/.config/starship.toml
```

O con tu editor favorito:

```bash
vim ~/.config/starship.toml
```

**Características de la configuración incluida:**
- 🌲 Git status avanzado
- 📦 Versiones de Node, Python, Go, Rust, etc.
- ⏱️ Duración de comandos
- 👤 Usuario y hostname
- 📁 Directorio actual con iconos
- 🔋 Indicador de batería
- ☁️ Contexto de AWS, GCloud, Azure

### Neofetch

Configuración disponible en:

```bash
nano ~/.config/neofetch/config.conf
```

---

## 🔧 Troubleshooting

### Problema: Error de permisos

```
Error: Could not open lock file /var/lib/apt/lists/lock
```

**Solución 1: Usar sudo para instalación de sistema**

```bash
sudo ./setup_terminal.sh
```

**Solución 2: Usar instalación local**

```bash
./setup_terminal.sh --local
```

### Problema: Starship no aparece después de instalar

**Solución 1: Recargar configuración de Bash**

```bash
source ~/.bashrc
```

**Solución 2: Recargar configuración de Zsh**

```bash
source ~/.zshrc
```

**Solución 3: Cerrar y abrir una nueva terminal**

### Problema: Comando no encontrado después de instalación local

**Solución: Agregar ~/.local/bin al PATH**

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

```bash
source ~/.bashrc
```

### Ver logs detallados

Los logs se guardan automáticamente en:

```
/tmp/setup_terminal_YYYYMMDD_HHMMSS.log
```

**Ver último log**

```bash
ls -lt /tmp/setup_terminal_*.log | head -n1 | awk '{print $NF}' | xargs cat
```

Para más ayuda, consulta [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 🧪 Testing y CI/CD

El proyecto incluye tests automatizados que se ejecutan en:
- ✅ Debian 12 (Bookworm)
- ✅ macOS Latest

### Ejecutar tests localmente

**Test de instalación dry-run**

```bash
./scripts/setup_terminal.sh --dry-run
```

**Verificación**

```bash
./scripts/verify.sh
```

**ShellCheck (si está instalado)**

```bash
shellcheck scripts/*.sh scripts/lib/*.sh
```

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor lee [CONTRIBUTING.md](CONTRIBUTING.md) para detalles sobre nuestro código de conducta y el proceso para enviar pull requests.

### Proceso de Contribución

**1. Fork el proyecto**

**2. Crea tu rama de feature**

```bash
git checkout -b feature/AmazingFeature
```

**3. Commit tus cambios**

```bash
git commit -m 'Add some AmazingFeature'
```

**4. Push a la rama**

```bash
git push origin feature/AmazingFeature
```

**5. Abre un Pull Request**

---

## 📊 Compatibilidad

| Plataforma | Versión | Estado |
|------------|---------|--------|
| **macOS** | Catalina (10.15+) | ✅ Soportado |
| **macOS** | Big Sur (11.x) | ✅ Soportado |
| **macOS** | Monterey (12.x) | ✅ Soportado |
| **macOS** | Ventura (13.x) | ✅ Soportado |
| **macOS** | Sonoma (14.x) | ✅ Soportado |
| **macOS** | Sequoia (15.x) | ✅ Soportado |
| Debian | 11 (Bullseye) | ✅ Soportado |
| Debian | 12 (Bookworm) | ✅ Soportado |
| Ubuntu | 20.04 LTS | ✅ Soportado |
| Ubuntu | 22.04 LTS | ✅ Soportado |
| Ubuntu | 24.04 LTS | ✅ Soportado |
| Proxmox | LXC Containers | ✅ Soportado |
| Linux Mint | 20/21 | ⚠️ No probado |
| Pop!_OS | 22.04 | ⚠️ No probado |

---

## 📝 Changelog

Ver [CHANGELOG.md](CHANGELOG.md) para una lista de cambios por versión.

---

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

---

## 👤 Autor

**Emilio Aray**
- GitHub: [@emilioaray-dev](https://github.com/emilioaray-dev)
- Repositorio: [start-bash-debian](https://github.com/emilioaray-dev/start-bash-debian)

---

## 🙏 Agradecimientos

- [Neofetch](https://github.com/dylanaraps/neofetch) por Dylan Araps
- [Starship](https://starship.rs/) por el equipo de Starship
- La comunidad de código abierto

---

## ⭐ Soporte

Si este proyecto te fue útil, considera:
- ⭐ Darle una estrella al repositorio
- 🐛 Reportar bugs en [Issues](https://github.com/emilioaray-dev/start-bash-debian/issues)
- 💡 Sugerir mejoras
- 🤝 Contribuir al proyecto

---

## 📚 Recursos Adicionales

- [Documentación de Starship](https://starship.rs/config/)
- [Wiki de Neofetch](https://github.com/dylanaraps/neofetch/wiki)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)

---

<div align="center">

**[⬆️ Volver arriba](#-terminal-setup---neofetch--starship)**

Hecho con ❤️ para la comunidad

</div>
