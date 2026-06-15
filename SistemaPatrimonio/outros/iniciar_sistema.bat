@echo off
title Servidor - Sistema de Gastos
echo ===================================================
echo INICIANDO O SISTEMA DE GESTAO PATRIMONIAL...
echo ===================================================
echo.
echo Por favor, aguarde. O banco de dados esta sendo conectado.
echo O seu navegador vai abrir automaticamente em instantes...
echo.
echo [AVISO] Nao feche esta janela preta enquanto estiver usando o sistema.

"C:\Program Files\R\R-4.4.2\bin\Rscript.exe" -e "shiny::runApp('C:/Users/fabri/Documents/SistemaPatrimonio', launch.browser=TRUE, host='0.0.0.0')"

exit