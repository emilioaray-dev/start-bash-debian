#!/bin/bash

# Función para verificar el éxito de un comando
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "\n🛑 ERROR: $1"
        exit 1
    fi
}

echo "--- 🛠️ Instalación de Neofetch y Starship en Debian ---"

# 1. Instalación de Neofetch (Desde Repositorios de Debian)
echo -e "\n1. Actualizando listas de paquetes e instalando Neofetch..."
sudo apt update
check_success "No se pudo actualizar la lista de paquetes."

# Se instala Neofetch, que está disponible directamente en Debian (Trixie/Bookworm).
sudo apt install neofetch curl -y
check_success "Fallo al instalar Neofetch y curl."
echo "✅ Neofetch instalado con éxito."

# 2. Instalación de Starship (Usando el script oficial, recomendado para la versión más reciente)
echo -e "\n2. Descargando e instalando Starship..."
# Starship es un binario único que se descarga y se mueve a /usr/local/bin
curl -sS https://starship.rs/install.sh | sh
check_success "Fallo al instalar Starship."
echo "✅ Starship instalado con éxito."

# 3. Configurar Starship en .bashrc
echo -e "\n3. Configurando Starship en ~/.bashrc..."
STARSHIP_INIT_LINE='eval "$(starship init bash)"'

# Verificar si la línea ya existe para evitar duplicados
if ! grep -q "$STARSHIP_INIT_LINE" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Starship Prompt Initialization" >> ~/.bashrc
    echo "$STARSHIP_INIT_LINE" >> ~/.bashrc
    echo "✅ Starship agregado a ~/.bashrc."
else
    echo "ℹ️ Starship ya estaba configurado en ~/.bashrc. Omitiendo la adición."
fi

# 4. Aplicar los cambios inmediatamente
echo -e "\n4. Aplicando los cambios de ~/.bashrc a la sesión actual..."
source ~/.bashrc
echo "✅ Script finalizado. ¡Su terminal ya está configurada!"

echo -e "\n--- Instrucciones de Uso ---\n"
echo "Para ver su configuración de sistema, ejecute: neofetch"
echo "Para que el prompt Starship se aplique de forma permanente, debe **abrir una nueva terminal**."