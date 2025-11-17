# 🔧 Solución de Problemas (Troubleshooting)

Guía de solución de problemas comunes con Terminal Setup.

---

## 📋 Tabla de Contenidos

- [Problemas de Instalación](#problemas-de-instalación)
- [Problemas de Permisos](#problemas-de-permisos)
- [Problemas con Neofetch](#problemas-con-neofetch)
- [Problemas con Starship](#problemas-con-starship)
- [Problemas de Configuración](#problemas-de-configuración)
- [Logs y Debugging](#logs-y-debugging)
- [Problemas Conocidos](#problemas-conocidos)

---

## 🚨 Problemas de Instalación

### Error: "Could not open lock file"

**Síntoma:**
```
Error: Could not open lock file /var/lib/apt/lists/lock - open (13: Permission denied)
```

**Causa:** Intentando instalar sin privilegios de superusuario.

**Solución:**

```bash
# Opción 1: Usar sudo
sudo ./setup_terminal.sh

# Opción 2: Instalación local (sin sudo)
./setup_terminal.sh --local
```

---

### Error: "No internet connection"

**Síntoma:**
```
❌ ERROR: No hay conexión a internet
```

**Diagnóstico:**
```bash
# Verificar conectividad
ping -c 3 github.com

# Verificar DNS
nslookup github.com

# Verificar proxy si aplica
echo $http_proxy
echo $https_proxy
```

**Soluciones:**

```bash
# Si estás detrás de un proxy
export http_proxy="http://proxy.example.com:8080"
export https_proxy="http://proxy.example.com:8080"

# Luego ejecutar instalación
./setup_terminal.sh
```

---

### Error: "Not enough disk space"

**Síntoma:**
```
❌ ERROR: Espacio en disco insuficiente
```

**Diagnóstico:**
```bash
# Verificar espacio disponible
df -h

# Ver uso por directorio
du -sh /*
```

**Soluciones:**

```bash
# Limpiar caché de apt
sudo apt-get clean
sudo apt-get autoclean

# Remover paquetes no necesarios
sudo apt-get autoremove

# Limpiar logs antiguos
sudo journalctl --vacuum-time=3d
```

---

## 🔐 Problemas de Permisos

### Error: "Permission denied" durante instalación local

**Síntoma:**
```
❌ ERROR: Permission denied al escribir en ~/.local/bin
```

**Solución:**

```bash
# Crear directorio con permisos correctos
mkdir -p ~/.local/bin
chmod 755 ~/.local/bin

# Verificar permisos
ls -ld ~/.local/bin
```

---

### Error: "Cannot write to .bashrc"

**Síntoma:**
```
❌ ERROR: No se puede escribir en ~/.bashrc
```

**Diagnóstico:**
```bash
# Verificar permisos
ls -l ~/.bashrc

# Verificar propietario
stat ~/.bashrc
```

**Solución:**

```bash
# Corregir permisos
chmod 644 ~/.bashrc

# Corregir propietario (si es necesario)
sudo chown $USER:$USER ~/.bashrc
```

---

## 🎨 Problemas con Neofetch

### Neofetch no muestra información correctamente

**Síntoma:** Neofetch no muestra logo o información incompleta.

**Diagnóstico:**
```bash
# Verificar instalación
which neofetch
neofetch --version

# Ejecutar con debug
neofetch --stdout
```

**Soluciones:**

```bash
# Reinstalar Neofetch
cd scripts
sudo ./uninstall.sh --skip-starship --yes
sudo ./setup_terminal.sh --skip-starship --yes

# Verificar configuración
cat ~/.config/neofetch/config.conf
```

---

### Neofetch no se ejecuta automáticamente

**Síntoma:** Neofetch instalado pero no aparece al abrir terminal.

**Diagnóstico:**
```bash
# Verificar configuración en .bashrc
grep -n "neofetch" ~/.bashrc

# Verificar que .bashrc se carga
echo $BASH_VERSION
```

**Soluciones:**

```bash
# Verificar que .bashrc se ejecuta en login shell
# Agregar a ~/.bash_profile o ~/.profile si es necesario
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Recargar configuración
source ~/.bashrc
```

---

## ⚡ Problemas con Starship

### Starship no aparece después de instalar

**Síntoma:** Terminal sigue mostrando prompt antiguo.

**Diagnóstico:**
```bash
# Verificar instalación
which starship
starship --version

# Verificar configuración en shell RC
case $(basename $SHELL) in
    bash)
        grep -n "starship init" ~/.bashrc
        ;;
    zsh)
        grep -n "starship init" ~/.zshrc
        ;;
esac
```

**Soluciones:**

```bash
# Para Bash
source ~/.bashrc

# Para Zsh
source ~/.zshrc

# Si el problema persiste, reiniciar terminal
exit
# Abrir nueva terminal
```

---

### Starship muestra caracteres raros

**Síntoma:** Caracteres cuadrados o símbolos incorrectos en el prompt.

**Causa:** Falta de fuentes Nerd Fonts.

**Solución:**

```bash
# Instalar fuente Nerd Font (ejemplo con FiraCode)
# En Debian/Ubuntu:
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Descargar fuente
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
unzip FiraCode.zip
rm FiraCode.zip

# Actualizar caché de fuentes
fc-cache -fv

# Configurar terminal para usar la fuente
# (varía según terminal - consulta documentación de tu terminal)
```

---

### Starship muy lento

**Síntoma:** Delay notable antes de mostrar prompt.

**Diagnóstico:**
```bash
# Verificar módulos activos
starship timings
```

**Soluciones:**

```bash
# Editar configuración para deshabilitar módulos lentos
nano ~/.config/starship.toml

# Agregar al archivo:
[cmd_duration]
min_time = 500  # Aumentar threshold

[git_status]
disabled = false
# Optimizar git status para repos grandes
ahead_behind_limit = 10
```

---

## ⚙️ Problemas de Configuración

### Configuración de Starship no se aplica

**Diagnóstico:**
```bash
# Verificar archivo existe
ls -l ~/.config/starship.toml

# Verificar sintaxis
starship config
```

**Solución:**

```bash
# Validar TOML
# Si hay errores, corregir o regenerar:
mv ~/.config/starship.toml ~/.config/starship.toml.backup
cd scripts
./setup_terminal.sh --skip-neofetch
```

---

### Cambios en .bashrc no se aplican

**Síntoma:** Modificaciones no tienen efecto.

**Soluciones:**

```bash
# Asegúrate de recargar
source ~/.bashrc

# Verificar que no hay errores de sintaxis
bash -n ~/.bashrc

# Si hay errores, restaurar backup
ls -lt ~/.bashrc.backup* | head -1
# Copiar el backup más reciente de vuelta si es necesario
```

---

## 📝 Logs y Debugging

### Ver logs de instalación

```bash
# Logs se guardan en /tmp/
ls -lt /tmp/setup_terminal_*.log | head -5

# Ver último log
tail -f /tmp/setup_terminal_*.log | tail -1

# Buscar errores en log
grep -i error /tmp/setup_terminal_*.log
```

### Modo verbose

```bash
# Ejecutar instalación con debug
./setup_terminal.sh --verbose --dry-run

# Ejecutar verificación con verbose
./scripts/verify.sh --verbose
```

### Debug manual

```bash
# Verificar variables de entorno
env | grep -E "SHELL|HOME|USER|PATH"

# Verificar proceso de shell
ps -p $$

# Ver configuración de shell
echo $SHELL
$SHELL --version
```

---

## 🐛 Problemas Conocidos

### 1. Conflicto con Oh My Bash/Zsh

**Síntoma:** Starship no funciona con Oh My Bash/Zsh instalado.

**Solución:**
```bash
# Starship debe inicializarse DESPUÉS de Oh My Bash/Zsh
# Asegúrate que en .bashrc/.zshrc:

# Oh My Bash/Zsh primero
source ~/.oh-my-bash/bashrc  # o oh-my-zsh

# Starship después
eval "$(starship init bash)"  # o zsh
```

---

### 2. PATH no incluye ~/.local/bin después de instalación

**Solución automática durante instalación:**
El script ahora agrega automáticamente al PATH.

**Solución manual:**
```bash
# Agregar a ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

### 3. Múltiples instalaciones de Neofetch

**Síntoma:** Diferentes versiones en PATH.

**Diagnóstico:**
```bash
# Encontrar todas las instalaciones
which -a neofetch
```

**Solución:**
```bash
# Desinstalar todas
./scripts/uninstall.sh --skip-starship
# Reinstalar
./scripts/setup_terminal.sh --skip-starship
```

---

## 🆘 Obtener Ayuda

Si ninguna de estas soluciones funciona:

1. **Recopila información:**
   ```bash
   # Sistema
   uname -a
   lsb_release -a

   # Shell
   echo $SHELL
   $SHELL --version

   # Instalación
   which neofetch starship
   neofetch --version
   starship --version

   # Configuración
   grep -n "neofetch\|starship" ~/.bashrc

   # Último log
   tail -100 /tmp/setup_terminal_*.log | tail -1
   ```

2. **Crea un Issue en GitHub:**
   - Ir a: https://github.com/emilioaray-dev/start-bash-debian/issues
   - Incluir toda la información recopilada
   - Describir el problema detalladamente
   - Indicar pasos para reproducir

3. **Formato recomendado para Issues:**
   ```markdown
   ## Descripción del Problema
   [Descripción clara]

   ## Entorno
   - OS: [ej. Debian 12]
   - Shell: [ej. bash 5.2]
   - Modo: [local/sistema]

   ## Pasos para Reproducir
   1. ...
   2. ...

   ## Logs/Output
   ```
   [logs aquí]
   ```

   ## Ya intenté
   - [ ] Reinstalar
   - [ ] Verificar permisos
   - [ ] Revisar logs
   ```

---

## 🔄 Reinstalación Limpia

Si nada funciona, reinstalación completa:

```bash
# 1. Backup de configuraciones personalizadas (si las tienes)
cp ~/.config/starship.toml ~/starship.toml.backup
cp ~/.config/neofetch/config.conf ~/neofetch.conf.backup

# 2. Desinstalación completa
cd scripts
sudo ./uninstall.sh --remove-config --yes

# 3. Limpiar residuos
rm -rf ~/.cache/starship
rm -rf /tmp/neofetch*

# 4. Reinstalación
sudo ./setup_terminal.sh --yes

# 5. Restaurar configuraciones si es necesario
cp ~/starship.toml.backup ~/.config/starship.toml
cp ~/neofetch.conf.backup ~/.config/neofetch/config.conf
```

---

<div align="center">

**[⬆️ Volver arriba](#-solución-de-problemas-troubleshooting)**

</div>
