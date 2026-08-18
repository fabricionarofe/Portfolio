const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const fs = require('fs'); // Módulo nativo do Node.js para manipular arquivos

// Função para simular o tempo de digitação humana (pausa)
const delay = (ms) => new Promise(res => setTimeout(res, ms));

// Inicializa o robô e salva a sessão localmente na pasta .wwebjs_auth
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: [
            '--no-sandbox', 
            '--disable-setuid-sandbox',
            '--disable-blink-features=AutomationControlled', // Esconde a flag "webdriver" (anti-bot)
            '--disable-infobars'
        ],
        // Disfarça o robô como um navegador normal do Windows para evitar bloqueios do WhatsApp
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'
    }
});

// Evento: Gera o QR Code no terminal
client.on('qr', (qr) => {
    console.log('\n======================================================');
    console.log('📱 ESCANEIE O QR CODE ABAIXO COM O SEU WHATSAPP');
    console.log('======================================================\n');
    qrcode.generate(qr, { small: true });
});

// Evento: Confirmação de que o robô conectou
client.on('ready', () => {
    console.log('✅ Robô de vendas conectado e pronto para vender!');
});

// Evento: Escuta e responde as mensagens recebidas
client.on('message', async (message) => {
    // Ignora mensagens enviadas em grupos ou atualizações de status
    if (message.isGroupMsg || message.isStatus) return;

    // Transforma a mensagem do cliente em letras minúsculas para facilitar a verificação
    const texto = message.body.toLowerCase().trim();
    
    // Pega as informações do chat para simular ações humanas
    const chat = await message.getChat();

    // Etapa 1: Topo do Funil (Saudação)
    if (texto === 'oi' || texto === 'olá' || texto === 'ola' || texto === 'quero saber mais') {
        await chat.sendSeen(); // Marca a mensagem como lida (visualiza)
        await chat.sendStateTyping(); // Fica com o status "digitando..."
        await delay(3500); // Aguarda 3,5 segundos para parecer humano
        
        const resposta = `Olá! Que bom ter você aqui. 🚀\n\nNós temos um material exclusivo: *Curso de Cutilagem para Manicures*.\n\nHoje ele está em promoção de R$ 109,00 por apenas *R$ 29,90*.\nAcesso vitalício, emissão de certificado de 60 horas. Promoção por tempo limitado!\n\nDigite *SIM* para receber o link oficial da Hotmart.`;
        
        try {
            // Tenta enviar a imagem junto com o texto. Coloque um arquivo "banner.jpg" na pasta!
            const media = MessageMedia.fromFilePath('./banner.jpg');
            await client.sendMessage(message.from, media, { caption: resposta });
        } catch (error) {
            // Se não achar a imagem "banner.jpg", envia apenas o texto
            await client.sendMessage(message.from, resposta);
        }
    } 
    // Etapa 2: Fundo do Funil (Fechamento)
    else if (texto === 'sim' || texto === 'quero' || texto === 'eu quero') {
        await chat.sendSeen();
        
        // Salva o número do cliente em um arquivo CSV para você fazer remarketing depois
        fs.appendFileSync('leads.csv', `${message.from},${new Date().toLocaleString('pt-BR')}\n`);

        await chat.sendStateTyping();
        await delay(2500); // Aguarda 2,5 segundos
        
        try {
            // Envia um áudio simulando que foi gravado na hora! (sendAudioAsVoice: true)
            // Coloque um arquivo de áudio chamado "audio_venda.mp3" na pasta do projeto.
            const audio = MessageMedia.fromFilePath('./audio_venda.mp3');
            await client.sendMessage(message.from, audio, { sendAudioAsVoice: true });
            
            await delay(1500); // Pequena pausa humana antes de mandar o texto com o link
        } catch (error) {} // Se o senhor não tiver colocado o áudio na pasta, ele ignora e manda só o texto
        
        const resposta = `Excelente escolha! 🎉\n\nVocê pode realizar o pagamento com PIX ou Cartão através do link seguro oficial abaixo:\n🔗 https://pay.hotmart.com/COLOQUE_SEU_LINK_AQUI\n\nAssim que o pagamento for aprovado, o acesso chegará no seu e-mail automaticamente. Se tiver alguma dúvida, é só mandar aqui!`;
        await client.sendMessage(message.from, resposta);
    }
    // Etapa 3: Quebra de Objeções (Tá caro / Sem dinheiro / Vou pensar)
    else if (texto.includes('caro') || texto.includes('dinheiro') || texto.includes('pensar')) {
        await chat.sendSeen();
        await chat.sendStateTyping();
        await delay(3000);
        
        const respostaObjecao = `Eu entendo perfeitamente! 🤝\n\nMuitas de nossas alunas pensaram a mesma coisa antes de começar. Mas pense nisso como um investimento: com apenas UMA cliente que você atender aplicando essas técnicas, você já recupera o valor do curso inteiro!\n\nAlém disso, você pode parcelar no cartão por um valor menor que um lanche no mês. Vamos aproveitar a promoção antes que acabe? Digite *SIM* para eu liberar seu link promocional.`;
        
        await client.sendMessage(message.from, respostaObjecao);
    }
});

// Inicia o processo
client.initialize().catch(err => {
    console.error('\n❌ Erro crítico ao iniciar o WhatsApp Web:');
    console.error(err.message);
    if (err.message.includes('Execution context was destroyed')) {
        console.log('\n👉 COMO RESOLVER: Este é um erro comum de cache corrompido.');
        console.log('1. Apague a pasta ".wwebjs_auth" no seu projeto.');
        console.log('2. Rode "node index.js" novamente.\n');
    }
});

// Captura o Ctrl+C no terminal para fechar o robô com segurança e evitar arquivos trancados (Erro EBUSY)
process.on('SIGINT', async () => {
    console.log('\n🛑 Encerrando o robô com segurança...');
    await client.destroy();
    process.exit(0);
});