@echo off
color 0A
title Instalador do Servidor Remote Control

echo =======================================================
echo    Instalador do Servidor de Controle Remoto (PC)
echo =======================================================
echo.

:: Verifica Permissões de Administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Permissões de Administrador confirmadas.
) else (
    echo [AVISO] O script precisa de permissao de Administrador!
    echo Feche e clique com o botao direito em "Executar como Administrador".
    pause
    exit
)

echo.
echo 1. Verificando instalacao do Python...
python --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Python ja esta instalado!
) else (
    echo [!] Python nao encontrado. Baixando e instalando pelo Winget...
    winget install Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements
    echo [OK] Python instalado com sucesso! Por favor reinicie o arquivo .bat para continuar.
    pause
    exit
)

echo.
echo 2. Instalando dependencias (pynput)...
pip install pynput --quiet
echo [OK] Dependencias instaladas!

echo.
echo 3. Configurando Firewall do Windows...
netsh advfirewall firewall add rule name="Remote Control App UDP" dir=in action=allow protocol=UDP localport=8080 >nul 2>&1
netsh advfirewall firewall add rule name="Remote Control App TCP" dir=in action=allow protocol=TCP localport=8000 >nul 2>&1
echo [OK] Portas 8080 (Mouse) e 8000 (Video) liberadas no Firewall!

echo.
echo 4. Configurando inicializacao automatica com o Windows...
:: Cria um script vbs oculto para iniciar o servidor sem mostrar tela preta
set "SERVER_PATH=%~dp0server.py"
echo Set WshShell = CreateObject("WScript.Shell") > "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Start_RemoteServer.vbs"
echo WshShell.Run "pythonw """ ^& "%SERVER_PATH%" ^& """", 0, False >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Start_RemoteServer.vbs"

echo [OK] O servidor iniciara invisivel junto com o Windows!

echo.
echo =======================================================
echo  TUDO PRONTO! O servidor ja pode ser iniciado.
echo =======================================================
echo O IP desta maquina para colocar no celular e:
ipconfig | findstr /i "ipv4"
echo.
echo Pressione qualquer tecla para iniciar o servidor agora...
pause >nul

:: Inicia o servidor usando pythonw para nao travar o terminal
start "" pythonw "%~dp0server.py"

echo Servidor iniciado em segundo plano! Voce ja pode usar o celular.
timeout /t 5 >nul
exit
