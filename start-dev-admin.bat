@echo off
:: Verifica se está executando como administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Executando como administrador...
    echo.
    cd /d "%~dp0"
    npm run dev
) else (
    echo Solicitando privilegios de administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)
