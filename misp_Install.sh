#!/bin/bash
# install_misp_prompt.sh
# Script para automatizar instalação do MISP perguntando o nome de usuário e a senha que quer criar
# Uso: sudo ./install_misp_prompt.sh
# Autor : Matheus Alves 
set -euo pipefail

MISP_INSTALL_URL="https://raw.githubusercontent.com/MISP/MISP/2.5/INSTALL/INSTALL.sh"
TMP_INSTALLER="/tmp/INSTALL.sh"

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Este script precisa ser executado como root. Use: sudo $0"
        exit 1
    fi
}

prompt_credentials() {
    # Pergunta o nome do usuário
    while true; do
        read -rp "Digite o NOME DO USUÁRIO que deseja criar (ex: socbrazil): " USERNAME
        USERNAME="${USERNAME## }"
        USERNAME="${USERNAME%% }"
        if [[ -z "$USERNAME" ]]; then
            echo "Nome de usuário não pode ser vazio. Tente novamente."
            continue
        fi
        if id -u "$USERNAME" &>/dev/null; then
            echo "O usuário '$USERNAME' já existe. Digite outro nome."
            continue
        fi
        break
    done

    # Pergunta a senha que o usuário quer criar (com confirmação)
    while true; do
        read -srp "Digite a SENHA que deseja criar para '$USERNAME': " PASSWORD
        echo
        read -srp "Confirme a SENHA: " PASSWORD2
        echo
        if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
            echo "As senhas não conferem. Tente novamente."
            continue
        fi
        if [[ ${#PASSWORD} -lt 8 ]]; then
            echo "Aviso: a senha tem menos de 8 caracteres. Recomendado ≥8. Deseja usar mesmo assim? [S/n]"
            read -r REPLY
            REPLY=${REPLY:-S}
            if [[ "$REPLY" =~ ^[Nn] ]]; then
                continue
            fi
        fi
        break
    done
}

prompt_sudoers_file() {
    echo -n "Deseja criar um arquivo em /etc/sudoers.d/ permitindo sudo para $USERNAME? [S/n]: "
    read -r REPLY
    REPLY=${REPLY:-S}
    if [[ "$REPLY" =~ ^[Nn] ]]; then
        CREATE_SUDOERS="no"
    else
        CREATE_SUDOERS="yes"
    fi
}

create_user() {
    echo "Criando usuário '$USERNAME'..."
    adduser --gecos "" --disabled-password "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    usermod -aG sudo "$USERNAME"
    echo "Usuário '$USERNAME' criado e adicionado ao grupo sudo."
}

create_sudoers_entry() {
    if [[ "$CREATE_SUDOERS" == "yes" ]]; then
        SUDO_FILE="/etc/sudoers.d/${USERNAME}"
        echo "Criando $SUDO_FILE..."
        echo "${USERNAME} ALL=(ALL:ALL) ALL" > "$SUDO_FILE"
        chmod 0440 "$SUDO_FILE"
        # valida com visudo
        if ! visudo -cf "$SUDO_FILE" >/dev/null 2>&1; then
            echo "Erro: validação do sudoers falhou para $SUDO_FILE. Removendo arquivo."
            rm -f "$SUDO_FILE"
            exit 1
        fi
        echo "Arquivo $SUDO_FILE criado com sucesso."
    else
        echo "Pulando criação do arquivo em /etc/sudoers.d/ (usar grupo sudo)."
    fi
}

update_system() {
    echo "Atualizando pacotes do sistema..."
    apt update && apt upgrade -y
}

download_misp_installer() {
    echo "Baixando instalador do MISP para $TMP_INSTALLER..."
    wget --no-cache -O "$TMP_INSTALLER" "$MISP_INSTALL_URL"
    chmod +x "$TMP_INSTALLER"
    echo "Instalador baixado."
}

run_misp_installer() {
    echo "Executando instalador do MISP como $USERNAME..."
    sudo -i -u "$USERNAME" bash "$TMP_INSTALLER" -c
    echo "Instalador finalizado (rodado como $USERNAME)."
}

cleanup() {
    echo -n "Deseja remover o instalador temporário $TMP_INSTALLER? [S/n]: "
    read -r REPLY
    REPLY=${REPLY:-S}
    if [[ "$REPLY" =~ ^[Nn] ]]; then
        echo "Mantendo $TMP_INSTALLER."
    else
        rm -f "$TMP_INSTALLER"
        echo "Instalador removido."
    fi
}

# Fluxo principal
require_root
prompt_credentials
prompt_sudoers_file
create_user
create_sudoers_entry
update_system
download_misp_installer
run_misp_installer
cleanup

echo "Script finalizado com sucesso."
