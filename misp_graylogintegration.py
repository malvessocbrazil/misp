#!/usr/bin/env python3
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

from pymisp import PyMISP
import requests
import json
import time

# ========================
# CONFIGURAÇÕES
# ========================
MISP_URL = "https://194.163.128.245"
MISP_KEY = "YWUe8RVtX27JRg5QRoJ7Uhd3TigW7Br4wsmiyfGw"
GRAYLOG_INPUT = "http://65.109.29.30:12201/gelf"
VERIFY_SSL = False  # True se tiver certificado válido

# ========================
# FUNÇÃO PRINCIPAL
# ========================
def main():
    try:
        print("[+] Conectando ao MISP...")
        misp = PyMISP(MISP_URL, MISP_KEY, VERIFY_SSL)
        result = misp.search(controller='attributes', timestamp='24h')

        if not result or "Attribute" not in result:
            print("[-] Nenhum IOC encontrado nas últimas 24h.")
            return

        print(f"[+] {len(result['Attribute'])} IOCs encontrados, enviando para o Graylog...")

        enviados = 0
        for attr in result["Attribute"]:
            payload = {
                "short_message": "IOC from MISP",
                "host": "misp-server",
                "level": 5,
                "_ioc_type": attr.get("type", ""),
                "_ioc_value": attr.get("value", ""),
                "_event_id": attr.get("event_id", ""),
                "_category": attr.get("category", ""),
                "_comment": attr.get("comment", ""),
                "_timestamp": attr.get("timestamp", "")
            }

            try:
                r = requests.post(GRAYLOG_INPUT, json=payload, timeout=10)
                if r.status_code == 202:
                    print(f"[OK] IOC enviado: {attr['value']}")
                    enviados += 1
                else:
                    print(f"[ERRO] Graylog retornou {r.status_code}: {r.text}")
            except requests.exceptions.RequestException as e:
                print(f"[ERRO] Falha ao enviar para Graylog: {e}")

            time.sleep(0.3)  # pequena pausa para evitar flood

        print(f"[+] Total de IOCs enviados: {enviados}")

    except Exception as e:
        print(f"[FALHA GERAL] {e}")

# ========================
# EXECUÇÃO
# ========================
if __name__ == "__main__":
    main()
