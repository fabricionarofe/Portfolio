library(DBI)
library(RPostgres)
library(httr)
library(jsonlite)
library(dplyr)

cat("==================================================================\n")
cat("📄 SCRIPT 3 - CONTRATOS1 (API DE CONSULTA PÚBLICA OFICIAL)\n")
cat("==================================================================\n\n")

# 1. Matriz de CNPJs (Os 37 Órgãos da PMB)
orgaos_pmb <- c("05055009000113", "19670696000191", "30513019000100", "07303818000122", "04977583000166", "04850095000193", "09551008000110", "21700218000129", "05065644000181", "14684151000110", "49159407000155", "05055009000628", "29331615000182", "29331512000112", "11536671000198", "14098990000157", "05055009001004", "14700173000127", "05055033000152", "07917818000112", "04789822000154", "10245579000106", "05055041000107", "02346546000124", "05544392000173", "06066036000154", "09453989000163", "05055017000160", "05055025000106", "53506046000143", "54305300000108", "59693965000150", "59815458000141", "59870569000150", "59631344000141", "59819427000169", "59927733000119")

# 2. Lotes de Datas (Formato da API do site: YYYYMMDD)
lotes_datas <- list(
  c("20210101", "20211231"), c("20220101", "20221231"),
  c("20230101", "20231231"), c("20240101", "20241231"),
  c("20250101", "20251231"), c("20260101", format(Sys.Date(), "%Y%m%d"))
)

conexao_pg <- tryCatch({
  dbConnect(RPostgres::Postgres(), dbname = "GOV", host = "[HOST_REMOVED]", port = 5432, user = "postgres", password = "[YOUR_KEY_HERE]")
}, error = function(e) { stop("❌ Erro ao conectar no banco!") })

df_contratos_completo <- data.frame()
total_contratos <- 0

# 3. Loop de Extração
for (i in 1:length(orgaos_pmb)) {
  cnpj_atual <- orgaos_pmb[i]
  cat(sprintf("\n🟡 [%02d/%02d] Varrendo Consulta Pública do CNPJ: %s\n", i, length(orgaos_pmb), cnpj_atual))
  
  for (lote in lotes_datas) {
    p_ini <- lote[1]; p_fim <- lote[2]
    pagina_atual <- 1
    tem_pag <- TRUE
    
    while(tem_pag) {
      # A ROTA MESTRA (A mesma que o site pncp.gov.br usa no frontend)
      url <- paste0(
        "https://pncp.gov.br/api/consulta/v1/contratos",
        "?dataInicial=", p_ini,
        "&dataFinal=", p_fim,
        "&cnpjOrgao=", cnpj_atual,
        "&pagina=", pagina_atual,
        "&tamanhoPagina=100"
      )
      
      sucesso <- FALSE
      tentativas <- 0
      dados <- NULL
      
      while(!sucesso && tentativas < 3) {
        tryCatch({
          resp <- GET(url, add_headers("Accept" = "application/json"), timeout(20))
          codigo <- status_code(resp)
          
          if (codigo == 200) {
            dados <- fromJSON(content(resp, "text", encoding = "UTF-8"), flatten = TRUE)
            sucesso <- TRUE
          } else if (codigo == 429) {
            cat(sprintf("\r   🚧 [FIREWALL] 15s... (Acumulado: %d)   ", total_contratos))
            flush.console(); Sys.sleep(15); tentativas <- tentativas + 1
          } else if (codigo %in% c(404, 204, 422)) {
            sucesso <- TRUE 
          } else { Sys.sleep(2); tentativas <- tentativas + 1 }
        }, error = function(e) { Sys.sleep(2); tentativas <- tentativas + 1 })
      }
      
      # Nesta API, os dados ficam dentro da chave $data (diferente da dados abertos que é $resultado)
      if (sucesso && !is.null(dados) && !is.null(dados$data) && length(dados$data) > 0) {
        df_temp <- as.data.frame(dados$data)
        df_contratos_completo <- bind_rows(df_contratos_completo, df_temp)
        
        qtd_agora <- nrow(df_temp)
        total_contratos <- total_contratos + qtd_agora
        
        cat(sprintf("\r   ✅ %s | Pág %d: Achou +%d | Total Acumulado: %d", 
                    substr(p_ini, 1, 4), pagina_atual, qtd_agora, total_contratos))
        flush.console()
        
        if (!is.null(dados$paginasRestantes) && dados$paginasRestantes > 0) { 
          pagina_atual <- pagina_atual + 1 
        } else { tem_pag <- FALSE }
      } else { 
        cat(sprintf("\r   ⚠️ %s vazio. Total Acumulado: %d              ", substr(p_ini, 1, 4), total_contratos))
        flush.console()
        tem_pag <- FALSE 
      }
      
      Sys.sleep(0.5)
    }
  }
}

# 4. Salvamento
cat("\n\n==================================================================\n")
if(nrow(df_contratos_completo) > 0) {
  # Limpa os pontos dos nomes das colunas (padrão JSON desta API)
  names(df_contratos_completo) <- gsub("\\.", "", names(df_contratos_completo))
  
  df_pg <- df_contratos_completo %>% mutate(across(where(is.list), ~ sapply(., function(x) as.character(toJSON(x, auto_unbox = TRUE)))))
  
  df_pg <- distinct(df_pg, numeroControlePNCP, .keep_all = TRUE)
  
  dbWriteTable(conexao_pg, "CONTRATOS1", df_pg, overwrite = TRUE, row.names = FALSE)
  cat(sprintf("🏆 SUCESSO ABSOLUTO! Banco 'CONTRATOS1' criado com %d Contratos reais!\n", nrow(df_pg)))
} else { cat("🛑 A varredura total foi concluída. Se o número for zero, os órgãos da PMB REALMENTE não registraram os contratos no portal.\n") }
dbDisconnect(conexao_pg)