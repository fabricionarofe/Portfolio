# ==========================================
# SISTEMA DE MONITORAMENTO DE CONTRATOS - PMB
# Padrão Visual: Prefeitura Municipal de Belém
# Versão Executiva: Modalidades Legais Corrigidas
# ==========================================

library(shiny)
library(bslib)
library(DBI)
library(RPostgres)
library(DT)
library(pool)
library(shinycssloaders)
library(shinymanager)

# 0. CREDENCIAIS DO SISTEMA (LOGIN)
credenciais <- data.frame(
  user = c("camila", "lucas", "fabricio"),
  password = c("admin123", "admin123", "admin123"),
  stringsAsFactors = FALSE
)

# 1. CONEXÃO COM O BANCO DE DADOS
# Tenta ler as credenciais ocultas. Se não encontrar, usa o padrão local.
db_user <- Sys.getenv("DB_USER")
if (db_user == "") db_user <- "postgres"

db_pass <- Sys.getenv("DB_PASS")
if (db_pass == "") db_pass <- "admin123"

# Cria o pool de conexões
pool <- dbPool(RPostgres::Postgres(),
               dbname = "GOV",
               host = "[HOST_REMOVED]",
               user = db_user,
               password = db_pass)

# 2. INTERFACE DO USUÁRIO (UI)
ui <- secure_app(
  language = "pt-BR", 
  head_auth = tags$script(HTML("
    $(document).on('keydown', function(e) {
      if(e.keyCode === 13) {
        e.preventDefault();
        setTimeout(function() { $('#go_auth').click(); }, 100);
      }
    });
  ")),
  navbarPage(
  title = "Monitoramento de Contratos",
  theme = bs_theme(version = 5, bg = "#F4F7F6", fg = "#474747", primary = "#082358"),
  
  # CSS Personalizado
  tags$head(tags$style(HTML("
    @font-face { font-family: 'Just Sans'; src: url('https://prefeitura.belem.pa.gov.br/wp-content/uploads/2025/01/JUST-Sans-Regular.woff2'); }
    body { font-family: 'Just Sans', sans-serif; background-color: #F4F7F6;}
    .navbar { background-color: #082358 !important; border-bottom: 4px solid #0084DA; padding: 10px 40px; }
    .navbar-brand { font-weight: bold; font-size: 22px; color: white !important; }
    .navbar-nav .nav-link { color: rgba(255,255,255,0.8) !important; font-size: 16px; font-weight: bold; margin-left: 20px; }
    .navbar-nav .nav-link.active { color: white !important; border-bottom: 3px solid #0084DA; }
    .pmb-search-card { background: white; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 4px solid #0084DA; margin-bottom: 20px; }
    
    .kpi-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); text-align: center; border-bottom: 5px solid #ccc; height: 100%; display: flex; flex-direction: column; justify-content: center; cursor: pointer; transition: transform 0.2s; }
    .kpi-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
    .kpi-card-noclick { cursor: default; transition: none; }
    .kpi-card-noclick:hover { transform: none; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
    
    .kpi-title { font-size: 14px; color: #666; text-transform: uppercase; font-weight: bold; margin-bottom: 10px; }
    .kpi-value { font-size: 28px; color: #082358; font-weight: bold; }
    .footer-info { text-align: center; margin-top: 40px; padding: 20px; color: #666; font-size: 13px; border-top: 1px solid #ddd; }
    .nav-tabs .nav-link { color: #082358; font-weight: bold; font-size: 16px; padding: 12px 20px; }
    .nav-tabs .nav-link.active { color: #0084DA; border-bottom: 3px solid #0084DA; }
    
    /* Configurações da Tabela (Justificado e Centralizado) */
    table.dataTable tbody td { font-size: 13px !important; padding: 8px 10px !important; vertical-align: middle; }
    table.dataTable thead th { font-size: 13px !important; padding: 10px !important; background-color: #082358 !important; color: white !important; text-align: center !important; vertical-align: middle !important; }
    table.dataTable tbody tr { cursor: pointer; }
    .dataTables_wrapper { overflow-x: auto; }
    .cnpj-col { white-space: nowrap !important; }
    .dt-justify { text-align: justify !important; text-justify: inter-word; hyphens: auto; }
  "))),
  
  # =====================================================================
  # ABA PRINCIPAL: SISTEMA SEGEP
  # =====================================================================
  tabPanel("Painel Principal",
           div(class = "container-fluid", style = "max-width: 1750px; margin-top: 20px;",
               
               # Filtros Globais
               div(class = "pmb-search-card",
                   tags$h4("Sistema de Monitoramento Integrado", style="font-weight: bold; color: #082358;"),
                   tags$div(style="background-color: #eef4f8; padding: 15px; border-radius: 8px; border-left: 4px solid #4FAF47; font-size: 13px; margin-bottom: 20px;",
                            tags$strong("Transparência Ativa: "), "Em cumprimento à Lei de Acesso à Informação (Lei nº 12.527/2011) e à Nova Lei de Licitações (Lei nº 14.133/2021)."),
                   fluidRow(class = "g-3",
                     div(class = "col-12 col-md-6 col-lg-2", textInput("pesquisa_livre", "Pesquisa Livre:", placeholder = "Palavra-chave...")),
                     div(class = "col-12 col-md-6 col-lg-2", selectInput("filtro_ano", "Ano:", choices = c("Todos", 2026, 2025, 2024, 2023, 2022))),
                     div(class = "col-12 col-md-4 col-lg-3", selectInput("filtro_secretaria", "Secretaria / Órgão:", choices = c("Carregando..."))),
                     div(class = "col-12 col-md-4 col-lg-3", selectInput("filtro_farol", "Status de Vigência:", 
                                           choices = c("Todos", 
                                                       "Mais de 5 Meses",
                                                       "Até 5 Meses",
                                                       "Até 3 Meses", 
                                                       "Até 30 Dias", 
                                                       "Vencido"))), 
                     div(class = "col-12 col-md-4 col-lg-2", selectInput("filtro_ata", "Modalidade (SRP?):", choices = c("Todos", "SIM", "NÃO")))
                   )
               ),
               
               # Abas Internas de Dados
               tabsetPanel(
                 tabPanel("Contratos",
                          div(style = "padding-top: 20px;",
                              fluidRow(style = "margin-bottom: 20px;",
                                       column(6, uiOutput("kpi_total")), column(6, uiOutput("kpi_valor"))),
                              fluidRow(style = "margin-bottom: 20px;",
                                       column(2, uiOutput("kpi_verde")), column(2, uiOutput("kpi_azul")), column(2, uiOutput("kpi_amarelo")), column(3, uiOutput("kpi_laranja")), column(3, uiOutput("kpi_vermelho"))),
                              div(style = "background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);", 
                                  withSpinner(DTOutput("tabela_mestre"), type = 4, color = "#082358"))
                          )
                 ),
                 tabPanel("Contratações",
                          div(style = "padding-top: 20px;",
                              fluidRow(style = "margin-bottom: 20px;", column(4, uiOutput("kpi_lic_total"))),
                              div(style = "background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);", 
                                  tags$h4("Processos Licitatórios em Andamento (Editais)", style="font-weight: bold; color: #082358; margin-bottom: 20px;"),
                                  withSpinner(DTOutput("tabela_licitacoes"), type = 4, color = "#082358")
                              )
                          )
                 ),
                 tabPanel("Atas",
                          div(style = "padding-top: 20px;",
                              fluidRow(style = "margin-bottom: 20px;", column(4, uiOutput("kpi_atas_total"))),
                              div(style = "background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);", 
                                  tags$h4("Atas de Registro de Preços Vigentes", style="font-weight: bold; color: #082358; margin-bottom: 20px;"),
                                  withSpinner(DTOutput("tabela_atas"), type = 4, color = "#082358")
                              )
                          )
                 ),
                 tabPanel("Credenciamentos",
                          div(style = "text-align: center; padding: 60px 20px; color: #082358;",
                              tags$i(class = "fas fa-id-badge", style = "font-size: 60px; margin-bottom: 20px; color: #0084DA;"),
                              tags$h3(tags$b("Módulo de Credenciamentos")),
                              tags$p("Esta página está reservada para a indexação dos editais de credenciamento e em breve será disponibilizada.", style="font-size: 16px; color: #666;")
                          )
                 ),
                 tabPanel("Provisório (Sem PNCP)",
                          div(style = "padding-top: 20px;",
                              div(style = "background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);", 
                                  tags$h4("Contratos Pendentes de PNCP Padrão", style="font-weight: bold; color: #dc3545; margin-bottom: 20px;"),
                                  tags$p("Abaixo estão listados apenas os contratos (já presentes na aba principal) que ainda não possuem a numeração extensa e definitiva do Portal Nacional de Compras Públicas.", style="color: #666; font-size: 14px;"),
                                  withSpinner(DTOutput("tabela_sem_pncp"), type = 4, color = "#dc3545")
                              )
                          )
             ),
             tabPanel(title = "Fiscais de Contratos",
                      div(style = "padding-top: 20px;",
                          div(style = "background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);", 
                              tags$h4("Relação de Fiscais e Contratos", style="font-weight: bold; color: #082358; margin-bottom: 5px;"),
                              tags$p("Clique em um fiscal da lista abaixo para visualizar os detalhes dos contratos sob sua responsabilidade.", style="color: #666; font-size: 14px; margin-bottom: 20px;"),
                              withSpinner(DTOutput("tabela_fiscais"), type = 4, color = "#082358")
                          )
                      )
                 )
               ),
               
               tags$div(class = "footer-info",
                        tags$p(tags$b("Elaboração:"), "Secretaria Municipal de Gestão e Planejamento (SEGEP)"),
                        tags$p(tags$b("Fonte:"), "Dados auditados integrados via Portal Nacional de Compras Públicas (PNCP). Prefeitura de Belém, 2026.")
               )
           )
  ),
  
  # =====================================================================
  # ABA SECUNDÁRIA: BI (POWER BI)
  # =====================================================================
  tabPanel("BI (Dashboard)",
           div(style = "text-align: center; padding: 100px 20px; color: #082358;",
               tags$i(class = "fas fa-chart-line", style = "font-size: 80px; margin-bottom: 20px; color: #0084DA;"),
               tags$h2(tags$b("Dashboard Executivo de BI")),
               tags$p("Esta página está reservada para a indexação do painel gerencial de Orçamento e RH.", style="font-size: 18px; color: #666;")
           )
  )
))

# 3. MOTOR DO SISTEMA (Server)
server <- function(input, output, session) {
  
  # Validador de Login
  res_auth <- secure_server(check_credentials = check_credentials(credenciais))

  # --- DICIONÁRIOS GLOBAIS DA PREFEITURA DE BELÉM ---
  mapa_sigla_uasg <- c(
    "PMB" = "925387", "ARBEL" = "927833", "GAB. P." = "927398", "GAB. V." = "N. TEM",
    "CODEM" = "926207", "CINBESA" = "930433", "CGM" = "928343", "FVSOL" = "929164",
    "FUNPAPA" = "930668", "FMAS" = "N. TEM", "GMB" = "930666", "BELEMPREV" = "925390",
    "IASB" = "925389", "OGM" = "930279", "PGM" = "930671", "PROMABEN" = "N. TEM",
    "SEGEP" = "927970", "SEMEC" = "926381", "SESMA" = "926219", "SEZEL" = "930676",
    "SEDCON" = "926322", "SEINFRA" = "925905", "SEHAB" = "930673", "SEMMA" = "931048",
    "SEMCULT" = "927440", "SEMEL" = "926313", "SEGOV" = "929728", "SEFIN" = "929350",
    "SEMCAD" = "N. TEM", "SEPDA" = "933120", "SECOM" = "933075", "SEGBEL" = "932950",
    "SEMU" = "932857", "SEMIAC" = "N. TEM", "SEAPE" = "933080", "SEMTE" = "932961"
  )
  
  mapa_cnpj_sigla <- c(
    "05055009000113" = "PMB", "19670696000191" = "ARBEL", "30513019000100" = "GAB. P.", "07303818000122" = "GAB. V.",
    "04977583000166" = "CODEM", "04850095000193" = "CINBESA", "09551008000110" = "CGM", "21700218000129" = "FVSOL",
    "05065644000181" = "FUNPAPA", "14684151000110" = "FMAS", "49159407000155" = "GMB", "29331615000182" = "BELEMPREV",
    "29331512000112" = "IASB", "11536671000198" = "OGM", "14098990000157" = "PGM", "05055009001004" = "PROMABEN",
    "14700173000127" = "SEGEP", "05055033000152" = "SEMEC", "07917818000112" = "SESMA", "04789822000154" = "SEZEL",
    "10245579000106" = "SEDCON", "05055041000107" = "SEINFRA", "02346546000124" = "SEHAB", "05544392000173" = "SEMMA",
    "06066036000154" = "SEMCULT", "09453989000163" = "SEMEL", "05055017000160" = "SEGOV", "05055025000106" = "SEFIN",
    "53506046000143" = "SEMCAD", "54305300000108" = "SEPDA", "59693965000150" = "SECOM", "59815458000141" = "SEGBEL",
    "59870569000150" = "SEMU", "59631344000141" = "SEMIAC", "59819427000169" = "SEAPE", "59927733000119" = "SEMTE"
  )
  
  # --- PLANILHA MESTRA DOS 31 CONTRATOS DA SEGEP ---
  # MODALIDADES CORRIGIDAS DE ACORDO COM A LEI DE LICITAÇÕES
  segep_master <- data.frame(
    proc = c("159/2025", "478/2019", "157/2025", "093/2023", "250/2023", "150/2023", "430/2023", "417/2024", "366/2025", "450/2025", "490/2025", "503/2025", "349/2025", "740/2025", "813/2025", "744/2025", "749/2025", "1282/2025", "1248/2025", "1287/2025", "1279/2025", "1336/2025", "1349/2025", "1354/2025", "1350/2025", "943/2025", "1232/2025", "63/2026", "1470/2025", "287/2026", "662/2026"),
    cont = c("02/2021", "04/2022", "028/2022", "06/2023", "07/2023", "013/2023", "015/2023", "018/2024", "02/2025", "03/2025", "04/2025", "05/2025", "06/2025", "07/2025", "08/2025", "09/2025", "10/2025", "11/2025", "12/2025", "13/2025", "14/2025", "15/2025", "16/2025", "17/2025", "18/2025", "19/2025", "20/2025", "02/2026", "02/2026", "03/2026", "04/2026"),
    emp = c("CLARO BRASIL S/A", "3I COMÉRCIO", "TICKET SOLUÇÕES", "NORTE TURISMO", "M.C XERFAN", "NC COMÉRCIO", "CLARO S/A", "BANCO DO BRASIL", "EXTRA DISTRIBUIDORA", "Y M GORAYEB", "LUMA COMÉRCIO", "STAR COMÉRCIO", "MAC COPIADORA", "SPLIT SERVICE", "JULIAN GRAZIANO", "COSTA E PAES", "COVEZI CAMINHÕES", "PRM COMERCIO", "VANGUARDA INFORMATICA", "ALLOY COMÉRCIO", "BELÉM RIO SEGURANÇA", "LOCDESK LOCAÇÃO", "IURI RIBEIRO", "BDR COMÉRCIO", "BELÉM RIO SEGURANÇA", "PONTES COMÉRCIO", "BAUHAUS PROJECT", "IMPRENSA NACIONAL", "INSTITUTO AQUILA", "NP TECNOLOGIA", "PONTES COMÉRCIO"),
    val = c(1548673.76, 106639.20, 14146958.66, 145134.00, 400411.25, 103601.86, 8001.60, 204.00, 5700.00, 1320.00, 1700.00, 4437.50, 21640.00, 844561.00, 13080774.58, 32160.00, 1600000.00, 474740.00, 294094.02, 119500.00, 369339.48, 98140.56, 300641.04, 20560.00, 738678.96, 139152.00, 8474440.10, 64559.71, 4693260.00, 32730.00, 160800.00),
    vig = as.Date(c("2026-05-17", "2026-06-20", "2026-09-30", "2027-03-24", "2026-05-26", "2026-06-30", "2026-08-30", "2026-10-02", "2026-04-16", "2026-04-25", "2026-05-20", "2026-05-20", "2026-07-01", "2026-07-21", "2026-07-28", "2026-08-12", "2026-10-17", "2026-10-21", "2026-04-21", "2026-10-21", "2026-10-28", "2026-11-06", "2026-11-25", "2026-11-25", "2026-11-25", "2026-11-25", "2026-12-04", "2027-02-10", "2027-02-27", "2027-06-23", "2027-04-14")),
    srp = c("SIM", "SIM", "SIM", "SIM", "SIM", "SIM", "NÃO", "NÃO", "SIM", "SIM", "SIM", "SIM", "SIM", "SIM", "SIM", "SIM", "NÃO", "NÃO", "SIM", "NÃO", "NÃO", "NÃO", "NÃO", "NÃO", "NÃO", "SIM", "SIM", "NÃO", "NÃO", "NÃO", "SIM"),
    mod = c("Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Dispensa de Licitação", "Dispensa de Licitação", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Pregão Eletrônico", "Inexigibilidade", "Inexigibilidade", "Inexigibilidade", "Pregão Eletrônico")
  )
  
  # --- FUNÇÃO EXTRATORA DE MODALIDADE ---
  extrair_modalidade <- function(df) {
    cols <- names(df)
    mod <- rep("Não Informada", nrow(df))
    if("modalidadeLicitacaoNome" %in% cols) mod <- df$modalidadeLicitacaoNome
    else if("modalidadeNome" %in% cols) mod <- df$modalidadeNome
    else if("amparoLegalNome" %in% cols) mod <- df$amparoLegalNome
    else if("amparoLegal" %in% cols) mod <- df$amparoLegal
    else if("fundamentoLegal" %in% cols) mod <- df$fundamentoLegal
    else {
      idx_mod <- grep("modalidade.*nome|amparo.*nome|fundamento", cols, ignore.case = TRUE)
      if(length(idx_mod) > 0) mod <- df[[idx_mod[1]]]
    }
    mod[is.na(mod) | mod == "" | mod == "N/A"] <- "Não Informada"
    return(mod)
  }
  
  # --- FUNÇÃO PADRONIZADORA GLOBAL DE SECRETARIAS/UASG ---
  padronizar_secretaria <- function(df) {
    if(!("SECRETARIA" %in% names(df))) df$SECRETARIA <- "Outros Órgãos"
    cnpjs <- rep(NA, nrow(df))
    if("CNPJ" %in% names(df)) cnpjs <- gsub("[^0-9]", "", df$CNPJ)
    if("NUMERODECONTROLEPNCP" %in% names(df)) {
      cnpjs <- ifelse(is.na(cnpjs) | cnpjs == "", substr(df$NUMERODECONTROLEPNCP, 1, 14), cnpjs)
    }
    
    for(i in 1:nrow(df)) {
      c <- cnpjs[i]
      if(!is.na(c) && c %in% names(mapa_cnpj_sigla)) {
        df$SECRETARIA[i] <- mapa_cnpj_sigla[[c]]
      } else {
        sec_atual <- toupper(df$SECRETARIA[i])
        for(sigla in names(mapa_sigla_uasg)) {
          if(grepl(paste0("\\b", sigla, "\\b"), sec_atual) || sigla == sec_atual) {
            df$SECRETARIA[i] <- sigla
            break
          }
        }
      }
    }
    
    df$SECRETARIA <- sapply(df$SECRETARIA, function(x) {
      if(is.na(x) || x == "A Definir" || x == "Outros Órgãos") return("Outros Órgãos")
      if(grepl("UASG", x)) return(x)
      if(x %in% names(mapa_sigla_uasg)) {
        uasg <- mapa_sigla_uasg[[x]]
        if(uasg == "N. TEM") return(paste0(x, " (Sem UASG)"))
        return(paste0(x, " (UASG: ", uasg, ")"))
      }
      return(paste0(x, " (Outros)"))
    }, USE.NAMES = FALSE)
    return(df)
  }
  
  # --- CARREGAMENTO DAS BASES E LÓGICA ---
  base_contratos <- reactive({ 
    df <- dbGetQuery(pool, 'SELECT * FROM "VW_GERAL_CONTRATOS"') 
    
    # Padroniza colunas em CAIXA ALTA
    if("NUMERODECONTROLEPNCP" %in% names(df)) names(df)[names(df) == "NUMERODECONTROLEPNCP"] <- "N PNCP"
    if("É ATA/SRP?" %in% names(df)) names(df)[names(df) == "É ATA/SRP?"] <- "SRP"
    if("NÚMERO DA ATA" %in% names(df)) names(df)[names(df) == "NÚMERO DA ATA"] <- "ATA"
    if("QTD DE ADITIVOS" %in% names(df)) names(df)[names(df) == "QTD DE ADITIVOS"] <- "ADITIVOS"
    if("VIGÊNCIA (VER CÉLULA)" %in% names(df)) names(df)[names(df) == "VIGÊNCIA (VER CÉLULA)"] <- "VIGÊNCIA"
    if("VALOR (VER CÉLULA)" %in% names(df)) names(df)[names(df) == "VALOR (VER CÉLULA)"] <- "VALOR"
    if("FAROL DE VIGÊNCIA" %in% names(df)) {
      names(df)[names(df) == "FAROL DE VIGÊNCIA"] <- "FAROL"
      df$FAROL <- gsub("VERMELHO \\(|LARANJA \\(|AMARELO \\(|AZUL \\(|VERDE \\(|\\)", "", df$FAROL)
    }
    
    # Antiduplicidade
    if("ATA" %in% names(df) && "CONTRATO" %in% names(df)) {
      df$ATA <- ave(as.character(df$ATA), paste(df$CONTRATO, df$EMPRESA), FUN = function(x) {
        atas_unicas <- unique(x[!is.na(x) & x != "N/A" & trimws(x) != ""])
        if(length(atas_unicas) == 0) return("N/A")
        paste(atas_unicas, collapse = " | ")
      })
    }
    df <- df[!duplicated(df[, c("CONTRATO", "EMPRESA")]), ]
    df$MODALIDADE <- extrair_modalidade(df)
    
    # UASG
    names(df)[names(df) == "N PNCP"] <- "NUMERODECONTROLEPNCP"
    df <- padronizar_secretaria(df)
    names(df)[names(df) == "NUMERODECONTROLEPNCP"] <- "N PNCP"
    
    # Injeção SEGEP
    for(i in 1:nrow(segep_master)) {
      p <- segep_master$proc[i]
      c <- segep_master$cont[i]
      
      idx <- which(grepl(p, df$`Processo ORIGINAL do GDOC`, fixed=T) | 
                     grepl(p, df$`N PNCP`, fixed=T) |
                     (grepl(c, df$CONTRATO, fixed=T) & grepl(segep_master$emp[i], df$EMPRESA, ignore.case=T)))
      
      if(length(idx) > 0) {
        df$SECRETARIA[idx] <- "SEGEP (UASG: 927970)"
        df$`N PNCP`[idx] <- ifelse(is.na(df$`N PNCP`[idx]) | df$`N PNCP`[idx] == "", p, df$`N PNCP`[idx])
        # Pega a modalidade da planilha apenas se a base oficial SQL estiver em branco
        df$MODALIDADE[idx] <- ifelse(df$MODALIDADE[idx] == "Não Informada", segep_master$mod[i], df$MODALIDADE[idx])
      } else {
        dias_rest <- as.numeric(segep_master$vig[i] - Sys.Date())
        farol_calc <- ifelse(dias_rest < 0, "Vencido",
                             ifelse(dias_rest <= 30, "Até 30 Dias",
                                    ifelse(dias_rest <= 90, "Até 3 Meses",
                                           ifelse(dias_rest <= 150, "Até 5 Meses", "Mais de 5 Meses"))))
        
        nova_linha <- data.frame(
          "ID" = 9999,
          "N PNCP" = p, 
          "FAROL" = farol_calc,
          "CONTRATO" = c,
          "EMPRESA" = segep_master$emp[i],
          "Processo ORIGINAL do GDOC" = p,
          "Processo do pagamento" = as.character(NA),
          "OBJETO" = "Inserido via Planilha SEGEP",
          "NÚMERO DE ITENS" = 0,
          "CNPJ" = "14.700.173/0001-27",
          "SECRETARIA" = "SEGEP (UASG: 927970)",
          "SRP" = segep_master$srp[i],
          "ATA" = as.character(NA),
          "TEVE ADITIVO?" = "NÃO",
          "ADITIVOS" = 0,
          "VIGÊNCIA" = format(segep_master$vig[i], "%d/%m/%Y"),
          "VALOR" = paste0("R$ ", formatC(segep_master$val[i], format="f", big.mark=".", decimal.mark=",", digits=2)),
          "VIGÊNCIA (DATA CALC)" = segep_master$vig[i],
          "VALOR (SOMA CALC)" = segep_master$val[i],
          "DIAS RESTANTES" = dias_rest,
          "MODALIDADE" = segep_master$mod[i],
          check.names = FALSE, stringsAsFactors = FALSE
        )
        df <- rbind(df, nova_linha)
      }
    }
    
    # 🛑 TRAVA LÓGICA DE SRP: Conserta os erros de digitação do PNCP
    if("SRP" %in% names(df) && "MODALIDADE" %in% names(df)) {
      df$SRP <- ifelse(
        grepl("SRP|REGISTRO DE PREÇO", df$MODALIDADE, ignore.case = TRUE) & df$SRP == "NÃO",
        "SIM", 
        df$SRP
      )
    }
    
    return(df)
  })
  
  base_licitacoes <- reactive({
    df <- dbGetQuery(pool, 'SELECT * FROM "LICITACOES1"')
    if("numeroControlePNCP" %in% names(df)) df <- df[!duplicated(df$numeroControlePNCP), ]
    
    df_std <- data.frame(
      SECRETARIA = rep("A Definir", nrow(df)), NUMERODECONTROLEPNCP = df$numeroControlePNCP,
      `FAROL` = "LICITAÇÃO / ATA", CONTRATO = "N/A", EMPRESA = "Em Disputa",
      OBJETO = df$objetoCompra, CNPJ = "N/A", `SRP` = ifelse(df$srp %in% c(TRUE, "true", "t"), "SIM", "NÃO"),
      `ATA` = "N/A", `MODALIDADE` = extrair_modalidade(df), `ADITIVOS` = 0, `VIGÊNCIA` = "N/A", `VALOR` = "N/A",
      check.names = FALSE, stringsAsFactors = FALSE
    )
    
    df_std <- padronizar_secretaria(df_std)
    names(df_std)[names(df_std) == "NUMERODECONTROLEPNCP"] <- "N PNCP"
    
    for(i in 1:nrow(segep_master)) {
      p <- segep_master$proc[i]
      c <- segep_master$cont[i]
      idx <- which(grepl(p, df_std$`N PNCP`, fixed=T))
      
      if(length(idx) > 0) {
        df_std$SECRETARIA[idx] <- "SEGEP (UASG: 927970)"
        df_std$CONTRATO[idx] <- c
        df_std$EMPRESA[idx] <- segep_master$emp[i]
        df_std$`VALOR`[idx] <- paste0("R$ ", formatC(segep_master$val[i], format="f", big.mark=".", decimal.mark=",", digits=2))
        df_std$MODALIDADE[idx] <- ifelse(df_std$MODALIDADE[idx] == "Não Informada", segep_master$mod[i], df_std$MODALIDADE[idx])
      } else {
        nova_linha <- data.frame(
          SECRETARIA = "SEGEP (UASG: 927970)", `N PNCP` = p,
          `FAROL` = "LICITAÇÃO / ATA", CONTRATO = c, EMPRESA = segep_master$emp[i],
          OBJETO = "Processo Licitatório", CNPJ = "N/A", `SRP` = segep_master$srp[i],
          `ATA` = "N/A", `MODALIDADE` = segep_master$mod[i], `ADITIVOS` = 0, `VIGÊNCIA` = "N/A", `VALOR` = paste0("R$ ", formatC(segep_master$val[i], format="f", big.mark=".", decimal.mark=",", digits=2)),
          check.names = FALSE, stringsAsFactors = FALSE
        )
        df_std <- rbind(df_std, nova_linha)
      }
    }
    
    if("SRP" %in% names(df_std) && "MODALIDADE" %in% names(df_std)) {
      df_std$SRP <- ifelse(grepl("SRP|REGISTRO DE PREÇO", df_std$MODALIDADE, ignore.case = TRUE) & df_std$SRP == "NÃO", "SIM", df_std$SRP)
    }
    return(df_std)
  })
  
  base_atas <- reactive({
    df <- dbGetQuery(pool, 'SELECT * FROM "ATAS1"')
    if("numeroControlePNCP" %in% names(df)) df <- df[!duplicated(df$numeroControlePNCP), ]
    
    df_std <- data.frame(
      SECRETARIA = rep("A Definir", nrow(df)), NUMERODECONTROLEPNCP = df$numeroControlePNCP,
      `FAROL` = "LICITAÇÃO / ATA", CONTRATO = "N/A", EMPRESA = "N/A",
      OBJETO = "Documento de Ata Registrado", CNPJ = "N/A", `SRP` = "SIM",
      `ATA` = df$numeroAtaRegistroPreco, `MODALIDADE` = extrair_modalidade(df), `ADITIVOS` = 0, `VIGÊNCIA` = "N/A", `VALOR` = "N/A",
      check.names = FALSE, stringsAsFactors = FALSE
    )
    
    df_std <- padronizar_secretaria(df_std)
    names(df_std)[names(df_std) == "NUMERODECONTROLEPNCP"] <- "N PNCP"
    return(df_std)
  })
  
  # --- 3. FILTROS E EVENTOS GLOBAIS ---
  observe({
    todas_sec <- unique(c(base_contratos()$SECRETARIA, base_licitacoes()$SECRETARIA, base_atas()$SECRETARIA))
    opcoes_secretaria <- c("Todas", sort(todas_sec[!is.na(todas_sec)]))
    sel <- ifelse(any(grepl("SEGEP", opcoes_secretaria)), opcoes_secretaria[grepl("SEGEP", opcoes_secretaria)][1], "Todas")
    updateSelectInput(session, "filtro_secretaria", choices = opcoes_secretaria, selected = sel)
  })
  
  observeEvent(input$click_farol, {
    updateSelectInput(session, "filtro_farol", selected = input$click_farol)
  })
  
  aplicar_filtros <- function(df) {
    if(nrow(df) == 0) return(df)
    if(input$filtro_ano != "Todos") {
      df <- df[grepl(paste0("/", input$filtro_ano), df$CONTRATO) | grepl(paste0("/", input$filtro_ano), df$`N PNCP`), ]
    }
    if(input$filtro_secretaria != "Todas" && input$filtro_secretaria != "Carregando...") df <- df[df$SECRETARIA == input$filtro_secretaria, ]
    if(input$filtro_farol != "Todos") df <- df[df$FAROL == input$filtro_farol, ]
    if(input$filtro_ata != "Todos") df <- df[df$SRP == input$filtro_ata, ]
    if(input$pesquisa_livre != "") {
      matches <- apply(df, 1, function(row) any(grepl(input$pesquisa_livre, row, ignore.case = TRUE)))
      df <- df[matches, ]
    }
    return(df)
  }
  
  dados_contratos_filt <- reactive({ aplicar_filtros(base_contratos()) })
  dados_licitacoes_filt <- reactive({ aplicar_filtros(base_licitacoes()) })
  dados_atas_filt <- reactive({ aplicar_filtros(base_atas()) })
  
  dados_sem_pncp <- reactive({
    df <- dados_contratos_filt()
    # Filtra os contratos cujo número não possui o hífen característico do padrão longo do PNCP
    df[is.na(df$`N PNCP`) | !grepl("-", df$`N PNCP`), ]
  })
  
  # --- 4. KPIs ---
  output$kpi_total <- renderUI({ 
    HTML(paste0('<div class="kpi-card kpi-card-noclick" style="border-bottom-color: #082358;">
                  <div class="kpi-title"><i class="fas fa-file-contract"></i> Total de Contratos</div>
                  <div class="kpi-value">', nrow(dados_contratos_filt()), '</div></div>')) 
  })
  output$kpi_valor <- renderUI({ 
    soma <- sum(as.numeric(dados_contratos_filt()$`VALOR (SOMA CALC)`), na.rm = TRUE)
    HTML(paste0('<div class="kpi-card kpi-card-noclick" style="border-bottom-color: #4FAF47;">
                  <div class="kpi-title"><i class="fas fa-dollar-sign"></i> Valor Acumulado</div>
                  <div class="kpi-value" style="color: #4FAF47;">R$ ', formatC(soma, format="f", big.mark=".", decimal.mark=",", digits=2), '</div></div>')) 
  })
  output$kpi_verde <- renderUI({ HTML(paste0('<div class="kpi-card" style="border-bottom-color: #28a745;" onclick="Shiny.setInputValue(\'click_farol\', \'Mais de 5 Meses\', {priority: \'event\'});"><div class="kpi-title">Mais de 5 Meses</div><div class="kpi-value" style="color:#28a745;">', sum(dados_contratos_filt()$FAROL == "Mais de 5 Meses", na.rm = TRUE), '</div></div>')) })
  output$kpi_azul <- renderUI({ HTML(paste0('<div class="kpi-card" style="border-bottom-color: #17a2b8;" onclick="Shiny.setInputValue(\'click_farol\', \'Até 5 Meses\', {priority: \'event\'});"><div class="kpi-title">Até 5 Meses</div><div class="kpi-value" style="color:#17a2b8;">', sum(dados_contratos_filt()$FAROL == "Até 5 Meses", na.rm = TRUE), '</div></div>')) })
  output$kpi_amarelo <- renderUI({ HTML(paste0('<div class="kpi-card" style="border-bottom-color: #ffc107;" onclick="Shiny.setInputValue(\'click_farol\', \'Até 3 Meses\', {priority: \'event\'});"><div class="kpi-title">Até 3 Meses</div><div class="kpi-value" style="color:#d39e00;">', sum(dados_contratos_filt()$FAROL == "Até 3 Meses", na.rm = TRUE), '</div></div>')) })
  output$kpi_laranja <- renderUI({ HTML(paste0('<div class="kpi-card" style="border-bottom-color: #fd7e14;" onclick="Shiny.setInputValue(\'click_farol\', \'Até 30 Dias\', {priority: \'event\'});"><div class="kpi-title">Até 30 Dias</div><div class="kpi-value" style="color:#fd7e14;">', sum(dados_contratos_filt()$FAROL == "Até 30 Dias", na.rm = TRUE), '</div></div>')) })
  output$kpi_vermelho <- renderUI({ HTML(paste0('<div class="kpi-card" style="border-bottom-color: #dc3545;" onclick="Shiny.setInputValue(\'click_farol\', \'Vencido\', {priority: \'event\'});"><div class="kpi-title">Vencidos</div><div class="kpi-value" style="color:#dc3545;">', sum(dados_contratos_filt()$FAROL == "Vencido", na.rm = TRUE), '</div></div>')) })
  
  output$kpi_lic_total <- renderUI({ HTML(paste0('<div class="kpi-card kpi-card-noclick" style="border-bottom-color: #082358; margin-bottom:20px; max-width:300px;"><div class="kpi-title"><i class="fas fa-bullhorn"></i> Total de Contratações</div><div class="kpi-value">', nrow(dados_licitacoes_filt()), '</div></div>')) })
  output$kpi_atas_total <- renderUI({ HTML(paste0('<div class="kpi-card kpi-card-noclick" style="border-bottom-color: #082358; margin-bottom:20px; max-width:300px;"><div class="kpi-title"><i class="fas fa-file-signature"></i> Total de Atas</div><div class="kpi-value">', nrow(dados_atas_filt()), '</div></div>')) })
  
  # --- 5. FUNÇÃO GLOBAL PARA RENDERIZAR AS TABELAS PADRÃO ---
  gerar_tabela_padrao <- function(df_mostrar, tipo_aba = "contrato") {
    
    # Adicionado colunas em CAIXA ALTA
    df_mostrar <- df_mostrar[, c("SECRETARIA", "N PNCP", "FAROL", "CONTRATO", "EMPRESA", "OBJETO", "CNPJ", "SRP", "ATA", "MODALIDADE", "ADITIVOS", "VIGÊNCIA", "VALOR")]
    
    df_mostrar$`N PNCP` <- sapply(df_mostrar$`N PNCP`, function(x) {
      if (is.na(x) || x == "") return(x)
      url_encoded <- URLencode(trimws(x), reserved = TRUE)
      url <- ifelse(tipo_aba == "licitacao", 
                    paste0("https://pncp.gov.br/app/editais?q=", url_encoded, "&pagina=1&status=todos"),
                    paste0("https://pncp.gov.br/app/contratos?q=", url_encoded, "&pagina=1&status=todos"))
      paste0('<a href="', url, '" target="_blank" style="color: inherit; font-weight: bold; text-decoration: underline;">', x, ' <i class="fas fa-external-link-alt" style="font-size:10px;"></i></a>')
    })
    
    datatable(df_mostrar, escape = FALSE, selection = 'none', 
              options = list(pageLength = 15, scrollX = TRUE, autoWidth = TRUE, dom = 'rtip', language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Portuguese-Brasil.json'),
                             columnDefs = list(
                               # Colunas centralizadas por padrão
                               list(targets = c(0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12), className = 'dt-center'),
                               # Coluna 5 (OBJETO) recebe a classe dt-justify para justificar o texto igual no Word
                               list(targets = 5, className = 'dt-justify'),
                               list(targets = 6, className = 'cnpj-col dt-center')
                             )), 
              rownames = FALSE, class = 'cell-border hover compact') %>%
      formatStyle(columns = names(df_mostrar), valueColumns = 'FAROL', 
                  backgroundColor = styleEqual(c('Vencido', 'Até 30 Dias', 'Até 3 Meses', 'Até 5 Meses', 'Mais de 5 Meses', 'LICITAÇÃO / ATA'), c('#f8d7da', '#ffe8cc', '#fff3cd', '#cce5ff', '#d4edda', '#e2e3e5')), 
                  color = styleEqual(c('Vencido', 'Até 30 Dias', 'Até 3 Meses', 'Até 5 Meses', 'Mais de 5 Meses', 'LICITAÇÃO / ATA'), c('#721c24', '#856404', '#856404', '#004085', '#155724', '#383d41'))) %>%
      formatStyle('FAROL', fontWeight = 'bold')
  }
  
  output$tabela_mestre <- renderDT({ gerar_tabela_padrao(dados_contratos_filt(), tipo_aba = "contrato") })
  output$tabela_licitacoes <- renderDT({ gerar_tabela_padrao(dados_licitacoes_filt(), tipo_aba = "licitacao") })
  output$tabela_atas <- renderDT({ gerar_tabela_padrao(dados_atas_filt(), tipo_aba = "contrato") })
  output$tabela_sem_pncp <- renderDT({ gerar_tabela_padrao(dados_sem_pncp(), tipo_aba = "contrato") })
  
  # --- 6. MÓDULO DE FISCAIS (CARREGAMENTO DO POSTGRESQL) ---
  dados_fiscais_tratados <- reactive({
    tryCatch({
      # Lê a tabela do banco
      df <- dbGetQuery(pool, 'SELECT * FROM "FISCAIS"')
      
      if(nrow(df) == 0) return(data.frame(ERRO = "A tabela FISCAIS está vazia no banco.", stringsAsFactors = FALSE))
      
      nomes_limpos <- trimws(toupper(names(df)))
      
      # Função auxiliar para pegar a coluna pela palavra-chave
      get_col <- function(pattern) {
        idx <- grep(pattern, nomes_limpos)
        if(length(idx) > 0) return(as.character(df[[idx[1]]]))
        return(rep("Não Informado", nrow(df)))
      }
      
      # Usando nomes seguros para evitar falhas silenciosas de parser no R com acentos/espaços
      df_clean <- data.frame(
        PROCESSO = get_col("PROCESSO"),
        CONTRATO = get_col("CONTRATO"),
        OBJETO = get_col("OBJETO"),
        FISCAL = get_col("FISCAL"),
        SUPLENTE = get_col("SUPLENTE"),
        PORTARIA = get_col("PORTARIA"),
        ADITIVOS = get_col("ADITIVO"),
        stringsAsFactors = FALSE
      )
      
      # Limpeza de NAs nos nomes e Padronização (Tudo Maiúsculo)
      df_clean$FISCAL <- toupper(trimws(as.character(df_clean$FISCAL)))
      df_clean$SUPLENTE <- toupper(trimws(as.character(df_clean$SUPLENTE)))
      
      df_clean$FISCAL[is.na(df_clean$FISCAL) | df_clean$FISCAL == ""] <- "NÃO INFORMADO"
      df_clean$SUPLENTE[is.na(df_clean$SUPLENTE) | df_clean$SUPLENTE == ""] <- "NÃO INFORMADO"
      
      # Vigência
      idx_vig <- grep("VIGÊNCIA|VIGENCIA", nomes_limpos)
      fim_vig <- if(length(idx_vig) >= 2) df[[idx_vig[2]]] else if(ncol(df)>=9) df[[9]] else rep(NA, nrow(df))
      
      # Formatação segura de datas removendo horas/timestamps se existirem
      fim_vig_char <- as.character(fim_vig)
      fim_vig_char <- gsub(" [0-9]{2}:[0-9]{2}:[0-9]{2}.*", "", fim_vig_char)
      fim_vig_date <- suppressWarnings(as.Date(fim_vig_char, tryFormats = c("%Y-%m-%d", "%d/%m/%Y", "%Y/%m/%d")))
      
      dias_rest <- as.numeric(fim_vig_date - Sys.Date())
      
      df_clean$FAROL <- ifelse(is.na(dias_rest), "Sem Data",
                               ifelse(dias_rest < 0, "Vencido",
                               ifelse(dias_rest <= 30, "Até 30 Dias",
                               ifelse(dias_rest <= 90, "Até 3 Meses",
                               ifelse(dias_rest <= 150, "Até 5 Meses", "Mais de 5 Meses")))))
                               
      df_clean$VIGENCIA <- ifelse(is.na(fim_vig_date), "Sem Data", format(fim_vig_date, "%d/%m/%Y"))
      
      # Anti-apagão robusto: Evita deletar contratos que não possuem número de processo cadastrado
      # Remove as duplicidades apenas das linhas que possuem um Processo válido e preenchido
      is_valid_proc <- df_clean$PROCESSO != "Não Informado" & !is.na(df_clean$PROCESSO) & trimws(df_clean$PROCESSO) != ""
      df_clean <- df_clean[!is_valid_proc | !duplicated(df_clean$PROCESSO), ]
      
      # Aplica os nomes visuais exigidos
      names(df_clean) <- c("NÚMERO DO PROCESSO", "N DO CONTRATO", "OBJETO", "FISCAL DO CONTRATO", "SUPLENTE", "PORTARIA DE DESIGNAÇÃO", "ADITIVOS", "FAROL", "VIGÊNCIA")
      
      return(df_clean)
    }, error = function(e) {
      return(data.frame(ERRO = paste("Falha interna:", e$message), stringsAsFactors = FALSE))
    })
  })

  # Renderiza a Tabela Principal (Apenas 3 Colunas)
  output$tabela_fiscais <- renderDT({
    df_full <- dados_fiscais_tratados()
    if (is.null(df_full) || nrow(df_full) == 0) {
      return(datatable(data.frame(Aviso = "Nenhum fiscal encontrado ou erro na tabela. Importe os dados novamente."), rownames = FALSE))
    }
    # Se houver uma falha, agora ele vai mostrar exatamente o que ocorreu na tela para nós!
    if ("ERRO" %in% names(df_full)) {
      return(datatable(data.frame(Aviso = df_full$ERRO[1]), rownames = FALSE))
    }
    
    # Contagem absolutamente segura de Fiscais usando a função nativa 'table' do R
    agg_data <- as.data.frame(table(
      Fiscal = as.character(df_full[["FISCAL DO CONTRATO"]])
    ))
    
    # Mantém apenas as combinações reais
    agg_data <- agg_data[agg_data$Freq > 0, ]
    names(agg_data) <- c("FISCAL DOS CONTRATOS", "QUANTIDADE DE CONTRATOS")
    
    # Adiciona a data de atualização estática solicitada
    agg_data[["DATA DA ATUALIZAÇÃO"]] <- "14/05/2026"
    
    # Ordena pelo nome do Fiscal
    agg_data <- agg_data[order(agg_data[["FISCAL DOS CONTRATOS"]]), ]
    
    datatable(agg_data, 
              selection = 'single', # Habilita seleção de apenas 1 linha para acionar o modal
              rownames = FALSE, 
              width = '100%', # Força a tabela a ocupar todo o espaço lateral
              class = 'cell-border hover stripe',
              options = list(
                pageLength = 15, scrollX = TRUE, autoWidth = FALSE, dom = 'frtip', 
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Portuguese-Brasil.json'),
                columnDefs = list(list(targets = '_all', className = 'dt-center'))
              )) %>%
      formatStyle(columns = names(agg_data), fontSize = '14px', padding = '10px') %>%
      formatStyle('FISCAL DOS CONTRATOS', fontWeight = 'bold', color = '#082358') %>%
      formatStyle('QUANTIDADE DE CONTRATOS', fontWeight = 'bold', backgroundColor = '#eef4f8', color = '#0084DA')
  })
  
  # Lógica do clique (Abertura do Modal/Pop-up)
  observeEvent(input$tabela_fiscais_rows_selected, {
    selected_row <- input$tabela_fiscais_rows_selected
    df_full <- dados_fiscais_tratados()
    
    if (!is.null(df_full) && !("ERRO" %in% names(df_full)) && length(selected_row) > 0) {
      # Recria o agrupamento exato para puxar o nome correto da linha clicada
      agg_data <- as.data.frame(table(
        Fiscal = as.character(df_full[["FISCAL DO CONTRATO"]])
      ))
      agg_data <- agg_data[agg_data$Freq > 0, ]
      names(agg_data) <- c("FISCAL DOS CONTRATOS", "QUANTIDADE DE CONTRATOS")
      agg_data <- agg_data[order(agg_data[["FISCAL DOS CONTRATOS"]]), ]
      
      fiscal_clicado <- agg_data[selected_row, "FISCAL DOS CONTRATOS"]
      
      # Filtra a base completa pelos contratos desse fiscal específico
      df_modal <- df_full[df_full[["FISCAL DO CONTRATO"]] == fiscal_clicado, ]
      df_modal <- df_modal[, c("N DO CONTRATO", "NÚMERO DO PROCESSO", "FAROL", "OBJETO", "SUPLENTE", "PORTARIA DE DESIGNAÇÃO", "ADITIVOS", "VIGÊNCIA")]
      
      # Exibe o Pop-up
      showModal(modalDialog(
        title = HTML(paste0("<div style='color: #082358; font-weight: bold; font-size: 22px;'><i class='fas fa-id-badge'></i> Painel de Fiscalização: ", fiscal_clicado, "</div>")),
        size = "xl", # Tamanho extra grande do Shiny
        easyClose = TRUE, fade = TRUE,
        footer = modalButton("Fechar Janela"),
        div(style = "margin-top: 15px; border-top: 3px solid #0084DA; padding-top: 15px;",
            renderDT({
              datatable(df_modal, escape = FALSE, selection = 'none', rownames = FALSE, 
                        width = '100%',
                        class = 'cell-border hover compact',
                        options = list(
                          pageLength = 10, scrollX = TRUE, autoWidth = FALSE, dom = 'rtip', 
                          language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Portuguese-Brasil.json'),
                          columnDefs = list(
                            list(targets = c(0, 1, 2, 4, 5, 6, 7), className = 'dt-center'),
                            list(targets = 3, className = 'dt-justify') # Justifica o texto do Objeto
                          )
                        )) %>%
                formatStyle(columns = names(df_modal), valueColumns = 'FAROL', 
                            backgroundColor = styleEqual(c('Vencido', 'Até 30 Dias', 'Até 3 Meses', 'Até 5 Meses', 'Mais de 5 Meses', 'Sem Data'), 
                                                         c('#f8d7da', '#ffe8cc', '#fff3cd', '#cce5ff', '#d4edda', '#e2e3e5')), 
                            color = styleEqual(c('Vencido', 'Até 30 Dias', 'Até 3 Meses', 'Até 5 Meses', 'Mais de 5 Meses', 'Sem Data'), 
                                               c('#721c24', '#856404', '#856404', '#004085', '#155724', '#383d41'))) %>%
                formatStyle('FAROL', fontWeight = 'bold')
            })
        )
      ))
    }
  })

}

runApp(shinyApp(ui, server), host = "0.0.0.0", port = 5050)