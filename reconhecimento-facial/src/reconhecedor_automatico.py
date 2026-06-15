import os
import sys

try:
    import cv2
except ImportError:
    print("ERRO: módulo 'cv2' não encontrado. Instale-o com 'pip install opencv-python'.")
    sys.exit(1)

try:
    import face_recognition
except ImportError:
    print("ERRO: módulo 'face_recognition' não encontrado. Instale-o com 'pip install face-recognition'.")
    sys.exit(1)

import numpy as np
import time

# --- CONFIGURAÇÃO ---
# Nome da pasta que armazenará as imagens dos rostos conhecidos
PASTA_BANCO_DE_ROSTOS = "banco_de_rostos"

# Fator de redimensionamento do vídeo para melhor performance. 1.0 é o tamanho original.
# Valores menores (ex: 0.25) são mais rápidos, mas menos precisos para rostos distantes.
FATOR_REDIMENSIONAMENTO = 0.25

# --- FUNÇÕES AUXILIARES ---

def preparar_ambiente():
    """Verifica se a pasta do banco de rostos existe, senão, a cria e encerra."""
    if not os.path.exists(PASTA_BANCO_DE_ROSTOS):
        print(f"Pasta '{PASTA_BANCO_DE_ROSTOS}' não encontrada.")
        print("Criando a pasta para você...")
        os.makedirs(PASTA_BANCO_DE_ROSTOS)
        print("\n--- INSTRUÇÕES ---")
        print(f"1. Adicione fotos de pessoas que você quer reconhecer na pasta '{PASTA_BANCO_DE_ROSTOS}'.")
        print("2. O nome do arquivo da foto deve ser o nome da pessoa (ex: 'ana_silva.jpg', 'joao_pereira.png').")
        print("3. Use apenas uma foto por pessoa, com o rosto bem visível.")
        print("4. Depois de adicionar as fotos, execute este script novamente.")
        sys.exit() # Encerra o script para o usuário adicionar as fotos

def cadastrar_novo_rosto():
    """Captura uma foto da webcam, pede um nome e salva no banco de rostos."""
    video_capture = cv2.VideoCapture(0)
    if not video_capture.isOpened():
        print("\nERRO: Não foi possível acessar a câmera.")
        return

    print("\n--- Cadastro de Novo Rosto ---")
    print("Posicione o rosto na câmera e pressione 'c' para capturar.")
    print("Pressione 'q' para voltar ao menu.")

    frame_capturado = None
    while True:
        ret, frame = video_capture.read()
        if not ret:
            print("ERRO: Falha ao capturar imagem da câmera.")
            break

        cv2.putText(frame, "Pressione 'c' para capturar ou 'q' para sair", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2, cv2.LINE_AA)
        cv2.imshow('Cadastrar Rosto', frame)

        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            frame_capturado = None
            break
        elif key == ord('c'):
            frame_capturado = frame
            break

    video_capture.release()
    cv2.destroyAllWindows()

    if frame_capturado is None:
        print("Cadastro cancelado.")
        return

    # Verifica se um rosto foi detectado na foto
    codificacoes = face_recognition.face_encodings(frame_capturado)
    if not codificacoes:
        print("\nAVISO: Nenhum rosto foi detectado na foto. Tente novamente com melhor iluminação e enquadramento.")
        return

    nome = ""
    while not nome:
        nome = input("Digite o nome da pessoa (ex: Ana Silva) e pressione Enter: ").strip()
        if not nome:
            print("Nome não pode ser vazio.")

    nome_arquivo = nome.lower().replace(" ", "_") + ".jpg"
    caminho_arquivo = os.path.join(PASTA_BANCO_DE_ROSTOS, nome_arquivo)

    try:
        cv2.imwrite(caminho_arquivo, frame_capturado)
        print(f"\nSUCESSO: Foto de '{nome}' salva em '{caminho_arquivo}'!")
    except Exception as e:
        print(f"\nERRO: Falha ao salvar a foto: {e}")

def carregar_rostos_conhecidos():
    """Carrega imagens da pasta, codifica os rostos e retorna os dados."""
    codificacoes_conhecidas = []
    nomes_conhecidos = []

    print("Carregando rostos do banco de dados...")
    arquivos_na_pasta = os.listdir(PASTA_BANCO_DE_ROSTOS)

    if not arquivos_na_pasta:
        print(f"\nAVISO: A pasta '{PASTA_BANCO_DE_ROSTOS}' está vazia!")
        print("Use a opção 'Cadastrar novo rosto' para adicionar pessoas.")
        return codificacoes_conhecidas, nomes_conhecidos

    for nome_arquivo in arquivos_na_pasta:
        caminho_imagem = os.path.join(PASTA_BANCO_DE_ROSTOS, nome_arquivo)
        try:
            imagem = face_recognition.load_image_file(caminho_imagem)
            # Assume que há apenas um rosto por imagem
            codificacao = face_recognition.face_encodings(imagem)[0]
            
            nome = os.path.splitext(nome_arquivo)[0].replace("_", " ").title()
            
            codificacoes_conhecidas.append(codificacao)
            nomes_conhecidos.append(nome)
            print(f"-> Rosto de '{nome}' carregado com sucesso.")
        except IndexError:
            print(f"AVISO: Nenhum rosto encontrado em '{nome_arquivo}'. Imagem ignorada.")
        except Exception as e:
            print(f"Erro ao processar '{nome_arquivo}': {e}")
            
    return codificacoes_conhecidas, nomes_conhecidos

