const fs = require('fs');

function analisarMercado() {
    console.log('📊 JARVAS: Analisando o mercado e calculando projeções de lucro...\n');

    try {
        const data = fs.readFileSync('produtos_hotmart.csv', 'utf8');
        const linhas = data.split('\n').filter(l => l.trim() !== '' && !l.startsWith('Produto'));
        
        let precos = [];
        
        linhas.forEach(linha => {
            const colunas = linha.split('","');
            if (colunas.length > 1) {
                let precoStr = colunas[1].replace('R$', '').replace('"', '').trim();
                // Ajusta o formato brasileiro (ex: "3.459,00" para float 3459.00)
                precoStr = precoStr.replace(/\./g, '').replace(',', '.');
                const preco = parseFloat(precoStr);
                if (!isNaN(preco)) {
                    precos.push(preco);
                }
            }
        });

        if (precos.length === 0) return console.log('Nenhum preço encontrado.');

        precos.sort((a, b) => a - b);
        
        const precosLowTicket = precos.filter(p => p <= 200);
        const mediaLowTicket = precosLowTicket.length > 0 
            ? precosLowTicket.reduce((a, b) => a + b, 0) / precosLowTicket.length 
            : 0;

        console.log(`🛒 PANORAMA DE MERCADO (Low Ticket)`);
        console.log(`   ↳ Preço Médio Praticado: R$ ${mediaLowTicket.toFixed(2).replace('.', ',')}\n`);

        console.log('💰 CÁLCULO DE LUCRO RECOMENDADO:');
        
        console.log('\n🟢 ESTRATÉGIA AFILIADO (Comissão de 55%)');
        console.log(`   - Preço de Venda: R$ ${mediaLowTicket.toFixed(2).replace('.', ',')}`);
        console.log(`   - Lucro Bruto (Comissão): R$ ${(mediaLowTicket * 0.55).toFixed(2).replace('.', ',')}`);
        console.log(`   - Custo Máximo por Venda (Ads): R$ ${(mediaLowTicket * 0.20).toFixed(2).replace('.', ',')}`);
        console.log(`   - Lucro Líquido Estimado: R$ ${(mediaLowTicket * 0.35).toFixed(2).replace('.', ',')} por venda.`);

        console.log('\n🟢 ESTRATÉGIA PRODUTOR PLR (Margem Alta)');
        console.log(`   - Preço Sugerido (Venda Impulsiva): R$ 47,00`);
        console.log(`   - Taxas da Plataforma (10%): R$ 4,70`);
        console.log(`   - Lucro Bruto: R$ 42,30`);
        console.log(`   - Margem de Lucro: 90% (Sobra R$ 42,30 para investir em Ads e embolsar o lucro).`);

    } catch (error) {
        console.error('❌ Erro ao ler a base de dados:', error.message);
    }
}

analisarMercado();