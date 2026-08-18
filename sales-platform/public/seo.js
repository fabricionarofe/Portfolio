const https = require('https');

function pesquisarTendenciasSEO(palavra) {
    console.log(`\n🔍 JARVAS: Analisando o volume de buscas no Google para "${palavra}"...`);
    
    // Usa a API secreta de Autocompletar do Google para ver o que os usuários estão digitando agora
    const url = `https://suggestqueries.google.com/complete/search?client=firefox&hl=pt-BR&q=${encodeURIComponent(palavra)}`;
    
    https.get(url, (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        
        res.on('end', () => {
            try {
                const resultado = JSON.parse(data);
                const sugestoes = resultado[1]; // O Google retorna as sugestões no índice 1
                
                console.log('📈 Termos Mais Buscados (Use isso no texto dos seus anúncios!):');
                sugestoes.forEach((termo, index) => {
                    console.log(`   ${index + 1}. ${termo}`);
                });
            } catch (e) {
                console.error('Erro ao processar dados de SEO.', e);
            }
        });
    }).on('error', (err) => {
        console.error('Erro na requisição:', err.message);
    });
}

// O senhor pode trocar essas palavras pelo nicho que quiser pesquisar!
pesquisarTendenciasSEO('curso de maquiagem');
setTimeout(() => pesquisarTendenciasSEO('como ganhar dinheiro com'), 2000);
setTimeout(() => pesquisarTendenciasSEO('planilha de excel para'), 4000);