#!/bin/bash
# install_misp_final.sh
# Script para criar um usuário de gerenciamento e instalar o MISP da forma correta.
# Autor: Matheus Alves

set -euo pipefail

MISP_INSTALL_URL="https://raw.githubusercontent.com/MISP/MISP/refs/heads/2.5/INSTALL/INSTALL.ubuntu2404.sh"

# --- 1. VERIFICAÇÃO DE ROOT ---
# Garante que o script inteiro seja executado com privilégios de root.
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script precisa ser executado como root. Use: sudo ./install_misp_final.sh"
  exit 1
fi

# --- 2. CRIAÇÃO DO USUÁRIO (Opcional, mas mantido conforme solicitado) ---
echo "==============================================="
echo "🧑 Criando usuário de gerenciamento"
echo "==============================================="

read -p "Informe o nome do usuário que deseja criar: " USERNAME
read -s -p "Informe a senha para o usuário $USERNAME: " PASSWORD
echo

if id "$USERNAME" &>/dev/null; then
  echo "⚠️  Usuário $USERNAME já existe, pulando criação..."
else
  echo "✅ Criando usuário $USERNAME..."
  adduser --quiet --disabled-password --gecos "" "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd
  usermod -aG sudo "$USERNAME"
  echo "✅ Usuário $USERNAME criado com privilégios sudo."
fi

# --- 3. PREPARAÇÃO DO SISTEMA (Como root) ---
echo "==============================================="
echo "📦 Atualizando o sistema..."
echo "==============================================="

# Aguarda liberação do lock do apt
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
  echo "⏳ Aguardando outro processo de pacote terminar..."
  sleep 5
done

apt-get update -y && apt-get upgrade -y

# --- 4. DOWNLOAD E EXECUÇÃO DO INSTALADOR (Como root) ---
echo "==============================================="
echo "⬇️  Baixando instalador do MISP..."
echo "==============================================="

wget -O /tmp/INSTALL.sh "$MISP_INSTALL_URL"
chmod +x /tmp/INSTALL.sh
echo "✅ Instalador baixado em /tmp/INSTALL.sh"

echo "==============================================="
echo "🚀 Executando instalador do MISP como ROOT..."
echo "   (Esta é a maneira correta)"
echo "==============================================="

# A MUDANÇA CRUCIAL:
# Executamos o instalador diretamente. Como nosso script já está rodando como root,
# o INSTALL.sh herda esses privilégios e poderá criar logs em /var/log/ e
# instalar tudo sem erros de permissão.
bash /tmp/INSTALL.sh

echo "==============================================="
echo "✅ Instalação do MISP concluída com sucesso!"
echo "==============================================="
