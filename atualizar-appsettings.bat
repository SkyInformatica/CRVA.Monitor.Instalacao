@echo off
REM Parâmetros: caminho do appsettings, diretorio, email, senha, organizacao, usuario_windows, senha_windows

set "DIRETORIO=%~1"
set "EMAIL=%~2"
set "SENHA=%~3"
set "ORGANIZACAO=%~4"
set "USUARIO_WINDOWS=%~5"
set "SENHA_WINDOWS=%~6"

REM Verifica se o arquivo appsettings.json existe
if not exist "appsettings.json" (
    echo Arquivo appsettings.json não encontrado.
    exit /b 1
)

powershell -NoProfile -Command ^
    "$json = Get-Content -Raw -Encoding UTF8 'appsettings.json';" ^
    "$json = $json -replace '\"DIRETORIO_DE_DOCUMENTOS\"', '\"%DIRETORIO%\"';" ^
    "$json = $json -replace '\"EMAIL\"', '\"%EMAIL%\"';" ^
    "$json = $json -replace '\"SENHA\"', '\"%SENHA%\"';" ^
    "$json = $json -replace '\"ORGANIZACAO\"', '\"%ORGANIZACAO%\"';" ^
    "$json = $json -replace '\"USUARIO_WINDOWS\"', '\"%USUARIO_WINDOWS%\"';" ^
    "$json = $json -replace '\"SENHA_WINDOWS\"', '\"%SENHA_WINDOWS%\"';" ^
    "Set-Content -Path 'appsettings.json' -Value $json -Encoding UTF8"
