@echo off
setlocal enabledelayexpansion

:: =================================================================
:: Script Unificado de Otimizacao, Build e Compressao Rust (UPX)
:: Execucao: rustools.bat --build
:: =================================================================

:: 1. Verificacao de Argumento
if /I not "%~1"=="--build" (
echo.
echo =================================================================
echo ERRO: Argumento '--build' necessario.
echo Uso: rustools.bat --build
echo Este script otimiza o Cargo.toml, compila e comprime o projeto Rust no diretorio atual.
echo =================================================================
pause
goto :FIM_LIMPEZA
)

:: 2. Configuracao de Variaveis
set "ARQUIVO_ALVO=Cargo.toml"
set "CHAVE_BUSCADA=[profile.release]"
set "START_DIR=%CD%"

echo Iniciar script de otimizacao e build. Diretorio atual: %START_DIR%

:: Usa PUSHD para salvar o diretorio atual e garantir o retorno com POPD
pushd . || (echo ERRO: Nao foi possivel salvar o diretorio inicial. & goto :FIM_LIMPEZA)

:: ----------------------------------------------------
:: PARTE 1: Otimizacao do Cargo.toml
:: ----------------------------------------------------
echo.
echo === [ PASSO 1/2: Otimizacao do Cargo.toml ] ===
echo Verificando se a chave "%CHAVE_BUSCADA%" ja existe em %ARQUIVO_ALVO%

:: Busca pela chave para evitar duplicacao
FINDSTR /I /B /C:"%CHAVE_BUSCADA%" "%ARQUIVO_ALVO%" >nul
IF %ERRORLEVEL% EQU 0 (
echo AVISO: A chave "%CHAVE_BUSCADA%" ja foi encontrada. Otimizacao ignorada.
) ELSE (
:: Se a chave NAO foi encontrada, adiciona o bloco
echo Chave nao encontrada. Adicionando bloco de otimizacao para release...
(
echo.
echo %CHAVE_BUSCADA%
echo opt-level = "z"
echo strip = true
echo lto = true
echo panic = "abort"
) >> "%ARQUIVO_ALVO%"
echo Bloco de otimizacao adicionado com sucesso.
)

:: ----------------------------------------------------
:: PARTE 2: Build e Compressao (UPX)
:: ----------------------------------------------------
echo.
echo === [ PASSO 2/2: Build e Compressao (UPX) ] ===

echo Construindo o projeto Rust (cargo build --release)...
cargo build --release
IF %ERRORLEVEL% NEQ 0 (
echo ERRO: Falha na execucao do 'cargo build --release'. Verifique as mensagens acima.
goto :FIM
)

:: Navega para o diretorio de release
cd target\release
IF %ERRORLEVEL% NEQ 0 (
echo ERRO: Diretorio 'target\release' nao encontrado. O build falhou?
goto :FIM
)

set "EXE_FILE="

:: Busca pelo primeiro arquivo .exe encontrado
FOR /F "delims=" %%F IN ('dir /b *.exe 2^>nul') DO (
set "EXE_FILE=%%F"
goto :ENCONTRADO
)

:ENCONTRADO
IF NOT DEFINED EXE_FILE (
echo.
echo ERRO: Nenhum arquivo .exe encontrado no diretorio 'target\release'.
goto :FIM
)

:: Executa a compressao UPX
echo.
echo Executavel encontrado: %EXE_FILE%
echo Aplicando UPX (--best --lzma)...
upx --best --lzma "%EXE_FILE%"
IF %ERRORLEVEL% NEQ 0 (
echo AVISO: UPX falhou ou nao esta instalado. A otimizacao de compressao nao foi aplicada.
)
:: Continua mesmo com erro de UPX, pois o build Rust foi bem sucedido.

:FIM
echo.
echo =================================
echo Processo Concluido!
echo =================================

echo O diretorio de build (target\release) sera aberto.
pause

start .

:FIM_LIMPEZA
:: POPD garante o retorno ao diretorio inicial, mesmo que haja erros anteriores
popd
endlocal
