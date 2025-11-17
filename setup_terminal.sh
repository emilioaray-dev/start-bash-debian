#!/bin/bash

# Función para verificar el éxito de un comando
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "\n🛑 ERROR: $1"
        exit 1
    fi
}

echo "--- 🛠️ Instalación de Neofetch y Starship en Debian ---"

# --- PASO 1: Habilitar Repositorios Contrib y Non-Free ---
echo -e "\n1. Habilitando repositorios 'contrib' y 'non-free'..."
# Usa 'sed' para añadir 'contrib non-free' a todas las líneas 'main' en sources.list
# Esto es necesario para encontrar 'neofetch' en instalaciones mínimas de Debian.
sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
check_success "Fallo al modificar /etc/apt/sources.list"

# --- PASO 2: Actualizar e Instalar Neofetch (y curl) ---
echo -e "\n2. Actualizando listas de paquetes e instalando Neofetch..."

# Actualiza la lista de paquetes para incluir los nuevos repositorios
apt update
check_success "No se pudo actualizar la lista de paquetes."

# Instala Neofetch (ahora debe encontrarse) y curl
apt install neofetch curl -y
check_success "Fallo al instalar Neofetch y curl."
echo "✅ Neofetch instalado con éxito."

# --- PASO 3: Instalar Starship (Usando el script oficial) ---
echo -e "\n3. Descargando e instalando Starship..."
# El script debe ejecutarse sin sudo ya que el comando principal se ejecuta como root/sudo
curl -sS https://starship.rs/install.sh | sh
check_success "Fallo al instalar Starship."
echo "✅ Starship instalado con éxito."

# --- PASO 4: Configurar Starship en .bashrc ---
echo -e "\n4. Configurando Starship en ~/.bashrc..."
STARSHIP_INIT_LINE='eval "$(starship init bash)"'

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