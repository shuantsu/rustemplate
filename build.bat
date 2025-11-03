@echo off
set "RELEASE_DIR=%1"
set "EXE_FILE=" :: Inicializa a variável para o nome do executável

echo Mudando para o diretório de release: %RELEASE_DIR%
cd "%RELEASE_DIR%"

echo Construindo o projeto Rust...
cargo build --release

cd target\release

:: 1. Busca pelo primeiro arquivo .exe e armazena o nome
FOR /F "delims=" %%F IN ('dir /b *.exe 2^>nul') DO (
    set "EXE_FILE=%%F"
    goto :EXECUTA_UPX_COM_SUCESSO
)

:EXECUTA_UPX_COM_SUCESSO
IF NOT DEFINED EXE_FILE (
    echo.
    echo ERRO: Nenhum arquivo .exe encontrado no diretório.
    goto :FIM
)

:: 2. Executa a ação (UPX) fora do loop com o nome encontrado
echo.
echo Executável encontrado: %EXE_FILE%
echo Aplicando UPX (compressão)...
upx --best --lzma "%EXE_FILE%"

:FIM
echo.

echo Concluído com sucesso!
echo.
echo Após a próxima ação, será aberta a pasta da build:
pause

start .
cd ..\..\..