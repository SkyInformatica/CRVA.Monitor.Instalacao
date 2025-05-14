@echo off
REM Parâmetros: caminho do appsettings, diretorio, email, senha, organizacao, usuario_windows, senha_windows

set "APPSETTINGS=%~1"
set "DIRETORIO=%~2"
set "EMAIL=%~3"
set "SENHA=%~4"
set "ORGANIZACAO=%~5"
set "USUARIO_WINDOWS=%~6"
set "SENHA_WINDOWS=%~7"

powershell -NoProfile -Command ^
    "$json = Get-Content -Raw -Encoding UTF8 '%APPSETTINGS%';" ^
    "$json = $json -replace '\"DIRETORIO_DE_DOCUMENTOS\"', '\"%DIRETORIO%\"';" ^
    "$json = $json -replace '\"EMAIL\"', '\"%EMAIL%\"';" ^
    "$json = $json -replace '\"SENHA\"', '\"%SENHA%\"';" ^
    "$json = $json -replace '\"ORGANIZACAO\"', '\"%ORGANIZACAO%\"';" ^
    "$json = $json -replace '\"USUARIO_WINDOWS\"', '\"%USUARIO_WINDOWS%\"';" ^
    "$json = $json -replace '\"SENHA_WINDOWS\"', '\"%SENHA_WINDOWS%\"';" ^
    "Set-Content -Path '%APPSETTINGS%' -Value $json -Encoding UTF8"
