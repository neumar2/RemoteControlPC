import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import 'video_player_screen.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  String _currentDir = '';
  List<dynamic> _items = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDirectory('');
  }

  Future<void> _loadDirectory(String dir) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ip = context.read<AppState>().currentProfile?.localIp ?? '';
      if (ip.isEmpty) throw Exception("IP não configurado");

      final url = Uri.parse('http://$ip:8000/api/files?dir=${Uri.encodeComponent(dir)}');
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        setState(() {
          _items = json.decode(response.body);
          _currentDir = dir;
          _isLoading = false;
        });
      } else {
        throw Exception("Erro HTTP ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _goBack() {
    if (_currentDir.isEmpty) return;
    final parts = _currentDir.split('/');
    parts.removeLast();
    _loadDirectory(parts.join('/'));
  }

  void _openFile(dynamic file) {
    if (file['is_dir']) {
      final newDir = _currentDir.isEmpty ? file['name'] : '$_currentDir/${file['name']}';
      _loadDirectory(newDir);
    } else {
      final ip = context.read<AppState>().currentProfile?.localIp ?? '';
      final url = 'http://$ip:8000/${file['path']}';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(url: url, title: file['name']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Navigation bar
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black26,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _currentDir.isEmpty ? null : _goBack,
                color: _currentDir.isEmpty ? Colors.white24 : Colors.white,
              ),
              Expanded(
                child: Text(
                  _currentDir.isEmpty ? 'Vídeos' : _currentDir,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadDirectory(_currentDir),
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text('Erro: $_error', style: const TextStyle(color: Colors.redAccent)),
                          TextButton(
                            onPressed: () => _loadDirectory(_currentDir),
                            child: const Text('Tentar Novamente'),
                          )
                        ],
                      ),
                    )
                  : _items.isEmpty
                      ? const Center(child: Text('Nenhum vídeo encontrado.', style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final file = _items[index];
                            final isDir = file['is_dir'];
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              color: const Color(0xFF1A1A1A),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.white10),
                              ),
                              child: ListTile(
                                onTap: () => _openFile(file),
                                leading: Icon(
                                  isDir ? Icons.folder : Icons.play_circle_fill,
                                  color: isDir ? Colors.amber : Theme.of(context).primaryColor,
                                  size: 32,
                                ),
                                title: Text(file['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: isDir ? null : Text('${(file['size'] / (1024 * 1024)).toStringAsFixed(1)} MB'),
                                trailing: isDir 
                                    ? const Icon(Icons.chevron_right, color: Colors.white54) 
                                    : IconButton(
                                        icon: const Icon(Icons.download, color: Colors.white),
                                        onPressed: () {
                                          final ip = context.read<AppState>().currentProfile?.localIp ?? '';
                                          final url = 'http://$ip:8000/${file['path']}?download=1';
                                          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                        },
                                      ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
