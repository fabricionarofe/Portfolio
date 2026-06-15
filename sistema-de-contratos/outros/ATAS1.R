library(DBI)
library(RPostgres)
library(httr)
library(jsonlite)
library(dplyr)
library(stringr)
library(rlang)

cat("==================================================================\n")
cat("📚 SCRIPT 4 - ATAS1 (FILTRO CIRÚRGICO CORRIGIDO)\n")
cat("==================================================================\n\n")

# 1. Conexão e Captura da Base Original
conexao_pg <- tryCatch({
  dbConnect(RPostgres::Postgres(), dbname = "GOV", host = "[HOST_REMOVED]", port = 5432, user = "postgres", password = "[YOUR_KEY_HERE]")
}, error = function(e) { stop("❌ Erro ao conectar no banco!") })

df_licitacoes <- dbGetQuery(conexao_pg, 'SELECT "numeroControlePNCP" FROM public."LICITACOES1" WHERE "numeroControlePNCP" IS NOT NULL')

# Fatiamento Mestre
df_licitacoes <- df_licitacoes %>%
  mutate(
    cnpjOrgao = sapply(strsplit(numeroControlePNCP, "[-/]"), `[`, 1),
    seqCompra = as.numeric(sapply(strsplit(numeroControlePNCP, "[-/]"), `[`, 3)),
    anoCompra = sapply(strsplit(numeroControlePNCP, "[-/]"), `[`, 4)
  )

cnpjs_alvo <- unique(df_licitacoes$cnpjOrgao)
lista_ids_mestres <- df_licitacoes$numeroControlePNCP

# CORREÇÃO 1: Varre TODOS os anos, não apenas os anos das licitações
anos_busca <- 2021:as.numeric(format(Sys.Date(), "%Y"))

if(length(cnpjs_alvo) == 0) { stop("Sua tabela LICITACOES1 está vazia.") }

cat(sprintf("🎯 Iniciando busca em %d CNPJs ao longo de %d anos...\n\n", length(cnpjs_alvo), length(anos_busca)))

df_atas_completo <- data.frame()

# FUNÇÃO ANTI-CRASH AVANÇADA (Ignora maiúsculas e minúsculas)
funil_seguro <- function(df) {
  col_idx <- grep("numerocontrolepncp$|numerocontrolepncpata$|id$", names(df), ignore.case = TRUE)
  if(length(col_idx) > 0) {
    col_name <- names(df)[col_idx[1]]
    return(distinct(df, !!sym(col_name), .keep_all = TRUE))
  }
  return(distinct(df))
}

# 2. Loop de Extração
for (i in 1:length(cnpjs_alvo)) {
  cnpj_atual <- cnpjs_alvo[i]
  cat(sprintf("\n🟡 [%02d/%02d] Lendo histórico do CNPJ: %s\n", i, length(cnpjs_alvo), cnpj_atual))
  
  for (ano in anos_busca) {
    p_ini <- paste0(ano, "0101"); p_fim <- paste0(ano, "1231")
    pagina_atual <- 1; tem_pag <- TRUE
    
    while(tem_pag) {
      url <- paste0("https://pncp.gov.br/api/consulta/v1/atas?dataInicial=", p_ini, "&dataFinal=", p_fim, "&cnpjOrgao=", cnpj_atual, "&pagina=", pagina_atual, "&tamanhoPagina=100")
      
      cat(sprintf("   ⏳ Ano: %s | Pág: %d | Lendo... ", ano, pagina_atual))
      flush.console()
      
      sucesso <- FALSE; tentativas <- 0; dados <- NULL; codigo <- 0
      
      while(!sucesso && tentativas < 3) {
        tryCatch({
          resp <- GET(url, add_headers("Accept" = "application/json"), timeout(20))
          codigo <- status_code(resp)
          if (codigo == 200) { dados <- fromJSON(content(resp, "text", encoding = "UTF-8"), flatten = TRUE); sucesso <- TRUE; cat("🟢 OK! \n")
          } else if (codigo == 429) { cat("🚧 Bloqueio(15s)... "); Sys.sleep(15); tentativas <- tentativas + 1
          } else if (codigo %in% c(404, 204, 422)) { sucesso <- TRUE; cat("⚪ Vazio. \n")
          } else { Sys.sleep(2); tentativas <- tentativas + 1 }
        }, error = function(e) { Sys.sleep(2); tentativas <- tentativas + 1 })
      }
      
      if (sucesso && !is.null(dados) && !is.null(dados$data) && length(dados$data) > 0) {
        df_temp <- funil_seguro(as.data.frame(dados$data))
        df_atas_completo <- bind_rows(df_atas_completo, df_temp)
        if (!is.null(dados$paginasRestantes) && dados$paginasRestantes > 0) { pagina_atual <- pagina_atual + 1 } else { tem_pag <- FALSE }
      } else { tem_pag <- FALSE }
      Sys.sleep(0.5)
    }
  }
}

