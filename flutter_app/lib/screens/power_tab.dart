import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';
import '../providers/app_state.dart';

class PowerTab extends StatelessWidget {
  const PowerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final network = context.read<NetworkService>();
    final profile = context.watch<AppState>().currentProfile;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: Colors.green.withOpacity(0.15),
              foregroundColor: Colors.greenAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            icon: const Icon(Icons.power),
            label: const Text('LIGAR PC (Wake-on-LAN)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (profile != null) {
                network.wakeOnLan(profile.macAddress);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Magic Packet enviado na rede!')),
                );
              }
            },
          ),
          const SizedBox(height: 48),
          const Text(
            'Desligar PC',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShutdownButton(label: 'Agora', time: 0, network: network),
              _ShutdownButton(label: '15 Min', time: 15 * 60, network: network),
              _ShutdownButton(label: '1 Hora', time: 60 * 60, network: network),
            ],
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar Desligamento Agendado', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              network.sendCommand('PWR:cancel');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comando de cancelamento enviado.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShutdownButton extends StatelessWidget {
  final String label;
  final int time;
  final NetworkService network;

  const _ShutdownButton({required this.label, required this.time, required this.network});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        foregroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: () {
        network.sendCommand('PWR:shutdown:\$time');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Desligamento programado para \$label.')),
        );
      },
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
