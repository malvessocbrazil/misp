Automação de Instalação do MISP para Ubuntu Server

Este repositório contém scripts shell projetados para automatizar a instalação da plataforma de inteligência de ameaças (Threat Intelligence) MISP em servidores Ubuntu.

O principal objetivo desses scripts é simplificar o processo de setup, incluindo a criação de um usuário de gerenciamento e a correção automática do problema comum de redirecionamento para https://misp.local que ocorre após a instalação padrão.

📦 Versões Disponíveis

MISP 2.5 — Compatível com Ubuntu Server 24.04 LTS

MISP 2.4 — Compatível com Ubuntu Server 22.04 LTS

⚠️ Observação:
O script da versão 2.4 não deve ser executado como usuário root.
Utilize um usuário com privilégios sudo para garantir que a instalação ocorra corretamente.

✅ Pré-requisitos

Antes de executar qualquer script, certifique-se de que seu ambiente atende aos seguintes requisitos:

Sistema Operacional: Ubuntu Server 22.04 LTS ou 24.04 LTS

Acesso: Acesso root ou usuário com privilégios sudo

Conectividade: Acesso à internet para baixar pacotes e dependências necessárias

🌍 MISP Installation Automation for Ubuntu Server

This repository contains shell scripts designed to automate the installation of the MISP Threat Intelligence platform on Ubuntu servers.

The main goal of these scripts is to simplify the setup process, including the creation of a management user and the automatic fix for the common redirection issue to https://misp.local that occurs after a standard installation.

📦 Available Versions

MISP 2.5 — Compatible with Ubuntu Server 24.04 LTS

MISP 2.4 — Compatible with Ubuntu Server 22.04 LTS

⚠️ Note:
The 2.4 script must not be executed as the root user.
Use a user with sudo privileges instead.

✅ Prerequisites

Before running any script, ensure your environment meets the following requirements:

Operating System: Ubuntu Server 22.04 LTS or 24.04 LTS

Access: Root or sudo-enabled user

Connectivity: Internet access to download required packages and dependencies
