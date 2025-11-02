#!/bin/bash
set -e # Encerra o script imediatamente se um comando falhar

echo "Iniciando a instalação automatizada do MISP..."

# 1. Baixar o script de instalação oficial (com a URL corrigida)
echo "Baixando o script de instalação..."
wget --no-cache -O /tmp/INSTALL.sh https://raw.githubusercontent.com/MISP/MISP/2.4/INSTALL/INSTALL.sh

# 2. Mudar para o diretório /tmp
echo "Mudando para o diretório /tmp..."
cd /tmp

# 3. Executar o script de instalação com a flag -c
echo "Executando o instalador do MISP..."
bash INSTALL.sh -c

echo "Script de instalação do MISP finalizado."
