import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';
import '../providers/app_state.dart';

class TrackpadTab extends StatefulWidget {
  const TrackpadTab({super.key});

  @override
  State<TrackpadTab> createState() => _TrackpadTabState();
}

class _TrackpadTabState extends State<TrackpadTab> {
  double _sensitivity = 1.0;
  final FocusNode _keyboardFocus = FocusNode();
  // Inicializamos com um espaço para que o Backspace do Android seja detectado quando o texto ficar vazio.
  final TextEditingController _keyboardCtrl = TextEditingController(text: ' ');

  @override
  void dispose() {
    _keyboardFocus.dispose();
    _keyboardCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final network = context.read<NetworkService>();
    if (text.isEmpty) {
      // O texto era ' ' e ficou '', então o usuário apertou Backspace
      network.sendCommand('MACRO:backspace');
      _keyboardCtrl.text = ' ';
    } else if (text.length > 1) {
      // O texto era ' ' e virou ' a', então o usuário apertou 'a'
      final char = text.substring(1);
      network.sendCommand('TY:$char');
      _keyboardCtrl.text = ' ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final network = context.read<NetworkService>();
    final hasMacros = context.watch<AppState>().currentProfile?.hasGamingMacros ?? false;

    return Stack(
      children: [
        // Campo escondido para puxar o teclado nativo
        Positioned(
          top: -1000,
          child: SizedBox(
            width: 10,
            child: TextField(
              focusNode: _keyboardFocus,
              controller: _keyboardCtrl,
              onChanged: _onTextChanged,
              autocorrect: false,
              enableSuggestions: false,
            ),
          ),
        ),
        
        Column(
          children: [
            // Macros Bar (Volume + Mídia)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMacroBtn(Icons.volume_down, 'MACRO:vol_down', network),
                    _buildMacroBtn(Icons.volume_up, 'MACRO:vol_up', network),
                    Container(width: 1, height: 30, color: Colors.white10),
                    _buildMacroBtn(Icons.skip_previous, 'MACRO:prev', network),
                    _buildMacroBtn(Icons.play_arrow, 'MACRO:play_pause', network, isPrimary: true, context: context),
                    _buildMacroBtn(Icons.skip_next, 'MACRO:next', network),
                    if (hasMacros) ...[
                      Container(width: 1, height: 30, color: Colors.white10),
                      _buildMacroBtn(Icons.fiber_manual_record, 'MACRO:record', network, color: Colors.redAccent),
                    ]
                  ],
                ),
              ),
            ),
            
            // Sensibilidade e Teclado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  const Icon(Icons.speed, color: Colors.white54, size: 20),
                  Expanded(
                    child: Slider(
                      value: _sensitivity,
                      min: 0.5,
                      max: 3.0,
                      divisions: 5,
                      label: '${_sensitivity.toStringAsFixed(1)}x',
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.white10,
                      onChanged: (val) => setState(() => _sensitivity = val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard, color: Colors.white),
                    tooltip: 'Abrir Teclado',
                    onPressed: () {
                      _keyboardFocus.requestFocus();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  )
                ],
              ),
            ),
            
            // Trackpad Area
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        final dx = details.delta.dx * _sensitivity;
                        final dy = details.delta.dy * _sensitivity;
                        network.sendCommand('MM:$dx:$dy');
                      },
                      onTap: () => network.sendCommand('MC:left'),
                      onDoubleTap: () => network.sendCommand('MC:right'),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151515), // Neumórfico super escuro
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.08),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                            const BoxShadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(0, 10),
                            )
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: const Center(
                          child: Text(
                            'TRACKPAD\n\nDeslize para mover o mouse\nToque para clicar\nDuplo toque para botão direito',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, height: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Scroll Bar (Page Up / Page Down)
                  Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 36),
                          onPressed: () => network.sendCommand('K:page_up'),
                          tooltip: 'Page Up (Subir Página)',
                        ),
                        Container(height: 1, width: 30, color: Colors.white10),
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 36),
                          onPressed: () => network.sendCommand('K:page_down'),
                          tooltip: 'Page Down (Descer Página)',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroBtn(IconData icon, String cmd, NetworkService net, {bool isPrimary = false, BuildContext? context, Color? color}) {
    return IconButton(
      icon: Icon(icon),
      iconSize: isPrimary ? 32 : 24,
      color: color ?? (isPrimary ? Theme.of(context!)?.primaryColor : Colors.white70),
      onPressed: () => net.sendCommand(cmd),
      style: isPrimary ? IconButton.styleFrom(
        backgroundColor: Theme.of(context!)?.primaryColor.withOpacity(0.2),
      ) : null,
    );
  }
}
