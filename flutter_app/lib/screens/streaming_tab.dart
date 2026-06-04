import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';

class StreamingTab extends StatelessWidget {
  const StreamingTab({Key? key}) : super(key: key);

  void _sendMacro(BuildContext context, String action) {
    final network = context.read<NetworkService>();
    network.sendCommand('MACRO:$action');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comando enviado: $action'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.purple.withOpacity(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Lançadores de Streaming',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Inicie ou recarregue a aba no PC',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStreamButton(context, 'Netflix', 'netflix', Colors.red.shade800, Icons.movie),
                _buildStreamButton(context, 'Prime Video', 'prime', Colors.blue.shade600, Icons.local_movies),
                _buildStreamButton(context, 'HBO Max', 'hbo', Colors.deepPurple.shade700, Icons.tv),
                _buildStreamButton(context, 'Crunchyroll', 'crunchyroll', Colors.orange.shade700, Icons.animation),
                _buildStreamButton(context, 'YouTube', 'youtube', Colors.red, Icons.play_circle_filled),
                _buildStreamButton(context, 'Disney+', 'disney', Colors.indigo.shade800, Icons.star),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamButton(BuildContext context, String name, String macro, Color color, IconData icon) {
    return Material(
      color: color.withOpacity(0.8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _sendMacro(context, macro),
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white24,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
