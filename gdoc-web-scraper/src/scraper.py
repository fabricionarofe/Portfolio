from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import getpass
import time
import traceback

def consultar_processo_gdoc(usuario, senha, numero_processo):
    print("Iniciando o navegador Google Chrome em modo invisível (Headless)...")
    # Configura e abre o navegador automaticamente
    servico = Service(ChromeDriverManager().install())
    options = webdriver.ChromeOptions()
    options.add_argument("--headless=new") # Roda o Chrome de forma invisível
    options.add_argument("--window-size=1920,1080") # Garante que o site não esconda botões (modo mobile)
    # Argumentos de estabilidade para evitar que o site bloqueie o robô invisível
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
    navegador = webdriver.Chrome(service=servico, options=options)

    try:
        # 1. Acessar a página de Login
        print("1. Acessando página de login...")
        navegador.get("https://gdoc.belem.pa.gov.br/gdocprocessos/login/")

        # 2. Preencher usuário e senha e clicar em Entrar (simulando digitação humana)
        print("2. Preenchendo dados de login e clicando em Entrar...")
        campo_matricula = WebDriverWait(navegador, 10).until(EC.presence_of_element_located((By.ID, "matricula")))
        campo_matricula.clear()
        campo_matricula.send_keys(usuario)
        
        campo_senha = navegador.find_element(By.ID, "senha")
        campo_senha.clear()
        campo_senha.send_keys(senha)
        
        time.sleep(1) # Pausa rápida para o sistema Java registrar a digitação
        # Usando clique via JavaScript para evitar falhas no modo invisível
        botao_login = navegador.find_element(By.ID, "logarUsuario")
        navegador.execute_script("arguments[0].click();", botao_login)
        
        # 3. Aguardar o sistema carregar a Home e redirecionar para a Pesquisa
        print("3. Indo para a tela de pesquisa...")
        time.sleep(5) # Pausa maior para garantir que a sessão foi registrada no servidor
        navegador.get("https://gdoc.belem.pa.gov.br/gdocprocessos/processos/pesquisa")

        print(f"4. Preparando para pesquisar o processo {numero_processo}...")
        
        # --- PRÓXIMO PASSO: COMO PESQUISAR ---
        campo_pesquisa = WebDriverWait(navegador, 10).until(EC.presence_of_element_located((By.ID, "tabview:tfProcesso")))
        campo_pesquisa.clear()
        campo_pesquisa.send_keys(numero_processo)
        
        # Usando XPATH para encontrar o botão pelo texto da tag span que você enviou
        botao_buscar = navegador.find_element(By.XPATH, "//span[text()='Pesquisar']")
        navegador.execute_script("arguments[0].click();", botao_buscar)

        print("5. Aguardando a tabela de resultados carregar...")
        
        # Espera até 30 segundos para o botão "Detalhar" aparecer (tolerância para internet lenta)
        botao_detalhar = WebDriverWait(navegador, 30).until(
            EC.presence_of_element_located((By.XPATH, "//a[text()='Detalhar']"))
        )
        print("6. Clicando no botão Detalhar...")
        navegador.execute_script("arguments[0].click();", botao_detalhar)

        print("7. Pop-up aberto! Trocando o foco do robô para dentro do iframe...")
        # Aguarda o iframe existir na tela e muda o foco do robô para dentro dele automaticamente
        WebDriverWait(navegador, 20).until(
            EC.frame_to_be_available_and_switch_to_it((By.TAG_NAME, "iframe"))
        )
        
        print("8. Abrindo a aba de Encaminhamentos...")
        aba_encaminhamentos = WebDriverWait(navegador, 20).until(
            EC.presence_of_element_located((By.XPATH, "//div[contains(@class, 'ui-accordion-header') and contains(., 'Encaminhamentos')]"))
        )
        # Rola a tela até a aba e clica
        navegador.execute_script("arguments[0].scrollIntoView({block: 'center'});", aba_encaminhamentos)
        time.sleep(1)
        navegador.execute_script("arguments[0].click();", aba_encaminhamentos)

        print("9. Rolando a página para carregar o histórico...")
        time.sleep(2) # Aguarda a animação da aba expandir o conteúdo
        # Simula a tecla Page Down dentro do iframe para descer a tela
        navegador.find_element(By.TAG_NAME, 'body').send_keys(Keys.PAGE_DOWN)
        time.sleep(1)

        print("10. Extraindo o Setor Atual e a Data...")
        # O XPath agora tem [text()!='Setor'] para pular o cabeçalho da tabela e pegar o dado real
        setor_elemento = WebDriverWait(navegador, 10).until(
            EC.presence_of_element_located((By.XPATH, "(//span[@title='Setor do trâmite' and text()!='Setor'])[1]"))
        )
        data_elemento = WebDriverWait(navegador, 10).until(
            EC.presence_of_element_located((By.XPATH, "(//span[@title='Data do encaminhamento'])[1]"))
        )

        # Usar innerText garante que o robô pegará o texto mesmo que a rolagem não tenha sido 100% perfeita
        texto_setor = setor_elemento.get_attribute("innerText").strip()
        texto_data = data_elemento.get_attribute("innerText").strip()

        print("\n=======================================================")
        print(f">>> SUCESSO! O Setor Atual é: {texto_setor}")
        print(f">>> Data do Encaminhamento  : {texto_data}")
        print("=======================================================\n")

    except Exception as e:
        print("\n=======================================================")
        print("❌ OCORREU UM ERRO DURANTE A EXECUÇÃO!")
        print("Abaixo estão os detalhes exatos de onde o robô travou:")
        traceback.print_exc()
        print("=======================================================\n")
    finally:
        # Fecha o navegador ao finalizar
        navegador.quit()

MEU_USUARIO = "0575950-048"

print("Por questões de segurança, a senha não fica salva no script.")
MINHA_SENHA = getpass.getpass("Digite sua senha do sistema (ela fica invisível ao digitar): ").strip()

NUMERO_DO_PROCESSO = input("Digite o número do processo que deseja pesquisar (ex: 514): ").strip()

consultar_processo_gdoc(MEU_USUARIO, MINHA_SENHA, NUMERO_DO_PROCESSO)
