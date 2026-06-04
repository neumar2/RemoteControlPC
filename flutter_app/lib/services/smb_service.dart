import '../models/profile.dart';
// Import hipotético do pacote smbi
// import 'package:smbi/smbi.dart';

class SmbFile {
  final String name;
  final String path;
  final int size;

  SmbFile({required this.name, required this.path, required this.size});
}

class SmbService {
  Profile? _currentProfile;

  void setProfile(Profile profile) {
    _currentProfile = profile;
  }

  Future<List<SmbFile>> listVideos() async {
    if (_currentProfile == null) return [];
    
    // TODO: Implementar listagem real usando smbi
    // Simulação de delay de rede
    await Future.delayed(const Duration(seconds: 1));
    
    // Retorna arquivos .mp4 mockados para fins de UI
    return [
      SmbFile(name: 'gravacao_jogo_1.mp4', path: '/Videos/gravacao_jogo_1.mp4', size: 1024 * 1024 * 50),
      SmbFile(name: 'clip_incrivel.mp4', path: '/Videos/clip_incrivel.mp4', size: 1024 * 1024 * 12),
      SmbFile(name: 'tutorial.mp4', path: '/Videos/tutorial.mp4', size: 1024 * 1024 * 150),
    ];
  }

  Future<void> downloadFile(SmbFile file, String destinationPath) async {
    // TODO: Implementar cópia real de stream SMB para File local
    await Future.delayed(const Duration(seconds: 2));
    print('Download concluído para \$destinationPath');
  }

  Future<void> deleteFile(SmbFile file) async {
    // TODO: Implementar deleção real no SMB
    await Future.delayed(const Duration(milliseconds: 500));
    print('Arquivo \${file.name} excluído do PC.');
  }
}
