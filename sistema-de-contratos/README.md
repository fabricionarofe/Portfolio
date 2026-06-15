# Sistema De Contratos

!Status
!License

## Sobre o Projeto

O **Sistema De Contratos** integra meu portfolio pessoal de Engenharia de Software. Este sistema tem foco corporativo e administrativo, buscando trazer controle, transparencia e rastreabilidade para os processos internos.

Todo o codigo-fonte passou por um rigoroso processo de reestruturacao e auditoria. O objetivo foi aplicar padroes modernos de arquitetura, garantindo a manutenibilidade, seguranca contra vazamentos de dados (ofuscamento de senhas) e a mitigacao de debitos tecnicos atraves do Principio DRY (Don't Repeat Yourself).

## Arquitetura do Projeto

A estrutura de pastas foi organizada para manter o codigo limpo e separar as responsabilidades:

- **`assets/`**: Recursos visuais como imagens, fontes e folhas de estilo globais.
- **`database/`**: Scripts, esquemas e configuracoes relacionadas ao banco de dados.
- **`outros/`**: Modulos e componentes especificos desta camada do sistema.
## Destaques Tecnicos

- **Isolamento de Responsabilidades:** Componentes separados de forma logica para facilitar a escalabilidade.
- **Seguranca Ativa:** Remocao automatizada de chaves e dados sensiveis do versionamento.
- **Reprodutibilidade:** Ambientes padronizados com gestao de dependencias explicitas no projeto.

## Como Executar Localmente

1. Realize o clone deste repositorio em sua maquina.
2. Navegue ate a raiz do projeto atraves do terminal (`cd "sistema-de-contratos"`).
3. Instale as dependencias listadas no arquivo de requisitos.
4. Execute o modulo principal da aplicacao.

---
*Documentacao gerada e padronizada automaticamente. Desenvolvido para demonstracao de maturidade em praticas de engenharia de software.*