def iniciar_reconhecimento():
    """Inicia o processo de reconhecimento facial pela webcam."""
    # Carrega os rostos que já estão na pasta
    codificacoes_rostos_conhecidos, nomes_rostos_conhecidos = carregar_rostos_conhecidos()

    if not codificacoes_rostos_conhecidos:
        print("Nenhum rosto conhecido no banco de dados para iniciar o reconhecimento.")
        return

    # Inicializa a webcam
    video_capture = cv2.VideoCapture(0)
    if not video_capture.isOpened():
        print("\nERRO: Não foi possível acessar a câmera. Verifique se ela está conectada e não está em uso por outro programa.")
        return

    print("\nIniciando reconhecimento... Pressione 'q' na janela da câmera para sair.")

    processar_este_quadro = True
    localizacoes_rostos = []
    nomes_rostos_quadro = []
    tempo_anterior = 0

    while True:
        ret, frame = video_capture.read()
        if not ret:
            print("ERRO: Falha ao ler o frame da câmera.")
            break

        if processar_este_quadro:
            # Redimensiona o quadro para processamento mais rápido
            quadro_pequeno = cv2.resize(frame, (0, 0), fx=FATOR_REDIMENSIONAMENTO, fy=FATOR_REDIMENSIONAMENTO)
            quadro_rgb_pequeno = cv2.cvtColor(quadro_pequeno, cv2.COLOR_BGR2RGB)

            # Encontra todos os rostos no quadro atual
            localizacoes_rostos = face_recognition.face_locations(quadro_rgb_pequeno)
            codificacoes_rostos_frame = face_recognition.face_encodings(quadro_rgb_pequeno, localizacoes_rostos)

            nomes_rostos_quadro = []
            # Itera sobre cada rosto encontrado
            for codificacao_rosto in codificacoes_rostos_frame:
                # Compara o rosto atual com todos os rostos conhecidos
                correspondencias = face_recognition.compare_faces(codificacoes_rostos_conhecidos, codificacao_rosto)
                nome = "Desconhecido"

                # Encontra a melhor correspondência baseada na menor distância
                distancias_rostos = face_recognition.face_distance(codificacoes_rostos_conhecidos, codificacao_rosto)
                if len(distancias_rostos) > 0:
                    melhor_indice = np.argmin(distancias_rostos)
                    if correspondencias[melhor_indice]:
                        nome = nomes_rostos_conhecidos[melhor_indice]
                
                nomes_rostos_quadro.append(nome)

        processar_este_quadro = not processar_este_quadro

        for (top, right, bottom, left), nome in zip(localizacoes_rostos, nomes_rostos_quadro):
            # Re-escala as coordenadas do rosto para o tamanho original do frame
            top = int(top / FATOR_REDIMENSIONAMENTO)
            right = int(right / FATOR_REDIMENSIONAMENTO)
            bottom = int(bottom / FATOR_REDIMENSIONAMENTO)
            left = int(left / FATOR_REDIMENSIONAMENTO)

            # Desenha o retângulo e o nome no frame
            cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)
            cv2.rectangle(frame, (left, bottom - 35), (right, bottom), (0, 255, 0), cv2.FILLED)
            cv2.putText(frame, nome, (left + 6, bottom - 6), cv2.FONT_HERSHEY_DUPLEX, 0.8, (255, 255, 255), 1)

        # Calcula e exibe o FPS (Frames Por Segundo)
        tempo_atual = time.time()
        fps = 1 / (tempo_atual - tempo_anterior) if (tempo_atual - tempo_anterior) > 0 else 0
        tempo_anterior = tempo_atual
        cv2.putText(frame, f"FPS: {int(fps)}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)

        # Exibe o resultado
        cv2.imshow('Reconhecimento Facial', frame)

        # Condição de parada (pressionar 'q')
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Libera recursos
    print("Encerrando reconhecimento...")
    video_capture.release()
    cv2.destroyAllWindows()

# --- LÓGICA PRINCIPAL ---
def menu_principal():
    """Exibe o menu principal e gerencia o fluxo do programa."""
    preparar_ambiente()

    while True:
        print("\n" + "="*30)
        print("   MENU PRINCIPAL")
        print("="*30)
        print("1. Iniciar reconhecimento facial")
        print("2. Cadastrar novo rosto")
        print("3. Sair")
        print("="*30)
        
        escolha = input("Escolha uma opção: ").strip()

        if escolha == '1':
            iniciar_reconhecimento()
        elif escolha == '2':
            cadastrar_novo_rosto()
        elif escolha == '3':
            print("Encerrando aplicação...")
            break
        else:
            print("Opção inválida. Por favor, escolha 1, 2 ou 3.")

if __name__ == "__main__":
    menu_principal()