# 3. O Filtro de Ouro Corrigido
cat("\n==================================================================\n")
cat("🧠 INICIANDO O FILTRO EXCLUSIVO...\n")

if(nrow(df_atas_completo) > 0) {
  names(df_atas_completo) <- gsub("\\.", "", names(df_atas_completo))
  df_atas_completo <- funil_seguro(df_atas_completo) 
  
  df_atas_completo$Chave_Ligacao_PowerBI <- NA_character_
  
  # CORREÇÃO 2: Mapeamento de colunas ignorando letras maiúsculas/minúsculas
  colunas_low <- tolower(names(df_atas_completo))
  idx_cnpj <- match("cnpjorgao", colunas_low)
  if(is.na(idx_cnpj)) idx_cnpj <- match("codigounidadegerenciadora", colunas_low)
  idx_ano <- match("anocompra", colunas_low)
  idx_num <- match("numerocompra", colunas_low)
  idx_pncp_compra <- match("numerocontrolepncpcompra", colunas_low)
  idx_id_compra <- match("idcompra", colunas_low)
  
  for(j in 1:nrow(df_atas_completo)) {
    ata_cnpj <- if(!is.na(idx_cnpj)) as.character(df_atas_completo[[idx_cnpj]][j]) else ""
    ata_ano <- if(!is.na(idx_ano)) as.character(df_atas_completo[[idx_ano]][j]) else ""
    
    ata_num_str <- if(!is.na(idx_num)) as.character(df_atas_completo[[idx_num]][j]) else ""
    ata_num <- if(ata_num_str != "" && !is.na(ata_num_str)) as.numeric(str_extract(ata_num_str, "^[0-9]+")) else 0
    
    # 1º Tentativa: Cruzamento Inteligente
    match_licitacao <- df_licitacoes %>% filter(cnpjOrgao == ata_cnpj & anoCompra == ata_ano & seqCompra == ata_num)
    
    if(nrow(match_licitacao) >= 1) {
      df_atas_completo$Chave_Ligacao_PowerBI[j] <- match_licitacao$numeroControlePNCP[1]
    } else {
      # 2º Tentativa: ID Formal do Governo (Case Insensitive)
      ata_id_compra <- if(!is.na(idx_pncp_compra)) df_atas_completo[[idx_pncp_compra]][j] else if(!is.na(idx_id_compra)) df_atas_completo[[idx_id_compra]][j] else ""
      
      if(!is.na(ata_id_compra) && ata_id_compra %in% lista_ids_mestres) {
        df_atas_completo$Chave_Ligacao_PowerBI[j] <- ata_id_compra
      }
    }
  }
  
  df_atas_alvo <- df_atas_completo %>% filter(!is.na(Chave_Ligacao_PowerBI))
  
  cat(sprintf("✂️ De %d Atas na Prefeitura, filtramos cirurgicamente APENAS as suas!\n", nrow(df_atas_completo)))
  
  if(nrow(df_atas_alvo) > 0) {
    df_pg <- df_atas_alvo %>% mutate(across(where(is.list), ~ sapply(., function(x) as.character(toJSON(x, auto_unbox = TRUE)))))
    dbWriteTable(conexao_pg, "ATAS1", df_pg, overwrite = TRUE, row.names = FALSE)
    cat(sprintf("🏆 SUCESSO! Banco 'ATAS1' gravado com %d Atas EXCLUSIVAS da sua base!\n", nrow(df_pg)))
  } else {
    cat("🛑 Após o filtro, nenhuma das atas da prefeitura pertencia à sua base de Licitações.\n")
  }
} else { 
  cat("🛑 A varredura não retornou nenhuma Ata.\n") 
}
dbDisconnect(conexao_pg)