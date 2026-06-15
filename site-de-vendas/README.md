# Site De Vendas

!Status
!License

## Sobre o Projeto

O **Site De Vendas** integra meu portfolio pessoal de Engenharia de Software. Trata-se de uma solucao focada em transacoes comerciais, exibicao de servicos e construcao de experiencia digital para o usuario final.

Todo o codigo-fonte passou por um rigoroso processo de reestruturacao e auditoria. O objetivo foi aplicar padroes modernos de arquitetura, garantindo a manutenibilidade, seguranca contra vazamentos de dados (ofuscamento de senhas) e a mitigacao de debitos tecnicos atraves do Principio DRY (Don't Repeat Yourself).

## Arquitetura do Projeto

A estrutura de pastas foi organizada para manter o codigo limpo e separar as responsabilidades:

- **`assets/`**: Recursos visuais como imagens, fontes e folhas de estilo globais.
- **`config/`**: Arquivos de configuracao e parametros de ambiente.
- **`database/`**: Scripts, esquemas e configuracoes relacionadas ao banco de dados.
- **`docs/`**: Documentacao adicional, diagramas e manuais do sistema.
- **`outros/`**: Modulos e componentes especificos desta camada do sistema.
- **`public/`**: Arquivos estaticos e acessiveis publicamente (HTML, icones, etc).
## Destaques Tecnicos

- **Isolamento de Responsabilidades:** Componentes separados de forma logica para facilitar a escalabilidade.
- **Seguranca Ativa:** Remocao automatizada de chaves e dados sensiveis do versionamento.
- **Reprodutibilidade:** Ambientes padronizados com gestao de dependencias explicitas no projeto.

## Como Executar Localmente

1. Realize o clone deste repositorio em sua maquina.
2. Navegue ate a raiz do projeto atraves do terminal (`cd "site-de-vendas"`).
3. Instale as dependencias listadas no arquivo de requisitos.
4. Execute o modulo principal da aplicacao.

---
*Documentacao gerada e padronizada automaticamente. Desenvolvido para demonstracao de maturidade em praticas de engenharia de software.*
