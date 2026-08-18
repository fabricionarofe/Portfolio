import smtplib
import os
from email.message import EmailMessage
import time
import webbrowser
import urllib.parse
import pyautogui

# 1. Configurações de Credenciais
# RECOMENDAÇÃO: Use variáveis de ambiente para não expor suas senhas no código fonte.

EMAIL_REMETENTE = os.environ.get('EMAIL_REMETENTE', 'fabricioshit1@gmail.com')
EMAIL_SENHA = os.environ.get('EMAIL_SENHA', 'tarcginrbqcdasva')

# 2. Banco de dados simulado de contatos
usuarios_cadastrados = [
    {"nome": "Fabrício", "email": "fabricionarofe@hotmail.com", "telefone": "5591982976373"},
    {"nome": "Lucas", "email": "monte.lucas@gmail.com", "telefone": ""}
]

def enviar_email(destinatario, assunto, mensagem):
    """Envia um e-mail utilizando SMTP SSL."""
    try:
        msg = EmailMessage()
        msg.set_content(mensagem)
        msg['Subject'] = assunto
        msg['From'] = EMAIL_REMETENTE
        msg['To'] = destinatario

        # Configuração para Gmail. Se for Outlook, mude para smtp.office365.com na porta 587 (TLS)
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(EMAIL_REMETENTE, EMAIL_SENHA)
            server.send_message(msg)
        print(f"[E-MAIL] Sucesso ao enviar para {destinatario}")
    except Exception as e:
        print(f"[E-MAIL] Erro ao enviar para {destinatario}: {e}")

def enviar_whatsapp_desktop(numero_destino, mensagem):
    """Abre o aplicativo do WhatsApp no Windows/Mac e aperta Enter para enviar."""
    if not numero_destino:
        return
    try:
        print(f"[WPP] Abrindo WhatsApp Desktop para enviar mensagem para {numero_destino}...")
        mensagem_codificada = urllib.parse.quote(mensagem)
        # Abre o aplicativo do WhatsApp na conversa específica
        webbrowser.open(f"whatsapp://send?phone={numero_destino}&text={mensagem_codificada}")
        
        # Aguarda 10 segundos para o aplicativo abrir e carregar a conversa
        time.sleep(10)
        
        # Simula o pressionamento da tecla Enter
        pyautogui.press('enter')
        print(f"[WPP] Mensagem enviada para {numero_destino}")
        
        # Pequena pausa antes de passar para o próximo (se houver)
        time.sleep(2)
    except Exception as e:
        print(f"[WPP] Erro ao enviar para {numero_destino}: {e}")

def notificar_movimentacao(numero_contrato, novo_status):
    """Função principal que orquestra as notificações após uma movimentação."""
    assunto = f"Atualização Importante: Contrato {numero_contrato}"
    mensagem = f"Olá! O contrato {numero_contrato} sofreu uma movimentação. Novo status: {novo_status}."

    for usuario in usuarios_cadastrados:
        print(f"Notificando {usuario['nome']}...")
        enviar_email(usuario['email'], assunto, mensagem)
        enviar_whatsapp_desktop(usuario.get('telefone'), mensagem)

if __name__ == "__main__":
    print("Enviando mensagem de teste automática...")
    notificar_movimentacao("TESTE-001", "Mensagem de teste automática")