@echo off
:: ============================================================
:: Instalador do RemoteControlPC Server (Modo Administrador)
:: Execute este arquivo com: Botao Direito -> Executar como Administrador
:: Isso precisa ser feito APENAS UMA VEZ.
:: ============================================================

echo.
echo ============================================================
echo   Instalando RemoteControlPC Server como Administrador...
echo ============================================================
echo.

:: Remove atalhos antigos da pasta Startup
del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\RemoteControlServer.lnk" 2>NUL
del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\RemoteControlServer.vbs" 2>NUL
del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Start_RemoteControl.bat" 2>NUL

:: Remove tarefa agendada antiga (se existir)
schtasks /delete /tn "RemoteControlPC_Server" /f 2>NUL

:: Cria nova tarefa agendada com privilegios de Administrador
schtasks /create /tn "RemoteControlPC_Server" /tr "\"C:\Users\neoma\AppData\Local\Programs\Python\Python312\pythonw.exe\" \"C:\Users\neoma\Documents\RemoteControlPC\python_server\server.py\"" /sc onlogon /rl highest /f

if %errorlevel% equ 0 (
    echo.
    echo [OK] Tarefa agendada criada com sucesso!
    echo.
    
    :: Mata qualquer servidor antigo rodando
    taskkill /im pythonw.exe /f 2>NUL
    timeout /t 2 /nobreak >NUL
    
    :: Inicia o servidor agora mesmo
    schtasks /run /tn "RemoteControlPC_Server"
    
    echo [OK] Servidor iniciado como Administrador!
    echo.
    echo ============================================================
    echo   PRONTO! O servidor agora:
    echo   - Roda como ADMINISTRADOR (funciona dentro de jogos)
    echo   - Inicia AUTOMATICAMENTE quando o PC liga
    echo   - Roda INVISIVEL (sem janela preta)
    echo ============================================================
) else (
    echo.
    echo [ERRO] Falha ao criar tarefa. Certifique-se de executar
    echo        este arquivo como Administrador!
    echo        Botao Direito -^> Executar como Administrador
)

echo.
pause
