import socket
import os
import subprocess
import threading
import json
import ctypes
import webbrowser
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import unquote
from pynput.mouse import Controller as MouseController, Button
from pynput.keyboard import Controller as KeyboardController, Key

# Inicializa controladores
mouse = MouseController()
keyboard = KeyboardController()

UDP_IP = "0.0.0.0"
UDP_PORT = 8080

def find_and_focus_window(title_substring):
    EnumWindows = ctypes.windll.user32.EnumWindows
    EnumWindowsProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int))
    GetWindowText = ctypes.windll.user32.GetWindowTextW
    GetWindowTextLength = ctypes.windll.user32.GetWindowTextLengthW
    IsWindowVisible = ctypes.windll.user32.IsWindowVisible
    
    found_hwnd = None
    
    def foreach_window(hwnd, lParam):
        nonlocal found_hwnd
        if IsWindowVisible(hwnd):
            length = GetWindowTextLength(hwnd)
            buff = ctypes.create_unicode_buffer(length + 1)
            GetWindowText(hwnd, buff, length + 1)
            if title_substring.lower() in buff.value.lower():
                found_hwnd = hwnd
                return False # Stop enumerating
        return True
    
    EnumWindows(EnumWindowsProc(foreach_window), 0)
    
    if found_hwnd:
        # SW_RESTORE = 9
        ctypes.windll.user32.ShowWindow(found_hwnd, 9)
        ctypes.windll.user32.SetForegroundWindow(found_hwnd)
        return True
    return False

def handle_command(data):
    """
    Protocolo de Strings Simples (Delimitador: ':')
    Formatos esperados:
    - Mouse Move:   MM:<dx>:<dy>
    - Mouse Click:  MC:<btn> (left, right, middle)
    - Mouse Scroll: MS:<dx>:<dy>
    - Keyboard:     K:<key>
    - Type:         TY:<string>
    - Macro:        MACRO:<action>
    - Power:        PWR:shutdown:<seconds> ou PWR:cancel
    """
    try:
        parts = data.split(':', 2) # Limita split para lidar com TY:text:com:dois:pontos
        cmd = parts[0]
        
        if cmd == 'MM':
            dx = int(float(parts[1]))
            dy = int(float(parts[2])) if len(parts) > 2 else 0
            mouse.move(dx, dy)
            
        elif cmd == 'MC':
            btn = parts[1]
            if btn == 'left':
                mouse.click(Button.left)
            elif btn == 'right':
                mouse.click(Button.right)
            elif btn == 'middle':
                mouse.click(Button.middle)
                
        elif cmd == 'MS':
            dx = int(float(parts[1]))
            dy = int(float(parts[2])) if len(parts) > 2 else 0
            mouse.scroll(dx, dy)
            
        elif cmd == 'K':
            key_name = parts[1]
            if hasattr(Key, key_name):
                keyboard.press(getattr(Key, key_name))
                keyboard.release(getattr(Key, key_name))
            else:
                keyboard.press(key_name)
                keyboard.release(key_name)
                
        elif cmd == 'TY':
            text = data.split(':', 1)[1] # Pega o resto da string após o primeiro :
            keyboard.type(text)
            
        elif cmd == 'MACRO':
            action = parts[1]
            if action in ['netflix', 'prime', 'hbo', 'crunchyroll', 'youtube', 'disney']:
                sites = {
                    'netflix': ('Netflix', 'https://www.netflix.com'),
                    'prime': ('Prime Video', 'https://www.primevideo.com'),
                    'hbo': ('Max', 'https://www.max.com'),
                    'crunchyroll': ('Crunchyroll', 'https://www.crunchyroll.com'),
                    'youtube': ('YouTube', 'https://www.youtube.com'),
                    'disney': ('Disney+', 'https://www.disneyplus.com')
                }
                title, url = sites[action]
                
                if find_and_focus_window(title):
                    keyboard.press(Key.f5)
                    keyboard.release(Key.f5)
                else:
                    webbrowser.open(url)
            elif action == 'backspace':
                keyboard.press(Key.backspace)
                keyboard.release(Key.backspace)
            elif action == 'play_pause':
                keyboard.press(Key.media_play_pause)
                keyboard.release(Key.media_play_pause)
            elif action == 'next':
                keyboard.press(Key.media_next)
                keyboard.release(Key.media_next)
            elif action == 'prev':
                keyboard.press(Key.media_previous)
                keyboard.release(Key.media_previous)
            elif action == 'mute':
                keyboard.press(Key.media_volume_mute)
                keyboard.release(Key.media_volume_mute)
            elif action == 'vol_up':
                keyboard.press(Key.media_volume_up)
                keyboard.release(Key.media_volume_up)
            elif action == 'vol_down':
                keyboard.press(Key.media_volume_down)
                keyboard.release(Key.media_volume_down)
            elif action == 'record':
                # Atalho Alt + F9
                with keyboard.pressed(Key.alt):
                    keyboard.press(Key.f9)
                    keyboard.release(Key.f9)
                    
        elif cmd == 'PWR':
            action = parts[1]
            if action == 'shutdown':
                try:
                    time_sec = int(parts[2])
                    subprocess.run(["shutdown", "-s", "-t", str(time_sec)], check=False)
                except ValueError:
                    print("Comando de shutdown ignorado devido a parametro invalido.")
            elif action == 'cancel':
                subprocess.run(["shutdown", "-a"], check=False)
                
    except Exception as e:
        print(f"Erro ao processar comando '{data}': {e}")

