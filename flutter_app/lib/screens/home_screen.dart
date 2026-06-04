import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/app_state.dart';
import '../services/network_service.dart';
import '../services/smb_service.dart';
import 'trackpad_tab.dart';
import 'power_tab.dart';
import 'gallery_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentProfile = appState.currentProfile;

    if (currentProfile != null) {
      context.read<NetworkService>().setProfile(currentProfile);
      context.read<SmbService>().setProfile(currentProfile);
    }

    final List<Widget> tabs = [
      const TrackpadTab(),
      const PowerTab(),
    ];
    
    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.touch_app), label: 'Trackpad'),
      const BottomNavigationBarItem(icon: Icon(Icons.power_settings_new), label: 'Energia'),
    ];

    if (currentProfile?.hasSMBFiles == true) {
      tabs.add(const GalleryTab());
      navItems.add(const BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Galeria'));
    }

    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark mode real
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/app_icon.png', width: 40, height: 40, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.important_devices, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentProfile?.id,
                  dropdownColor: const Color(0xFF1E1E1E),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                  isExpanded: true,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  items: [
                    ...appState.profiles.map((p) => DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    )),
                    const DropdownMenuItem<String>(
                      value: 'ADD_NEW',
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Color(0xFF6C63FF), size: 20),
                          SizedBox(width: 8),
                          Text('Adicionar PC...', style: TextStyle(color: Color(0xFF6C63FF))),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val == 'ADD_NEW') {
                      _showProfileDialog(context, null, appState);
                    } else if (val != null) {
                      final selected = appState.profiles.firstWhere((p) => p.id == val);
                      appState.switchProfile(selected);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            tooltip: 'Sobre',
            onPressed: () => _showAboutDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            tooltip: 'Configurações do PC Atual',
            onPressed: () {
              if (currentProfile != null) {
                _showProfileDialog(context, currentProfile, appState);
              }
            },
          )
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: tabs.isNotEmpty ? tabs[_currentIndex] : const Center(child: Text("Nenhum perfil selecionado", style: TextStyle(color: Colors.white))),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.white38,
          currentIndex: _currentIndex,
          items: navItems,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, Profile? profile, AppState appState) {
    final isNew = profile == null;
    final nameCtrl = TextEditingController(text: profile?.name ?? '');
    final localIpCtrl = TextEditingController(text: profile?.localIp ?? '');
    final macCtrl = TextEditingController(text: profile?.macAddress ?? '00:00:00:00:00:00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(isNew ? 'Adicionar Novo PC' : 'Configurações do PC', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl, 
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nome (ex: PC Esposa)', labelStyle: TextStyle(color: Colors.white54))
              ),
              TextField(
                controller: localIpCtrl, 
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'IP Local (ex: 192.168.1.15)', labelStyle: TextStyle(color: Colors.white54))
              ),
              TextField(
                controller: macCtrl, 
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Endereço MAC', labelStyle: TextStyle(color: Colors.white54))
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            onPressed: () {
              if (nameCtrl.text.isEmpty || localIpCtrl.text.isEmpty) return;
              
              final newProfile = Profile(
                id: isNew ? DateTime.now().millisecondsSinceEpoch.toString() : profile.id,
                name: nameCtrl.text,
                localIp: localIpCtrl.text,
                vpnIp: '',
                macAddress: macCtrl.text,
                hasGamingMacros: true,
                hasSMBFiles: true,
              );
              appState.addOrUpdateProfile(newProfile);
              Navigator.pop(ctx);
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.code, color: Color(0xFF6C63FF)),
            SizedBox(width: 8),
            Text('Sobre', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remote Control App', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Desenvolvido por: Neumar Permonian', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 16),
            Text('Este projeto é de código aberto e está licenciado sob a licença MIT. Você é livre para usar, modificar e distribuir o código.', 
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFF6C63FF))),
          )
        ],
      ),
    );
  }
}
