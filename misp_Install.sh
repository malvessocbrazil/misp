#!/bin/bash
# Script de automação da instalação do MISP no Ubuntu
# Autor: Matheus Alves

# --- Variáveis ---
USERNAME="socbrazil"
PASSWORD="swLhWf4p5dEx0Q"
MISP_INSTALL_URL="https://raw.githubusercontent.com/MISP/MISP/2.5/INSTALL/INSTALL.sh"

# --- Função para criar usuário ---
create_user() {
    echo "Criando usuário $USERNAME..."
    # Cria o usuário com senha criptografada
    sudo adduser --gecos "" --disabled-password $USERNAME
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    # Adiciona ao grupo sudo
    sudo usermod -aG sudo $USERNAME
    echo "Usuário $USERNAME criado e adicionado ao grupo sudo."
}

# --- Atualiza sistema ---
update_system() {
    echo "Atualizando pacotes do sistema..."
    sudo apt update && sudo apt upgrade -y
}

# --- Download do instalador do MISP ---
download_misp_installer() {
    echo "Baixando instalador do MISP..."
    wget --no-cache -O /tmp/INSTALL.sh $MISP_INSTALL_URL
    chmod +x /tmp/INSTALL.sh
}

# --- Executa instalador como usuário ---
run_misp_installer() {
    echo "Executando instalador do MISP como $USERNAME..."
    sudo -i -u $USERNAME bash /tmp/INSTALL.sh -c
}

# --- Execução ---
create_user
update_system
download_misp_installer
run_misp_installer

echo "Instalação do MISP finalizada."