def start_udp_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((UDP_IP, UDP_PORT))
    print(f"[UDP] Servidor de Mouse/Teclado rodando em {UDP_IP}:{UDP_PORT}")
    
    while True:
        try:
            data, addr = sock.recvfrom(1024) 
            cmd_str = data.decode('utf-8').strip()
            handle_command(cmd_str)
        except Exception as e:
            print(f"[UDP] Erro no Socket: {e}")

class VideoGalleryHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

    def do_GET(self):
        # Rota de API personalizada para listar os arquivos
        if self.path.startswith('/api/files'):
            try:
                # Pega a pasta (ex: /api/files?dir=Forza)
                query_dir = ""
                if "?dir=" in self.path:
                    query_dir = unquote(self.path.split("?dir=")[1])
                
                base_path = os.path.abspath(os.path.expanduser(r"C:\Users\neoma\Videos"))
                target_path = os.path.abspath(os.path.join(base_path, query_dir))
                
                # Prevenção rigorosa de Path Traversal
                if not target_path.startswith(base_path) or os.path.commonpath([base_path, target_path]) != base_path:
                    self.send_response(403)
                    self.end_headers()
                    return
                
                if not os.path.exists(target_path):
                    self.send_response(404)
                    self.end_headers()
                    return
                
                items = []
                for item in os.listdir(target_path):
                    item_path = os.path.join(target_path, item)
                    is_dir = os.path.isdir(item_path)
                    
                    # Filtra apenas pastas e arquivos de video mp4
                    if is_dir or item.lower().endswith('.mp4'):
                        items.append({
                            "name": item,
                            "is_dir": is_dir,
                            "size": os.path.getsize(item_path) if not is_dir else 0,
                            "path": os.path.relpath(item_path, base_path).replace("\\", "/")
                        })
                
                response_data = json.dumps(items).encode('utf-8')
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Content-Length', len(response_data))
                self.end_headers()
                self.wfile.write(response_data)
                return
            except Exception as e:
                self.send_response(500)
                self.end_headers()
                return

        # Para as rotas normais (arquivos de vídeo), implementamos o suporte a Range requests
        # Isso é essencial para vídeos pesados (ex: 6GB) não precisarem carregar tudo de uma vez.
        try:
            raw_path = self.path
            is_download = False
            if '?' in raw_path:
                raw_path, query_string = raw_path.split('?', 1)
                if 'download=1' in query_string:
                    is_download = True
                    
            file_path = unquote(raw_path.lstrip('/'))
            base_path = os.path.abspath(os.path.expanduser(r"C:\Users\neoma\Videos"))
            
            # Removemos a barra inicial ou drive letter do file_path para o join funcionar corretamente como filho
            file_path = file_path.lstrip('\\/')
            full_path = os.path.abspath(os.path.join(base_path, file_path))
            
            # Prevenção rigorosa de Path Traversal
            if not full_path.startswith(base_path) or os.path.commonpath([base_path, full_path]) != base_path:
                self.send_response(403)
                self.end_headers()
                return
            
            if not os.path.exists(full_path) or not os.path.isfile(full_path):
                self.send_response(404)
                self.end_headers()
                return
                
            file_size = os.path.getsize(full_path)
            
            if 'Range' in self.headers:
                range_header = self.headers['Range']
                range_match = range_header.replace('bytes=', '').split('-')
                start = int(range_match[0]) if range_match[0] else 0
                end = int(range_match[1]) if len(range_match) > 1 and range_match[1] else file_size - 1
                
                # Previne erros de ranges inválidos
                if start >= file_size:
                    self.send_response(416)
                    self.send_header('Content-Range', f'bytes */{file_size}')
                    self.end_headers()
                    return
                
                end = min(end, file_size - 1)
                length = end - start + 1
                
                self.send_response(206)
                self.send_header('Content-Type', 'video/mp4')
                self.send_header('Accept-Ranges', 'bytes')
                self.send_header('Content-Range', f'bytes {start}-{end}/{file_size}')
                self.send_header('Content-Length', str(length))
                if is_download:
                    self.send_header('Content-Disposition', f'attachment; filename="{os.path.basename(full_path)}"')
                self.end_headers()
                
                with open(full_path, 'rb') as f:
                    f.seek(start)
                    chunk_size = 65536 # 64KB chunks para maior performance
                    bytes_to_read = length
                    while bytes_to_read > 0:
                        read_size = min(chunk_size, bytes_to_read)
                        try:
                            data = f.read(read_size)
                            if not data:
                                break
                            self.wfile.write(data)
                            bytes_to_read -= len(data)
                        except (ConnectionAbortedError, ConnectionResetError, BrokenPipeError):
                            # O Player parou de assistir esse pedaço (comum no streaming)
                            break
                return
            else:
                self.send_response(200)
                self.send_header('Content-Type', 'video/mp4')
                self.send_header('Accept-Ranges', 'bytes')
                self.send_header('Content-Length', str(file_size))
                if is_download:
                    self.send_header('Content-Disposition', f'attachment; filename="{os.path.basename(full_path)}"')
                self.end_headers()
                
                with open(full_path, 'rb') as f:
                    try:
                        # Para arquivos grandes sem Range, envia em chunks também para não estourar a RAM
                        chunk_size = 65536
                        while True:
                            data = f.read(chunk_size)
                            if not data:
                                break
                            self.wfile.write(data)
                    except (ConnectionAbortedError, ConnectionResetError, BrokenPipeError):
                        pass
                return
        except Exception as e:
            print(f"Erro no streaming de vídeo: {e}")
            try:
                self.send_response(500)
                self.end_headers()
            except:
                pass

def start_http_server():
    video_dir = os.path.expanduser(r"C:\Users\neoma\Videos")
    if not os.path.exists(video_dir):
        os.makedirs(video_dir)
    os.chdir(video_dir)
    
    server_address = ('0.0.0.0', 8000)
    httpd = HTTPServer(server_address, VideoGalleryHandler)
    print(f"[HTTP] Servidor de Galeria de Video rodando em {server_address[0]}:8000")
    httpd.serve_forever()

def main():
    print("Iniciando Servidores do Controle Remoto...")
    # Inicia o servidor HTTP numa thread separada
    http_thread = threading.Thread(target=start_http_server, daemon=True)
    http_thread.start()
    
    # Inicia o UDP na thread principal
    start_udp_server()

if __name__ == '__main__':
    main()
