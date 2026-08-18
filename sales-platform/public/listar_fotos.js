const fs = require('fs');
const path = require('path');

// Caminho para a pasta FOTOS
const fotosDir = path.join(__dirname, 'FOTOS');

try {
    // Inspeciona a pasta
    const arquivos = fs.readdirSync(fotosDir);
    
    // Filtra para pegar apenas arquivos de imagem
    const imagens = arquivos.filter(arq => /\.(jpg|jpeg|png|gif|webp)$/i.test(arq));
    
    // Formata os nomes para o padrão do JavaScript
    const arrayFormatado = imagens.map(img => `            'FOTOS/${img}'`).join(',\n');
    
    console.log('\n🤖 JARVAS: Aqui estão os nomes das suas fotos. Copie o bloco abaixo e substitua no seu curso_manicure.html:\n');
    console.log(`        const imagensFotos = [\n${arrayFormatado}\n        ];\n`);
} catch (error) {
    console.error('\n❌ Erro: Não consegui ler a pasta FOTOS. Verifique se ela realmente existe na área de trabalho.\n', error.message);
}