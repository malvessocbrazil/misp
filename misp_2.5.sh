#!/bin/bash
# Script para criar um usuário de gerenciamento, instalar o MISP 
# Autor: Matheus Alves

set -euo pipefail

MISP_INSTALL_URL="https://raw.githubusercontent.com/MISP/MISP/refs/heads/2.5/INSTALL/INSTALL.ubuntu2404.sh"

# --- 1. VERIFICAÇÃO DE ROOT ---
if [ "$EUID" -ne 0 ]; then
  echo " Este script precisa ser executado como root. Use: sudo ./misp_install_v2.sh"
  exit 1
fi

# --- 2. CRIAÇÃO DO USUÁRIO DE GERENCIAMENTO ---
echo "==============================================="
echo " Criando usuário de gerenciamento"
echo "==============================================="

read -p "Informe o nome do usuário que deseja criar: " USERNAME
read -s -p "Informe a senha para o usuário $USERNAME: " PASSWORD
echo

if id "$USERNAME" &>/dev/null; then
  echo "Usuário $USERNAME já existe, pulando criação..."
else
  echo " Criando usuário $USERNAME..."
  adduser --quiet --disabled-password --gecos "" "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd
  usermod -aG sudo "$USERNAME"
  echo " Usuário $USERNAME criado com privilégios sudo."
fi

# --- 3. CONFIGURAÇÃO DO ENDEREÇO DE ACESSO (IP/FQDN) ---
echo "==============================================="
echo " Configurando o endereço de acesso do MISP"
echo "==============================================="
echo "Para evitar o redirecionamento para 'misp.local',"
echo "informe o endereço IP ou o nome de domínio (FQDN)"
echo "que você usará para acessar o MISP."
echo "Exemplo: 192.168.15.9 ou misp.suaempresa.com"
echo

# Loop para garantir que a entrada não seja vazia
while true; do
    read -p "Informe o IP ou FQDN para o MISP: " MISP_HOSTNAME
    if [ -n "$MISP_HOSTNAME" ]; then
        break
    else
        echo "O endereço não pode ser vazio. Por favor, tente novamente."
    fi
done

# --- 4. PREPARAÇÃO DO SISTEMA ---
echo "==============================================="
echo " Atualizando o sistema..."
echo "==============================================="

while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
  echo " Aguardando outro processo de pacote terminar..."
  sleep 5
done

apt-get update -y && apt-get upgrade -y

# --- 5. DOWNLOAD E EXECUÇÃO DO INSTALADOR ---
echo "==============================================="
echo " Baixando instalador do MISP..."
echo "==============================================="

wget -O /tmp/INSTALL.sh "$MISP_INSTALL_URL"
chmod +x /tmp/INSTALL.sh
echo " Instalador baixado em /tmp/INSTALL.sh"

echo "==============================================="
echo " Executando instalador do MISP como ROOT..."
echo "   (O script pode pedir sua interação)"
echo "==============================================="

# Executa o instalador oficial de forma interativa (padrão)
bash /tmp/INSTALL.sh

# --- 6. CORREÇÃO DO REDIRECIONAMENTO (BASEURL) ---
echo "==============================================="
echo " Corrigindo o redirecionamento (baseurl)..."
echo "==============================================="
echo "Configurando o acesso para: https://$MISP_HOSTNAME"

# Define a URL base usando o comando cake do MISP
# Isso deve ser executado como o usuário do servidor web (www-data)
sudo -u www-data /var/www/MISP/app/Console/cake Baseurl "https://$MISP_HOSTNAME"

echo "URL base configurada com sucesso!"

# --- 7. FINALIZAÇÃO ---
echo "==============================================="
echo " Instalação e configuração do MISP concluídas!"
echo " Acesse sua instância em: https://$MISP_HOSTNAME"
echo "==============================================="
