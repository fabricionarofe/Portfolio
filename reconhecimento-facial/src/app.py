import os
import cv2
import face_recognition
import numpy as np
from flask import Flask, render_template, Response, request, jsonify
import time

app = Flask(__name__, template_folder='.')

PASTA_BANCO_DE_ROSTOS = "banco_de_rostos"
FATOR_REDIMENSIONAMENTO = 0.25

if not os.path.exists(PASTA_BANCO_DE_ROSTOS):
    os.makedirs(PASTA_BANCO_DE_ROSTOS)

codificacoes_rostos_conhecidos = []
nomes_rostos_conhecidos = []
frame_atual = None  # Variável global para armazenar a foto no momento do cadastro

def carregar_rostos_conhecidos():
    global codificacoes_rostos_conhecidos, nomes_rostos_conhecidos
    codificacoes_rostos_conhecidos.clear()
    nomes_rostos_conhecidos.clear()
    
    arquivos_na_pasta = os.listdir(PASTA_BANCO_DE_ROSTOS)
    for nome_arquivo in arquivos_na_pasta:
        caminho_imagem = os.path.join(PASTA_BANCO_DE_ROSTOS, nome_arquivo)
        try:
            imagem = face_recognition.load_image_file(caminho_imagem)
            encodings = face_recognition.face_encodings(imagem)
            if encodings:
                codificacoes_rostos_conhecidos.append(encodings[0])
                nomes_rostos_conhecidos.append(os.path.splitext(nome_arquivo)[0].replace("_", " ").title())
        except Exception:
            pass

# Carrega os rostos logo ao iniciar
carregar_rostos_conhecidos()

def gen_frames():
    global frame_atual
    camera = cv2.VideoCapture(0)
    tempo_anterior = 0
    processar_este_quadro = True
    localizacoes_rostos = []
    nomes_rostos_quadro = []

    while True:
        success, frame = camera.read()
        if not success:
            break

        # Salva o frame atual globalmente para a função de cadastro não precisar abrir a câmera de novo
        frame_atual = frame.copy()

        if processar_este_quadro:
            quadro_pequeno = cv2.resize(frame, (0, 0), fx=FATOR_REDIMENSIONAMENTO, fy=FATOR_REDIMENSIONAMENTO)
            quadro_rgb_pequeno = cv2.cvtColor(quadro_pequeno, cv2.COLOR_BGR2RGB)
            localizacoes_rostos = face_recognition.face_locations(quadro_rgb_pequeno)
            codificacoes_rostos_frame = face_recognition.face_encodings(quadro_rgb_pequeno, localizacoes_rostos)

            nomes_rostos_quadro = []
            for codificacao_rosto in codificacoes_rostos_frame:
                nome = "Desconhecido"
                if codificacoes_rostos_conhecidos:
                    correspondencias = face_recognition.compare_faces(codificacoes_rostos_conhecidos, codificacao_rosto)
                    distancias_rostos = face_recognition.face_distance(codificacoes_rostos_conhecidos, codificacao_rosto)
                    if len(distancias_rostos) > 0:
                        melhor_indice = np.argmin(distancias_rostos)
                        if correspondencias[melhor_indice]:
                            nome = nomes_rostos_conhecidos[melhor_indice]
                nomes_rostos_quadro.append(nome)

        processar_este_quadro = not processar_este_quadro

        for (top, right, bottom, left), nome in zip(localizacoes_rostos, nomes_rostos_quadro):
            top = int(top / FATOR_REDIMENSIONAMENTO)
            right = int(right / FATOR_REDIMENSIONAMENTO)
            bottom = int(bottom / FATOR_REDIMENSIONAMENTO)
            left = int(left / FATOR_REDIMENSIONAMENTO)

            cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)
            cv2.rectangle(frame, (left, bottom - 35), (right, bottom), (0, 255, 0), cv2.FILLED)
            cv2.putText(frame, nome, (left + 6, bottom - 6), cv2.FONT_HERSHEY_DUPLEX, 0.8, (255, 255, 255), 1)

        ret, buffer = cv2.imencode('.jpg', frame)
        frame_bytes = buffer.tobytes()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/video_feed')
def video_feed():
    return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/cadastrar', methods=['POST'])
def cadastrar():
    global frame_atual
    nome = request.form.get('nome')
    
    if not nome: return jsonify({'status': 'erro', 'mensagem': 'Nome não fornecido.'}), 400
    if frame_atual is None: return jsonify({'status': 'erro', 'mensagem': 'Aguarde a câmera iniciar.'}), 400

    nome_arquivo = nome.lower().replace(" ", "_") + ".jpg"
    caminho_arquivo = os.path.join(PASTA_BANCO_DE_ROSTOS, nome_arquivo)
    cv2.imwrite(caminho_arquivo, frame_atual)
    carregar_rostos_conhecidos() # Recarrega a memória para já reconhecer a pessoa nova
    
    return jsonify({'status': 'sucesso', 'mensagem': f'Rosto de {nome} cadastrado com sucesso!'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)