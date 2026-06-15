const puppeteer = require('puppeteer'); // A mesma biblioteca que move o WhatsApp Web
const fs = require('fs'); // Módulo para salvar arquivos

// ----------------------------------------------------------------
// JARVAS - MÓDULOS DE MINERAÇÃO (CADA FUNÇÃO RODA EM UMA ABA)
// ----------------------------------------------------------------

async function minerarHotmart(browser) {
    const page = await browser.newPage();
    try {
        console.log('🔥 [HOTMART] Acessando vitrine...');
        await page.goto('https://hotmart.com/pt-br/marketplace/search', { waitUntil: 'networkidle2' });
        await new Promise(r => setTimeout(r, 5000));

        const produtos = await page.evaluate(() => {
            const cards = document.querySelectorAll('a');
            const resultados = [];
            cards.forEach(card => {
                const textoCard = card.innerText;
                const img = card.querySelector('img');
                if (img && textoCard.includes('R$')) {
                    const linhas = textoCard.split('\n').map(t => t.trim()).filter(t => t !== '');
                    const preco = linhas.find(l => l.includes('R$'));
                    let nome = linhas[0] !== preco ? linhas[0] : (img.alt || 'Produto Hotmart');
                    nome = nome.replace(/"/g, '');
                    if (preco && !resultados.find(r => r.nome === nome) && resultados.length < 20) {
                        resultados.push({ nome, preco });
                    }
                }
            });
            return resultados;
        });

        if (produtos.length > 0) {
            let conteudoCSV = 'Produto,Preco\n';
            produtos.forEach(p => conteudoCSV += `"${p.nome}","${p.preco}"\n`);
            fs.writeFileSync('produtos_hotmart.csv', conteudoCSV, 'utf8');
            console.log(`✅ [HOTMART] ${produtos.length} produtos salvos em 'produtos_hotmart.csv'!`);
        }
    } catch (erro) {
        console.error('❌ [HOTMART] Erro:', erro.message);
    } finally {
        await page.close(); // Fecha apenas a aba da Hotmart
    }
}

async function minerarShopee(browser) {
    const page = await browser.newPage();
    try {
        console.log('🛍️ [SHOPEE] Acessando produtos digitais...');
        // Shopee tem sistemas fortes anti-bot, disfarçamos o robô como um navegador comum
        await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36');
        await page.goto('https://shopee.com.br/search?keyword=curso%20digital', { waitUntil: 'networkidle2' });
        await new Promise(r => setTimeout(r, 6000)); // Aguarda carregar

        const produtos = await page.evaluate(() => {
            const cards = document.querySelectorAll('a[data-sqe="link"]');
            const resultados = [];
            cards.forEach(card => {
                const img = card.querySelector('img');
                const nome = img ? img.alt.replace(/"/g, '') : 'Produto Shopee';
                const spanPreco = Array.from(card.querySelectorAll('span')).find(s => s.innerText.includes('R$'));
                const preco = spanPreco ? spanPreco.innerText.trim() : 'Preço oculto';
                if (nome && preco.includes('R$') && resultados.length < 20) {
                    resultados.push({ nome, preco });
                }
            });
            return resultados;
        });

        if (produtos.length > 0) {
            let conteudoCSV = 'Produto,Preco\n';
            produtos.forEach(p => conteudoCSV += `"${p.nome}","${p.preco}"\n`);
            fs.writeFileSync('produtos_shopee.csv', conteudoCSV, 'utf8');
            console.log(`✅ [SHOPEE] ${produtos.length} produtos salvos em 'produtos_shopee.csv'!`);
        } else {
            console.log('⚠️ [SHOPEE] Nenhum produto capturado (A Shopee pode ter exigido verificação humana).');
        }
    } catch (erro) {
        console.error('❌ [SHOPEE] Erro:', erro.message);
    } finally {
        await page.close(); // Fecha apenas a aba da Shopee
    }
}

// ----------------------------------------------------------------
// ORQUESTRADOR PRINCIPAL (GERENTE DAS ABAS)
// ----------------------------------------------------------------
async function iniciarRoboDePesquisa() {
    console.log('🤖 JARVAS: Inicializando o Sistema de Mineração em Massa...');

    const browser = await puppeteer.launch({ headless: false });
    console.log('🤖 JARVAS: Abrindo múltiplas abas simultaneamente. Aguarde, senhor...\n');

    // Dispara as funções de espionagem (Hotmart para Digitais e Shopee para Dropshipping)
    await Promise.all([
        minerarHotmart(browser),
        minerarShopee(browser)
    ]);

    console.log('\n🤖 JARVAS: Operação de mineração em massa concluída com sucesso!');
    await browser.close(); // Fecha o navegador inteiro
}

iniciarRoboDePesquisa();