library(DBI)
library(RPostgres)
library(httr)
library(jsonlite)
library(dplyr)

cat("==================================================================\n")
cat("🚀 SCRIPT 1 - LICITAÇÕES1 (ARRASTÃO MESTRE - ATÉ 22/04/2026)\n")
cat("==================================================================\n\n")

# 1. Matriz de CNPJs (Os 36 Órgãos da SEGEP + 1 Filial GMB)
orgaos_pmb <- data.frame(
  sigla = c("PMB", "ARBEL", "GAB. P.", "GAB. V.", "CODEM", "CINBESA", "CGM", "FVSOL", "FUNPAPA", "FMAS", "GMB", "GMB-F", "BELEMPREV", "IASB", "OGM", "PGM", "PROMABEN", "SEGEP", "SEMEC", "SESMA", "SEZEL", "SEDCON", "SEINFRA", "SEHAB", "SEMMA", "SEMCULT", "SEMEL", "SEGOV", "SEFIN", "SEMCAD", "SEPDA", "SECOM", "SEGBEL", "SEMU", "SEMIAC", "SEAPE", "SEMTE"),
  cnpj = c("05055009000113", "19670696000191", "30513019000100", "07303818000122", "04977583000166", "04850095000193", "09551008000110", "21700218000129", "05065644000181", "14684151000110", "49159407000155", "05055009000628", "29331615000182", "29331512000112", "11536671000198", "14098990000157", "05055009001004", "14700173000127", "05055033000152", "07917818000112", "04789822000154", "10245579000106", "05055041000107", "02346546000124", "05544392000173", "06066036000154", "09453989000163", "05055017000160", "05055025000106", "53506046000143", "54305300000108", "59693965000150", "59815458000141", "59870569000150", "59631344000141", "59819427000169", "59927733000119")
)

# 2. Matriz de Datas (Fixada até 22/04/2026)
lotes_datas <- list(
  c("2021-01-01", "2021-12-31"), 
  c("2022-01-01", "2022-12-31"),
  c("2023-01-01", "2023-12-31"), 
  c("2024-01-01", "2024-12-31"),
  c("2025-01-01", "2025-12-31"), 
  c("2026-01-01", "2026-04-22")
)

# 3. Matriz de Modalidades (Obrigatório 1 a 11)
codigos_mod <- 1:11 

df_licitacoes_completo <- data.frame()

cat("🛡️ Sistema Antibloqueio ATIVADO. Se o governo bloquear, o script aguarda e tenta de novo.\n\n")

# 4. Loop de Extração
for (i in 1:nrow(orgaos_pmb)) {
  cnpj_atual <- orgaos_pmb$cnpj[i]
  sigla_atual <- orgaos_pmb$sigla[i]
  
  cat(sprintf("\n🟡 [%02d/%02d] Varrendo Órgão: %s (%s)\n", i, nrow(orgaos_pmb), sigla_atual, cnpj_atual))
  
  for (lote in lotes_datas) {
    p_ini <- lote[1]; p_fim <- lote[2]
    
    for (mod in codigos_mod) {
      pagina_atual <- 1
      tem_pag <- TRUE
      
      while(tem_pag) {
        url <- paste0(
          "https://dadosabertos.compras.gov.br/modulo-contratacoes/1_consultarContratacoes_PNCP_14133",
          "?orgaoEntidadeCnpj=", cnpj_atual,
          "&dataPublicacaoPncpInicial=", p_ini,
          "&dataPublicacaoPncpFinal=", p_fim,
          "&codigoModalidade=", mod,
          "&pagina=", pagina_atual,
          "&tamanhoPagina=500"
        )
        
        # --- BLINDAGEM DE ERROS E FIREWALL ---
        sucesso_requisicao <- FALSE
        tentativas <- 0
        dados <- NULL
        
        while(!sucesso_requisicao && tentativas < 5) {
          tryCatch({
            resp <- GET(url, add_headers("Accept" = "application/json"), timeout(45))
            codigo_http <- status_code(resp)
            
            if (codigo_http == 200) {
              dados <- fromJSON(content(resp, "text", encoding = "UTF-8"), flatten = TRUE)
              sucesso_requisicao <- TRUE
              
            } else if (codigo_http == 429) {
              cat("\r   🚧 [FIREWALL SERPRO] Limite atingido. Aguardando 15s para respirar... ")
              flush.console()
              Sys.sleep(15)
              tentativas <- tentativas + 1
              
            } else if (codigo_http %in% c(404, 422, 204)) {
              sucesso_requisicao <- TRUE 
              
            } else {
              Sys.sleep(5)
              tentativas <- tentativas + 1
            }
          }, error = function(e) {
            Sys.sleep(5)
            tentativas <- tentativas + 1
          })
        }
        # --- FIM DA BLINDAGEM ---
        
        # Salvamento se obteve sucesso
        if (sucesso_requisicao && !is.null(dados) && !is.null(dados$resultado) && length(dados$resultado) > 0) {
          df_temp <- as.data.frame(dados$resultado)
          df_temp$DW_Sigla_Orgao <- sigla_atual
          
          df_licitacoes_completo <- bind_rows(df_licitacoes_completo, df_temp)
          
          cat(sprintf("\r   ✅ %s | Mod %02d | Pág %d: +%d compras salvas (Total: %d)", substr(p_ini, 1, 4), mod, pagina_atual, nrow(df_temp), nrow(df_licitacoes_completo)))
          flush.console()
          
          if (!is.null(dados$paginasRestantes) && dados$paginasRestantes > 0) {
            pagina_atual <- pagina_atual + 1
          } else {
            tem_pag <- FALSE
          }
        } else {
          tem_pag <- FALSE
        }
        
        Sys.sleep(1) # Pausa amigável OBRIGATÓRIA de 1 segundo
      }
    }
  }
}

# 5. Fechamento e Envio para o PostgreSQL
cat("\n\n==================================================================\n")
cat("🎯 EXTRAÇÃO BLINDADA CONCLUÍDA! SALVANDO NO POSTGRESQL...\n")
cat("==================================================================\n")

if(nrow(df_licitacoes_completo) > 0) {
  df_licitacoes_completo <- distinct(df_licitacoes_completo, numeroControlePNCP, .keep_all = TRUE)
  
  df_pg <- df_licitacoes_completo %>%
    mutate(across(where(is.list), ~ sapply(., function(x) {
      if(is.null(x) || length(x) == 0) return(NA_character_)
      as.character(toJSON(x, auto_unbox = TRUE))
    })))
  
  conexao_pg <- tryCatch({
    dbConnect(RPostgres::Postgres(), dbname = "GOV", host = "[HOST_REMOVED]", port = 5432, user = "postgres", password = "[YOUR_KEY_HERE]")
  }, error = function(e) { stop("❌ Falha crítica ao conectar no PostgreSQL!") })
  
  dbWriteTable(conexao_pg, "LICITACOES1", df_pg, overwrite = TRUE, row.names = FALSE)
  dbDisconnect(conexao_pg)
  
  cat(sprintf("🏆 SUCESSO! O banco 'LICITACOES1' foi criado do zero com %d registros.\n", nrow(df_pg)))
} else { 
  cat("🛑 A varredura não retornou dados.\n") 
}