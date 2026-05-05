import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Level9Screen extends StatefulWidget {
  const Level9Screen({super.key});

  @override
  State<Level9Screen> createState() => _Level9ScreenState();
}

class _Level9ScreenState extends State<Level9Screen> {
  static const Color _backgroundColor = Color(0xFF171725);

  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSfx(String fileName) async {
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sfx/$fileName'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LEVEL 9',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Next level coming soon.',
                  style: TextStyle(
                    color: Color(0xFFB8B8D8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _playSfx('sfx_button.ogg');
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF235DB5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
