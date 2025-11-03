@echo off
set "ARQUIVO_ALVO=Cargo.toml"
set "CHAVE_BUSCADA=[profile.release]"

:: 1. Navega para o diretório fornecido pelo argumento %1
cd "%1"

echo Verificando se a chave "%CHAVE_BUSCADA%" já existe em %ARQUIVO_ALVO%

:: 2. Usa FINDSTR para buscar a chave
:: O comando 'FINDSTR' retorna um código de erro 0 se encontrar a string.
FINDSTR /I /B /C:"%CHAVE_BUSCADA%" "%ARQUIVO_ALVO%" >nul
IF %ERRORLEVEL% EQU 0 (
    echo.
    echo AVISO: A chave "%CHAVE_BUSCADA%" já foi encontrada. Encerrando o script.
    goto :EOF
)

:: Se a chave NÃO foi encontrada, o script continua aqui
echo.
echo Chave nao encontrada. Adicionando o bloco [profile.release]...
echo.>> "%ARQUIVO_ALVO%"
echo [profile.release]>> "%ARQUIVO_ALVO%"
echo opt-level = "z">> "%ARQUIVO_ALVO%"
echo strip = true>> "%ARQUIVO_ALVO%"
echo lto = true>> "%ARQUIVO_ALVO%"
echo panic = "abort">> "%ARQUIVO_ALVO%"

echo Texto adicionado com sucesso ao %ARQUIVO_ALVO%.

:EOF

cd ..
pause