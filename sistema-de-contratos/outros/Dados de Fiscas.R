# Instalar pacotes caso ainda não os tenha no ambiente
# install.packages("readxl")
# install.packages("DBI")
# install.packages("RPostgres")
# install.packages("tidyr") # Adicionado para a função fill()
# install.packages("dplyr") # Adicionado para o pipe (%>%)

library(readxl)
library(DBI)
library(RPostgres)
library(tidyr) # Pacote para manipulação e limpeza de dados
library(dplyr) # Pacote essencial para manipulação e uso do %>%

# 1. LEITURA DOS DADOS DO ARQUIVO XLS
print("Uma janela foi aberta para você selecionar o arquivo XLS (procure-a na barra de tarefas se não aparecer na frente).")
caminho_arquivo <- file.choose() # Abre uma janela para selecionar o arquivo manualmente

# read_excel suporta tanto .xls quanto .xlsx automaticamente
dados_fiscais_brutos <- read_excel(caminho_arquivo, col_names = TRUE)

# 2. LIMPEZA DOS DADOS: TRATAMENTO DE CÉLULAS MESCLADAS
# Células mescladas no Excel são lidas como um valor na primeira linha e 'NA' (nulo) nas demais.
# A função fill() propaga o último valor válido para preencher os 'NA's abaixo dele.

# Juntamos a limpeza em um único comando para maior segurança.
dados_fiscais_limpos <- dados_fiscais_brutos %>%
  # CORREÇÃO DE DATAS: Converte as colunas de data do formato numérico do Excel para o formato de Data do R.
  # O Excel armazena datas como o número de dias desde 1899-12-30.
  # Assumindo que as colunas 8 (Início Vigência) e 9 (Fim Vigência) são as datas.
  mutate(across(c(8, 9), ~ as.Date(as.numeric(.), origin = "1899-12-30"))) %>%

  # Preenche as colunas 1 a 16 (Processo, Contrato, Empresa, Valor, etc.) para baixo.
  # Isso garante que as linhas dos TAs herdem as informações do contrato pai acima delas.
  fill(1:16, .direction = "down") %>%
  # Remove linhas que ficaram totalmente em branco após a leitura.
  filter(rowSums(is.na(.)) != ncol(.))

# PONTO DE VERIFICAÇÃO: Mostra as 6 primeiras linhas do objeto criado.
print("Verificação do objeto 'dados_fiscais_limpos' criado:")
print(head(dados_fiscais_limpos))

# 3. CONEXÃO COM O BANCO DE DADOS POSTGRESQL (BANCO 'GOV')
# Utilizando a mesma lógica de credenciais do seu PAINEL.R
db_user <- Sys.getenv("DB_USER")
if (db_user == "") db_user <- "postgres"

db_pass <- Sys.getenv("DB_PASS")
if (db_pass == "") db_pass <- "admin123"

conexao <- dbConnect(RPostgres::Postgres(),
                     dbname = "GOV",
                     host = "[HOST_REMOVED]",
                     user = db_user,
                     password = db_pass)

# 4. INSERÇÃO DOS DADOS NA TABELA
# O parâmetro 'overwrite = TRUE' cria a tabela do zero ou a substitui se já existir.
# Se preferir apenas adicionar dados em uma tabela existente, mude para 'append = TRUE' e remova o 'overwrite'.
dbWriteTable(conexao, "FISCAIS", dados_fiscais_limpos, overwrite = TRUE)

# 5. ENCERRAMENTO
dbDisconnect(conexao)

print("Tabela FISCAIS criada e populada com sucesso no banco GOV!")