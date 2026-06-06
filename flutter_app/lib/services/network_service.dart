import 'dart:async';
import 'dart:io';
import '../models/profile.dart';

class NetworkService {
  RawDatagramSocket? _socket;
  String? _activeIp;
  Profile? _currentProfile;
  final int port = 9090;

  /// Atualiza o perfil atual e determina o IP ativo
  Future<void> setProfile(Profile profile) async {
    if (_currentProfile?.id == profile.id) return;
    _currentProfile = profile;
    
    // Inicializa socket se não existir
    if (_socket == null) {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    }
    
    // Força o uso do IP Local diretamente sem checar VPN por enquanto
    _activeIp = _currentProfile!.localIp;
    print('IP fixado para: $_activeIp');
  }

  Future<bool> _checkReachability(String ip) async {
    try {
      // Cria socket temporário para testar
      final testSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      final address = InternetAddress(ip);
      
      Completer<bool> completer = Completer();
      
      // Envia pacote de "ping"
      testSocket.send('PING'.codeUnits, address, port);
      
      // Aguarda reposta (assumindo que o servidor Python ecoaria, 
      // ou apenas confia na resolução sem erro).
      // Para manter a performance no PC, o Python não responde ping. 
      // Vamos tentar um tcp socket ultra rápido só pra ver se o host tá de pé,
      // ou assumimos local falhou se não tiver rota.
      // Como estamos enviando UDP cego, vamos sempre tentar enviar para o Local. Se der erro na rede local, falha.
      
      // Para um Smart Fallback real sem ping do servidor: 
      // Vamos checar se o celular consegue pingar (ICMP) ou faz um connect rápido
      // Isso é uma simulação, um ping ICMP exigiria root no celular, então fazemos socket.connect TCP na porta de SMB (445)
      final socket = await Socket.connect(ip, 445, timeout: const Duration(milliseconds: 200));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  void sendCommand(String command) {
    if (_activeIp == null || _socket == null) return;
    
    try {
      final address = InternetAddress(_activeIp!);
      _socket!.send(command.codeUnits, address, port);
    } catch (e) {
      print('Erro ao enviar comando: $e');
    }
  }

  Future<void> wakeOnLan(String macAddress) async {
    try {
      final macStr = macAddress.replaceAll(':', '').replaceAll('-', '');
      if (macStr.length != 12) return;
      final macBytes = List<int>.generate(6, (i) => int.parse(macStr.substring(i * 2, i * 2 + 2), radix: 16));
      final packet = List<int>.filled(6, 0xff)..addAll(List.generate(16, (_) => macBytes).expand((i) => i));
      
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      socket.send(packet, InternetAddress('255.255.255.255'), 9);
      
      if (_currentProfile != null) {
        socket.send(packet, InternetAddress(_currentProfile!.localIp), 9);
        socket.send(packet, InternetAddress(_currentProfile!.vpnIp), 9);
      }
      socket.close();
    } catch (e) {
      print('Erro WOL: $e');
    }
  }
}
