# ==============================================================================
# SISTEMA INTEGRADO DE GESTÃO PATRIMONIAL - FABRÍCIO (V. FINAL COM CALENDÁRIO)
# ==============================================================================

library(shiny)
library(bslib)
library(htmltools)
library(DBI)
library(RPostgres)

# 1. PARÂMETROS TÉCNICOS E FINANCEIROS
valor_juros          <- 43880  
valor_carro_total    <- 75000
entrada_carro        <- 20000
poupanca_casa_init   <- 27000  
meta_casa            <- 70000 
juros_por_km         <- 0.41
patrimonio_por_km    <- 0.52
lucro_por_km         <- 0.93   
limite_fabricio      <- 1200.00
salario_fabricio     <- 5200.00

# Credenciais do Banco
db_host <- "[HOST_REMOVED]"
db_name <- "GOV"
db_user <- "postgres"
db_pass <- "admin123"

conectar_db <- function() {
  dbConnect(RPostgres::Postgres(), dbname = db_name, host = db_host, 
            port = 5432, user = db_user, password = db_pass)
}

# 2. CSS - ESTÉTICA DARK MINIMALISTA
estetica_css <- "
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;700&family=Rajdhani:wght@600;700&display=swap');
  
  body, .content-wrapper {
    font-family: 'Inter', sans-serif;
    background-color: #0b0e14 !important;
    color: #e6edf3;
  }
  .card-custom {
    background-color: #161b22;
    border: 1px solid #30363d;
    border-radius: 16px;
    padding: 24px;
    text-align: center;
    transition: transform 0.3s ease;
  }
  .card-custom:hover { transform: translateY(-5px); }
  .icon-fill {
    font-size: 100px;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    display: inline-block;
    transition: all 1.2s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .valor-grande {
    font-family: 'Rajdhani', sans-serif;
    font-size: 32px;
    font-weight: 700;
    margin-top: 10px;
  }
  .label-sub { color: #8b949e; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
  .btn-primary { background-color: #238636; border: none; font-weight: bold; padding: 12px; }
  .btn-primary:hover { background-color: #2ea043; }
  .form-control, .form-select {
    background-color: #0b0e14;
    color: #e6edf3;
    border: 1px solid #30363d;
  }
  .form-control:focus, .form-select:focus {
    background-color: #0b0e14;
    color: #e6edf3;
    border-color: #58a6ff;
    box-shadow: 0 0 0 0.25rem rgba(88, 166, 255, 0.25);
  }
  .login-container {
    max-width: 400px;
    margin: 10vh auto;
  }
  details summary {
    cursor: pointer;
    color: #8b949e;
    font-size: 14px;
    margin-top: 10px;
    outline: none;
  }
  details summary:hover { color: #f85149; }
  .btn-excluir-inline:hover { color: #f85149 !important; transform: scale(1.2); }
"

# 3. INTERFACE DO USUÁRIO
login_ui <- div(class = "login-container card-custom",
                h3("SISTEMA DE GESTÃO", style = "font-family: 'Rajdhani'; color: #e6edf3; margin-bottom: 20px;"),
                tags$i(class = "fas fa-shield-halved", style = "font-size: 50px; color: #30363d; margin-bottom: 20px;"),
                textInput("login_user", "Usuário:", width = "100%"),
                passwordInput("login_pass", "Senha : "[YOUR_KEY_HERE]"100%"),
                br(),
                actionButton("btn_login", "AUTENTICAR", class = "btn btn-primary w-100", icon = icon("right-to-bracket"))
)

main_ui <- div(
  layout_columns(
    col_widths = c(4, 4, 4),
    div(class = "card-custom", span(class = "label-sub", "JUROS PAGOS"), br(), uiOutput("carro_azul"), div(class = "valor-grande", style = "color: #58a6ff;", textOutput("txt_divida_perc")), textOutput("txt_divida_valor")),
    div(class = "card-custom", span(class = "label-sub", "CONSTITUIÇÃO DE PATRIMÔNIO"), br(), uiOutput("carro_verde"), div(class = "valor-grande", style = "color: #3fb950;", textOutput("txt_equity_perc")), textOutput("txt_equity_valor")),
    div(class = "card-custom", span(class = "label-sub", "Fundo Imobiliário 2027"), br(), uiOutput("casa_ouro"), div(class = "valor-grande", style = "color: #f1e05a;", textOutput("txt_casa_perc")), textOutput("txt_casa_valor"))
  ),
  hr(style = "border-color: #30363d; margin: 40px 0;"),
  layout_columns(
    col_widths = c(4, 8),
    div(class = "card-custom", style = "text-align: left;",
        h5("CONTROLES DE ENTRADA", style="margin-bottom: 20px;"),
        numericInput("km_input", "KM Rodados no Turno:", value = 0, min = 0),
        actionButton("run_calc", "COMPUTAR KM", class = "btn btn-primary w-100 mb-4"),
        numericInput("val_poup", "Valor Poupado no Mês (R$):", value = 2000, min = 0),
        actionButton("add_month", "REGISTRAR MÊS", class = "btn btn-outline-info w-100 mb-4"),
        hr(style = "border-color: #30363d;"),
        # SEÇÃO PROTEGIDA - MAIS OPÇÕES
        tags$details(
          tags$summary("Mais Opções"),
          div(style = "padding-top: 15px;",
              actionButton("reset_btn", "ZERAR SISTEMA", class = "btn btn-outline-danger btn-sm w-100")
          )
        )
    ),
    div(class = "card-custom", style = "text-align: left;",
        h5("SIMULADOR DE FATURAS - CARTÕES", style="margin-bottom: 20px; color: #e6edf3;"),
        layout_columns(
          col_widths = c(5, 7),
          div(
            div(style = "display: flex; align-items: flex-end; gap: 10px;",
                div(style = "flex-grow: 1;",
                    selectInput("fatura_perfil", "Selecionar Perfil:", choices = c("FABRÍCIO", "RAFAEL", "RODRIGO", "LAIZE", "MÃE"))
                ),
                actionButton("btn_novo_perfil", icon("plus"), class = "btn btn-outline-success", style = "margin-bottom: 1rem;", title = "Adicionar Novo Perfil")
            ),
            dateInput("fatura_data", "Data da Compra:", value = Sys.Date(), format = "dd/mm/yyyy", language = "pt-BR"),
            textInput("fatura_desc", "Descrição da Compra:"),
            numericInput("fatura_valor", "Valor (R$):", value = 0, min = 0),
            actionButton("add_despesa", "LANÇAR DESPESA", class = "btn btn-primary w-100 mt-2")
          ),
          div(
            div(style = "display: flex; gap: 10px; margin-bottom: 15px; background: #0b0e14; padding: 10px; border-radius: 8px; border: 1px solid #30363d;",
                selectInput("filtro_mes", "Visualizar Mês:", 
                            choices = list("Janeiro" = "01", "Fevereiro" = "02", "Março" = "03", "Abril" = "04", 
                                           "Maio" = "05", "Junho" = "06", "Julho" = "07", "Agosto" = "08", 
                                           "Setembro" = "09", "Outubro" = "10", "Novembro" = "11", "Dezembro" = "12"), 
                            selected = format(Sys.Date(), "%m"), width = "60%"),
                selectInput("filtro_ano", "Ano:", 
                            choices = c("2025", "2026", "2027"), 
                            selected = format(Sys.Date(), "%Y"), width = "40%")
            ),
            uiOutput("alerta_limite_fabricio"),
            div(style = "display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #30363d; padding-bottom: 10px; margin-bottom: 10px;",
                h6("Total do Mês Selecionado:", style = "margin: 0; color: #8b949e;"),
                h4(textOutput("fatura_total_perfil"), style = "margin: 0; font-family: 'Rajdhani', sans-serif; color: #f1e05a;")
            ),
            uiOutput("insights_despesas"),
            div(style = "max-height: 250px; overflow-y: auto; padding-right: 5px;", uiOutput("tabela_fatura_ui"))
          )
        )
    )
  )
)

ui <- fluidPage(
  theme = bs_theme(version = 5, preset = "darkly"),
  tags$head(
    tags$style(HTML(estetica_css)),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css")
  ),
  uiOutput("ui_dinamica")
)

# 4. SERVIDOR
server <- function(input, output, session) {
  
  usuario_logado <- reactiveVal(FALSE)
  data <- reactiveValues(
    km_historico = 0,
    poup_historico = poupanca_casa_init,
    meses_passados = 0,
    despesas = data.frame(id = integer(), Perfil = character(), Descricao = character(), Valor = numeric(), Data = character(), stringsAsFactors = FALSE)
  )
  
  output$ui_dinamica <- renderUI({
    if (usuario_logado()) return(main_ui) else return(login_ui)
  })
  
  observeEvent(input$btn_login, {
    if (input$login_user == "fabricion" && input$login_pass == "admin123") {
      tryCatch({
        con <- conectar_db()
        dbExecute(con, "CREATE TABLE IF NOT EXISTS estado_patrimonio (id SERIAL PRIMARY KEY, km_historico NUMERIC, poup_historico NUMERIC, meses_passados INTEGER)")
        dbExecute(con, "CREATE TABLE IF NOT EXISTS despesas_cartao (id SERIAL PRIMARY KEY, perfil TEXT, descricao TEXT, valor NUMERIC, data_compra TEXT)")
        
        # CRIAÇÃO DA TABELA DE PERFIS E CARGA INICIAL
        dbExecute(con, "CREATE TABLE IF NOT EXISTS perfis_usuario (nome TEXT UNIQUE)")
        
        perfis_padrao <- c("FABRÍCIO", "RAFAEL", "RODRIGO", "LAIZE", "MÃE")
        for (p in perfis_padrao) {
          dbExecute(con, "INSERT INTO perfis_usuario (nome) VALUES ($1) ON CONFLICT (nome) DO NOTHING", params = list(p))
        }
        # Migra silenciosamente perfis que já estavam nas despesas antigas para a tabela nova
        dbExecute(con, "INSERT INTO perfis_usuario (nome) SELECT DISTINCT perfil FROM despesas_cartao ON CONFLICT (nome) DO NOTHING")
        
        res_patrimonio <- dbGetQuery(con, "SELECT * FROM estado_patrimonio WHERE id = 1")
        if (nrow(res_patrimonio) == 0) {
          dbExecute(con, sprintf("INSERT INTO estado_patrimonio (id, km_historico, poup_historico, meses_passados) VALUES (1, 0, %f, 0)", poupanca_casa_init))
        } else {
          # Corrige o banco de dados caso ainda esteja com o valor antigo de 30 mil
          if (res_patrimonio$poup_historico[1] == 30000) {
            dbExecute(con, sprintf("UPDATE estado_patrimonio SET poup_historico = %f WHERE id = 1", poupanca_casa_init))
            res_patrimonio$poup_historico[1] <- poupanca_casa_init
          }
          data$km_historico <- res_patrimonio$km_historico[1]
          data$poup_historico <- res_patrimonio$poup_historico[1]
          data$meses_passados <- res_patrimonio$meses_passados[1]
        }
        
        data$despesas <- dbGetQuery(con, "SELECT id, perfil AS \"Perfil\", descricao AS \"Descricao\", valor AS \"Valor\", data_compra AS \"Data\" FROM despesas_cartao ORDER BY id DESC")
        dbDisconnect(con)
        usuario_logado(TRUE)
        
        # Recuperar perfis históricos do banco e atualizar o menu
        perfis_historicos <- unique(data$despesas$Perfil)
        todos_perfis <- unique(c("FABRÍCIO", "RAFAEL", "RODRIGO", "LAIZE", "MÃE", perfis_historicos))
        updateSelectInput(session, "fatura_perfil", choices = todos_perfis, selected = "FABRÍCIO")
      }, error = function(e) {
        showNotification(paste("Erro no Banco de Dados:", e$message), type = "error")
      })
    } else {
      showNotification("Credenciais Incorretas", type = "error")
    }
  })
  
  # LÓGICA DO BOTÃO DE NOVO PERFIL
  observeEvent(input$btn_novo_perfil, {
    showModal(modalDialog(
      title = "Adicionar Novo Perfil",
      textInput("novo_perfil_nome", "Nome do Perfil (Ex: JOÃO):"),
      footer = tagList(
        modalButton("Cancelar"),
        actionButton("salvar_novo_perfil", "Salvar", class = "btn btn-primary")
      ),
      easyClose = TRUE
    ))
  })
  
  observeEvent(input$salvar_novo_perfil, {
    req(input$novo_perfil_nome)
    novo_nome <- toupper(trimws(input$novo_perfil_nome))
    if (novo_nome != "") {
      con <- conectar_db()
      dbExecute(con, "INSERT INTO perfis_usuario (nome) VALUES ($1) ON CONFLICT (nome) DO NOTHING", params = list(novo_nome))
      res_perfis <- dbGetQuery(con, "SELECT nome FROM perfis_usuario ORDER BY nome")
      dbDisconnect(con)
      
      todos_perfis <- res_perfis$nome
      updateSelectInput(session, "fatura_perfil", choices = todos_perfis, selected = novo_nome)
      removeModal()
    }
  })
  
  # LÓGICA DE GRAVAÇÃO
  observeEvent(input$run_calc, {
    req(input$km_input > 0)
    data$km_historico <- data$km_historico + input$km_input
    con <- conectar_db()
    dbExecute(con, sprintf("UPDATE estado_patrimonio SET km_historico = %f WHERE id = 1", data$km_historico))
    dbDisconnect(con)
    updateNumericInput(session, "km_input", value = 0)
  })
  
  observeEvent(input$add_month, {
    req(input$val_poup >= 0)
    data$poup_historico <- data$poup_historico + input$val_poup
    data$meses_passados <- data$meses_passados + 1
    con <- conectar_db()
    dbExecute(con, sprintf("UPDATE estado_patrimonio SET poup_historico = %f, meses_passados = %d WHERE id = 1", data$poup_historico, data$meses_passados))
    dbDisconnect(con)
  })
  
  observeEvent(input$add_despesa, {
    req(input$fatura_desc != "", input$fatura_valor > 0)
    # Transforma a data do calendário em texto dd/mm/yyyy para o banco
    data_formatada <- format(input$fatura_data, "%d/%m/%Y") 
    
    con <- conectar_db()
    dbExecute(con, "INSERT INTO despesas_cartao (perfil, descricao, valor, data_compra) VALUES ($1, $2, $3, $4)", params = list(input$fatura_perfil, input$fatura_desc, input$fatura_valor, data_formatada))
    data$despesas <- dbGetQuery(con, "SELECT id, perfil AS \"Perfil\", descricao AS \"Descricao\", valor AS \"Valor\", data_compra AS \"Data\" FROM despesas_cartao ORDER BY id DESC")
    dbDisconnect(con)
    
    updateTextInput(session, "fatura_desc", value = "")
    updateNumericInput(session, "fatura_valor", value = 0)
  })
  
  observeEvent(input$reset_btn, {
    data$km_historico <- 0
    data$poup_historico <- poupanca_casa_init
    data$meses_passados <- 0
    data$despesas <- data.frame(id = integer(), Perfil = character(), Descricao = character(), Valor = numeric(), Data = character(), stringsAsFactors = FALSE)
    con <- conectar_db()
    dbExecute(con, sprintf("UPDATE estado_patrimonio SET km_historico = 0, poup_historico = %f, meses_passados = 0 WHERE id = 1", poupanca_casa_init))
    dbExecute(con, "TRUNCATE TABLE despesas_cartao")
    dbDisconnect(con)
    showNotification("Sistema zerado.", type = "warning")
  })
  
  # LÓGICA DE EXCLUSÃO DE LANÇAMENTO INLINE (BOTÃO X)
  observeEvent(input$delete_row_id, {
    con <- conectar_db()
    dbExecute(con, "DELETE FROM despesas_cartao WHERE id = $1", params = list(as.integer(input$delete_row_id)))
    data$despesas <- dbGetQuery(con, "SELECT id, perfil AS \"Perfil\", descricao AS \"Descricao\", valor AS \"Valor\", data_compra AS \"Data\" FROM despesas_cartao ORDER BY id DESC")
    dbDisconnect(con)
  })
  
  # RENDERIZAÇÃO VISUAL
  status <- reactive({
    pago_juros <- min(data$km_historico * juros_por_km, valor_juros)
    perc_juros <- (pago_juros / valor_juros) * 100
    prop_real <- min(entrada_carro + (data$km_historico * patrimonio_por_km), valor_carro_total)
    perc_carro <- (prop_real / valor_carro_total) * 100
    perc_casa <- min((data$poup_historico / meta_casa) * 100, 100)
    list(perc_banco = perc_juros, valor_banco = pago_juros, perc_carro = perc_carro, valor_carro = prop_real, perc_casa = perc_casa, valor_casa = data$poup_historico)
  })
  
  output$carro_azul <- renderUI({
    perc <- status()$perc_banco
    grad <- sprintf("linear-gradient(to top, #58a6ff %f%%, #30363d %f%%)", perc, perc)
    tags$i(class = "fas fa-car-side icon-fill", style = sprintf("background: %s; -webkit-background-clip: text;", grad))
  })
  output$carro_verde <- renderUI({
    perc <- status()$perc_carro
    grad <- sprintf("linear-gradient(to top, #3fb950 %f%%, #30363d %f%%)", perc, perc)
    tags$i(class = "fas fa-car-side icon-fill", style = sprintf("background: %s; -webkit-background-clip: text;", grad))
  })
  output$casa_ouro <- renderUI({
    perc <- status()$perc_casa
    grad <- sprintf("linear-gradient(to top, #f1e05a %f%%, #30363d %f%%)", perc, perc)
    tags$i(class = "fas fa-house-chimney icon-fill", style = sprintf("background: %s; -webkit-background-clip: text;", grad))
  })
  
  output$txt_divida_perc <- renderText({ sprintf("%.4f%%", status()$perc_banco) })
  output$txt_divida_valor <- renderText({ sprintf("R$ %.2f de R$ 43.880,00", status()$valor_banco) })
  output$txt_equity_perc <- renderText({ sprintf("%.4f%%", status()$perc_carro) })
  output$txt_equity_valor <- renderText({ sprintf("R$ %.2f de R$ 75.000,00", status()$valor_carro) })
  output$txt_casa_perc <- renderText({ sprintf("%.1f%%", status()$perc_casa) })
  output$txt_casa_valor <- renderText({ sprintf("R$ %.2f acumulados", status()$valor_casa) })
  
  # LÓGICA DE FILTRAGEM DE MÊS E ANO
  despesas_filtradas <- reactive({
    if(nrow(data$despesas) == 0) return(data.frame())
    df_perfil <- data$despesas[data$despesas$Perfil == input$fatura_perfil, ]
    
    # Busca por padrão "/MM/YYYY" ou pelos lançamentos antigos de abril "/04"
    termo_busca_novo <- paste0("/", input$filtro_mes, "/", input$filtro_ano)
    termo_busca_antigo <- paste0("/", input$filtro_mes) 
    
    df_filtrado <- df_perfil[grepl(termo_busca_novo, df_perfil$Data) | 
                               (grepl(termo_busca_antigo, df_perfil$Data) & nchar(df_perfil$Data) <= 5 & input$filtro_ano == "2026"), ]
    
    return(df_filtrado)
  })
  
  output$fatura_total_perfil <- renderText({
    df <- despesas_filtradas()
    if(nrow(df) == 0) return("R$ 0.00")
    sprintf("R$ %.2f", sum(as.numeric(df$Valor)))
  })
  
  output$insights_despesas <- renderUI({
    df <- despesas_filtradas()
    if(nrow(df) == 0) return(NULL)
    
    # Agrupa e soma os gastos por descrição (ignorando letras maiúsculas/minúsculas para juntar "99" com "99 app", etc)
    df$ValorNum <- as.numeric(df$Valor)
    df$Desc_lower <- tolower(trimws(df$Descricao))
    gastos <- aggregate(ValorNum ~ Desc_lower, data = df, sum)
    gastos <- gastos[order(-gastos$ValorNum), ] # Ordena do maior para o menor gasto
    
    # Pega os Top 5 (ou menos, se houver menos de 5)
    n_items <- min(5, nrow(gastos))
    top_gastos <- gastos[1:n_items, ]
    
    # Cria a lista de HTML
    linhas_lista <- lapply(1:n_items, function(i) {
      item <- top_gastos$Desc_lower[i]
      valor <- top_gastos$ValorNum[i]
      
      alerta <- ""
      cor_texto <- "#c9d1d9" # Cor padrão da fonte
      
      # Mantém os avisos se alguma categoria perigosa estiver no Top 5
      if (any(sapply(c("99", "uber", "indrive", "transporte", "taxi"), function(x) grepl(x, item)))) {
        alerta <- " <span style='color: #f85149; font-size: 11px; font-weight: normal;'>(Maneire nos apps!)</span>"
      } else if (any(sapply(c("ifood", "pizza", "lanche", "restaurante", "delivery", "hamburguer"), function(x) grepl(x, item)))) {
        alerta <- " <span style='color: #d29922; font-size: 11px; font-weight: normal;'>(Cuidado com delivery!)</span>"
      }
      
      tags$li(style = sprintf("margin-bottom: 4px; color: %s;", cor_texto),
        HTML(sprintf("<b>%s</b>: R$ %.2f%s", toupper(item), valor, alerta))
      )
    })
    
    div(style = "border-left: 4px solid #58a6ff; background-color: rgba(255,255,255,0.05); padding: 10px; margin-bottom: 10px; border-radius: 0 4px 4px 0; font-size: 13px;",
        div(style = "color: #58a6ff; font-weight: bold; margin-bottom: 8px;", 
            tags$i(class = "fas fa-list-ol", style = "margin-right: 8px;"), 
            "TOP 5 MAIORES GASTOS DO MÊS:"
        ),
        tags$ol(style = "margin: 0; padding-left: 20px;", linhas_lista)
    )
  })
  
  output$alerta_limite_fabricio <- renderUI({
    req(input$fatura_perfil == "FABRÍCIO")
    df <- despesas_filtradas()
    total_gasto <- if(nrow(df) > 0) sum(as.numeric(df$Valor)) else 0
    
    saldo_restante <- salario_fabricio - total_gasto
    cor_alerta <- ifelse(saldo_restante < 0, "#f85149", "#3fb950")
    
    div(style = sprintf("border: 1px solid %s; border-radius: 8px; padding: 12px; margin-bottom: 15px; background-color: rgba(0,0,0,0.2);", cor_alerta), 
        h6("RESUMO FINANCEIRO - FABRÍCIO", style = "margin: 0 0 10px 0; color: #8b949e;"), 
        div(style = "display: flex; justify-content: space-between; margin-bottom: 5px;", 
            span("Salário Mensal:"), 
            strong(sprintf("R$ %.2f", salario_fabricio), style = "color: #58a6ff;")
        ),
        div(style = "display: flex; justify-content: space-between; margin-bottom: 5px;", 
            span("Total Devido (Fatura):"), 
            strong(sprintf("- R$ %.2f", total_gasto), style = "color: #f85149;")
        ),
        div(style = "display: flex; justify-content: space-between; border-top: 1px dashed #30363d; padding-top: 5px; margin-top: 5px;", 
            span("Saldo Livre:"), 
            strong(sprintf("R$ %.2f", saldo_restante), style = sprintf("color: %s;", cor_alerta))
        )
    )
  })
  
  output$tabela_fatura_ui <- renderUI({
    df <- despesas_filtradas()
    if(nrow(df) == 0) return(div(style = "padding: 10px; color: #8b949e; text-align: center;", "Nenhum lançamento no perfil para o mês selecionado."))
    
    linhas <- lapply(1:nrow(df), function(i) {
      row <- df[i, ]
      div(style = "display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #30363d; padding: 10px 5px;",
          div(style = "flex: 0 0 85px; color: #8b949e; font-size: 13px;", row$Data),
          div(style = "flex: 1; color: #c9d1d9; font-size: 14px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding-right: 10px;", row$Descricao),
          div(style = "flex: 0 0 90px; text-align: right; color: #e6edf3; font-weight: bold; font-family: 'Rajdhani', sans-serif;", sprintf("R$ %.2f", as.numeric(row$Valor))),
          div(style = "flex: 0 0 30px; text-align: right;",
              tags$button(id = row$id, class = "btn btn-sm btn-excluir-inline", style = "background: transparent; border: none; color: #8b949e; padding: 0 5px; transition: 0.3s;",
                          title = "Excluir este lançamento",
                          onclick = "Shiny.setInputValue('delete_row_id', this.id, {priority: 'event'});",
                          tags$i(class = "fas fa-times"))
          )
      )
    })
    div(style = "display: flex; flex-direction: column;", linhas)
  })
}

shinyApp(ui, server)