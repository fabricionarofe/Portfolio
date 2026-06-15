const Jimp = require('jimp');

async function criarBanner(nicho, arquivoEntrada, arquivoSaida) {
    console.log(`\n🎨 JARVAS: Iniciando a criação do banner para o nicho "${nicho}"...`);

    // Os textos e preços exatos cruzando a pesquisa SEO e os valores da Hotmart
    const dados = {
        'maquiagem': { 
            titulo: 'CURSO DE MAQUIAGEM ONLINE', 
            preco: 'POR APENAS R$ 37,00' 
        },
        'excel': { 
            titulo: 'PLANILHA CONTROLE FINANCEIRO', 
            preco: 'POR APENAS R$ 47,00' 
        },
        'shopee': { 
            titulo: 'COMO VENDER NA SHOPEE', 
            preco: 'LANCAMENTO: R$ 67,00' 
        },
        'manicure': { 
            titulo: 'CURSO DE CUTILAGEM', 
            preco: 'DE 109 POR: R$ 29,90' 
        }
    };

    const config = dados[nicho];
    if (!config) return console.log('❌ Nicho não encontrado no banco de dados.');

    try {
        // Carrega a imagem limpa que a IA gerou
        const image = await Jimp.read(arquivoEntrada);
        
        // Carrega as fontes do sistema (Preto, ideal para fundos claros no espaço vazio)
        const fontTitulo = await Jimp.loadFont(Jimp.FONT_SANS_64_BLACK);
        const fontPreco = await Jimp.loadFont(Jimp.FONT_SANS_32_BLACK);

        // Carimba o Título no topo da imagem (y: 40)
        image.print(fontTitulo, 0, 40, { text: config.titulo, alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER }, image.bitmap.width);
        
        // Carimba o Preço logo abaixo do título (y: 120)
        image.print(fontPreco, 0, 120, { text: config.preco, alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER }, image.bitmap.width);

        // Salva a imagem final com o nome que o robô do WhatsApp exige (banner.jpg)
        await image.writeAsync(arquivoSaida);
        console.log(`✅ Arte concluída com sucesso! Salva como "${arquivoSaida}". O robô de vendas já pode usá-la.`);

    } catch (error) {
        console.error('❌ Erro ao criar o banner. Verifique se o arquivo de imagem base existe na pasta.', error.message);
    }
}

// Mude 'manicure' para o nicho que desejar. 
// Certifique-se de ter uma imagem chamada "base.jpg" na pasta!
criarBanner('manicure', 'base.jpg', 'banner.jpg');