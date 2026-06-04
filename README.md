# Remote Control PC

Um aplicativo moderno feito em Flutter para controle remoto total do seu PC Windows via Wi-Fi ou rede local. Transforme seu smartphone num Trackpad avançado, teclado, controlador de mídia e reprodutor de vídeos remotos.

## 📥 Download Rápido (Pronto para Usar)
Se você não quer compilar o código e apenas quer usar o aplicativo, baixe os arquivos já prontos na pasta `Releases_Para_Baixar` deste repositório:
1. **[📱 Baixar APK para Android (RemoteControlApp_v1.0.apk)](Releases_Para_Baixar/RemoteControlApp_v1.0.apk)**
2. **[💻 Baixar Servidor para Windows (Instalador_Servidor_Windows.zip)](Releases_Para_Baixar/Instalador_Servidor_Windows.zip)**

---

## 🚀 Funcionalidades Principais

- **Trackpad Premium:** Controle preciso do mouse com duplo toque e controle de sensibilidade.
- **Scroll Bar:** Botões dedicados de "Page Up" e "Page Down" na lateral para rolagem super rápida de sites e apresentações.
- **Teclado Remoto:** Integração nativa para digitar no PC através do seu smartphone Android.
- **Macros de Gaming e Mídia:** Controle de volume, mutar, e gravação rápida de tela (ex: Alt+F9 para NVIDIA ShadowPlay).
- **Gerenciador de Energia:** Desligue ou agende o desligamento remoto do seu PC Windows diretamente pelo app.
- **Galeria SMB de Vídeos:** Navegue nas suas pastas de vídeos do PC Windows e assista diretamente pelo aplicativo através de um robusto servidor HTTP com suporte a *Range Requests*, capaz de iniciar vídeos pesados (ex: gameplays de 10GB+) instantaneamente.
- **Suporte Multi-PCs:** Salve as configurações do seu PC principal, notebook e outras máquinas com troca rápida de perfis.

## 🛠 Arquitetura

O projeto é dividido em dois módulos essenciais:

1. **Flutter App (`/flutter_app`)**: O aplicativo mobile contendo a UI moderna (Neumorfismo Escuro / Cyberpunk) projetado em Dart.
2. **Python Server (`/python_server`)**: O cérebro que roda no Windows, recebendo sinais UDP e gerando um Web Server inteligente (porta 8000) e controlador de inputs virtuais (porta 8080).

## 📥 Como Instalar e Usar

### 1. Preparar o PC Windows (Servidor Python)
O código inclui um script de instalação automatizado.
1. Transfira a pasta `python_server` para o PC Windows que deseja controlar.
2. Clique com o botão direito no arquivo `Instalador_Servidor.bat` e escolha **Executar como Administrador**.
3. O script cuidará da instalação do Python, instalará a biblioteca `pynput`, configurará regras automáticas no Firewall do Windows e agendará o servidor para rodar sempre que o computador ligar.

### 2. Preparar o Smartphone (Flutter App)
Você pode compilar o projeto com o Flutter instalado no seu computador:
```bash
cd flutter_app
flutter pub get
flutter build apk
```
Ou rodar no modo desenvolvedor:
```bash
flutter run
```

### 3. Parear App com o PC
1. Abra o App.
2. Na aba superior, clique em "Adicionar PC" e preencha com o **IP Local** da sua máquina Windows.
3. Aproveite o controle total!

## 📄 Licença

Este projeto é disponibilizado sob a licença [MIT](LICENSE). Desenvolvido de forma independente para a comunidade Open Source.
Copyright (c) 2026 Neumar Permonian.
