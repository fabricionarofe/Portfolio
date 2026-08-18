library(DBI)
library(RPostgres)
library(httr)
library(jsonlite)
library(dplyr)

cat("==================================================================\n")
cat("🛒 SCRIPT 2 - ITENS1 (SINCRONIZADOR DE HIATOS)\n")
cat("==================================================================\n\n")

# 1. Conexão e Identificação do Hiato
conexao_pg <- tryCatch({
  dbConnect(RPostgres::Postgres(), dbname = "GOV", host = "[HOST_REMOVED]", port = 5432, user = "postgres", password = "[YOUR_KEY_HERE]")
}, error = function(e) { stop("❌ Erro ao conectar no banco!") })

# A MÁGICA AQUI: O script cruza as tabelas e pega APENAS o que falta baixar
query_delta <- '
  SELECT L."numeroControlePNCP" 
  FROM public."LICITACOES1" L
  LEFT JOIN public."ITENS1" I ON L."numeroControlePNCP" = I."FK_numeroControlePNCP"
  WHERE I."FK_numeroControlePNCP" IS NULL 
    AND L."numeroControlePNCP" IS NOT NULL;
'

df_alvos <- dbGetQuery(conexao_pg, query_delta)
lista_ids <- unique(df_alvos$numeroControlePNCP) # Garante que não haja duplicidade na busca

if(length(lista_ids) == 0) {
  dbDisconnect(conexao_pg)
  stop("✅ Todos os itens da LICITACOES1 já estão na tabela ITENS1. Banco 100% Sincronizado!")
}

cat(sprintf("🎯 Hiato identificado: %d processos estão sem itens no banco. Iniciando extração...\n\n", length(lista_ids)))

df_itens_novos <- data.frame()

# 2. Loop de Extração com Freio Anti-Loop
for (i in 1:length(lista_ids)) {
  id_compra <- lista_ids[i]
  pagina_atual <- 1
  tem_pag <- TRUE
  
  while(tem_pag) {
    cat(sprintf("   ⏳ [%03d/%03d] Lendo: %s | Pág: %d... ", i, length(lista_ids), id_compra, pagina_atual))
    flush.console()
    
    url_base <- "https://dadosabertos.compras.gov.br/modulo-contratacoes/2.1_consultarItensContratacoes_PNCP_14133_Id"
    
    sucesso <- FALSE
    tentativas <- 0
    dados <- NULL
    codigo <- 0
    
    # Blindagem de Conexão
    while(!sucesso && tentativas < 3) {
      tryCatch({
        resp <- GET(
            url_base, 
            query = list(tipo = "numeroControlePNCPCompra", codigo = id_compra, pagina = pagina_atual, tamanhoPagina = 500),
            add_headers("Accept" = "application/json"), 
            timeout(20)
        )
        codigo <- status_code(resp)
        
        if (codigo == 200) {
          dados <- fromJSON(content(resp, "text", encoding = "UTF-8"), flatten = TRUE)
          sucesso <- TRUE
        } else if (codigo == 429) {
          cat("[FIREWALL 15s] ")
          Sys.sleep(15); tentativas <- tentativas + 1
        } else if (codigo %in% c(404, 204, 422)) {
          sucesso <- TRUE # Significa que o processo legitimamente não tem itens cadastrados
        } else {
          Sys.sleep(2); tentativas <- tentativas + 1
        }
      }, error = function(e) { Sys.sleep(2); tentativas <- tentativas + 1 })
    }
    
    # Tratamento da Resposta
    if (sucesso && !is.null(dados) && !is.null(dados$resultado) && length(dados$resultado) > 0) {
      df_temp <- as.data.frame(dados$resultado)
      df_temp$FK_numeroControlePNCP <- id_compra 
      df_itens_novos <- bind_rows(df_itens_novos, df_temp)
      
      cat(sprintf("✅ %d itens!\n", nrow(df_temp)))
      
      # Matemática do Pote Cheio (Evita o Bug do Serpro)
      if (nrow(df_temp) == 500 && pagina_atual < 30) { 
        pagina_atual <- pagina_atual + 1 
      } else { tem_pag <- FALSE }
      
    } else {
      cat("⚠️ Vazio/Sem itens.\n")
      tem_pag <- FALSE
    }
    Sys.sleep(0.8) # Respiro amigável para a API
  }
}

# 3. Salvamento Incremental (APPEND)
cat("\n==================================================================\n")
if(nrow(df_itens_novos) > 0) {
  df_pg <- df_itens_novos %>% mutate(across(where(is.list), ~ sapply(., function(x) as.character(toJSON(x, auto_unbox = TRUE)))))
  
  # LÓGICA DE SEGURANÇA: append = TRUE adiciona ao final sem apagar os que já existem
  dbWriteTable(conexao_pg, "ITENS1", df_pg, append = TRUE, row.names = FALSE)
  
  cat(sprintf("🏆 SUCESSO! %d novos itens adicionados à tabela ITENS1 para fechar o hiato.\n", nrow(df_pg)))
} else {
  cat("🛑 A extração rodou, mas nenhum desses processos possuía itens detalhados no governo.\n")
}
dbDisconnect(conexao_pg)