# 🚀 Setup Rápido de Terminal (Neofetch + Starship)

Este repositorio contiene un simple script de Bash diseñado para configurar instantáneamente un entorno de shell más informativo y productivo en sistemas Debian/Ubuntu/Proxmox, instalando **Neofetch** y el prompt **Starship**.

Es ideal para usar en templates de Proxmox o para la configuración inicial de cualquier nuevo contenedor LXC o Máquina Virtual (VM) de Linux.

---

## 🎯 Objetivo

El propósito de este script es asegurar que toda nueva instancia de servidor tenga, por defecto, las siguientes herramientas de productividad y diagnóstico instaladas y configuradas en `bash`:

* **Neofetch:** Muestra información esencial del sistema (OS, Kernel, CPU, RAM) de forma atractiva al ejecutar el comando.
* **Starship:** Proporciona un prompt minimalista, rápido y rico en funciones (git status, versiones de lenguaje, etc.) para mejorar la eficiencia del flujo de trabajo.

---

## 🛠️ Requisitos

* Sistema operativo basado en Debian (Debian, Ubuntu, Contenedores LXC de Proxmox).
* Acceso de superusuario (`sudo` o `root`).
* Conexión a Internet (para descargar paquetes `apt` y el binario de Starship).

---

## 💻 Instalación y Uso Rápido

Para instalar ambas herramientas y configurarlas en su shell actual, simplemente ejecute este comando en una línea:

```bash
# 1. Descargar el script (Asegúrese de cambiar la URL por la de su repositorio)
wget [https://github.com/SU_USUARIO/SU_REPOSITORIO/raw/main/setup_terminal.sh](https://github.com/SU_USUARIO/SU_REPOSITORIO/raw/main/setup_terminal.sh) -O setup_terminal.sh

# 2. Dar permisos y ejecutar
chmod +x setup_terminal.sh && sudo ./setup_terminal.sh

# 3. Limpiar (Opcional)
rm setup_terminal.sh