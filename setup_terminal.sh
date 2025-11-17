#!/bin/bash

# Función para verificar el éxito de un comando
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "\n🛑 ERROR: $1"
        exit 1
    fi
}

echo "--- 🛠️ Instalación de Neofetch y Starship en Debian (Versión robusta) ---"

# --- PASO 1: Instalación de Dependencias Esenciales ---
echo -e "\n1. Instalando dependencias (git, make, curl)..."
# Usamos apt update antes de instalar cualquier cosa
apt update
check_success "No se pudo actualizar la lista de paquetes."

# Instalamos git, make (para Neofetch source) y curl (para Starship)
apt install git make curl -y
check_success "Fallo al instalar las dependencias básicas."
echo "✅ Dependencias instaladas con éxito."

# --- PASO 2: Instalación de Neofetch (Desde el repositorio de Git) ---
echo -e "\n2. Clonando e instalando Neofetch desde GitHub..."

# Directorio temporal para la compilación
NEOFETCH_DIR="/tmp/neofetch"
rm -rf "$NEOFETCH_DIR"

# Clonar el repositorio y moverse a él
git clone https://github.com/dylanaraps/neofetch "$NEOFETCH_DIR"
check_success "Fallo al clonar el repositorio de Neofetch."

cd "$NEOFETCH_DIR"
# Instalar el programa en /usr/local/bin
make install
check_success "Fallo al compilar e instalar Neofetch."
cd ~

echo "✅ Neofetch instalado con éxito."

# --- PASO 3: Instalación de Starship (Usando el script oficial) ---
echo -e "\n3. Descargando e instalando Starship..."
# Ejecutado con permisos de root
curl -sS https://starship.rs/install.sh | sh
check_success "Fallo al instalar Starship."
echo "✅ Starship instalado con éxito."

# --- PASO 4: Configurar Starship en .bashrc ---
echo -e "\n4. Configurando Starship en ~/.bashrc..."
STARSHIP_INIT_LINE='eval "$(starship init bash)"'
NEOFETCH_CALL_LINE='neofetch'

# 4.1. Agregar la llamada a Neofetch (¡NUEVO!)
if ! grep -q "$NEOFETCH_CALL_LINE" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Display system info on startup (Neofetch)" >> ~/.bashrc
    echo "$NEOFETCH_CALL_LINE" >> ~/.bashrc
    echo "✅ Llamada a Neofetch agregada a ~/.bashrc."
else
    echo "ℹ️ Neofetch ya estaba configurado para ejecución automática."
fi

# 4.2. Agregar la inicialización de Starship
if ! grep -q "$STARSHIP_INIT_LINE" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Starship Prompt Initialization" >> ~/.bashrc
    echo "$STARSHIP_INIT_LINE" >> ~/.bashrc
    echo "✅ Starship agregado a ~/.bashrc."
else
    echo "ℹ️ Starship ya estaba configurado en ~/.bashrc. Omitiendo la adición."
fi

# --- PASO 5: Aplicar los cambios inmediatamente ---
echo -e "\n5. Aplicando los cambios de ~/.bashrc a la sesión actual..."
source ~/.bashrc
echo "✅ Script finalizado. ¡Su terminal ya está configurada!"