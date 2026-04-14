import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:racktangle/Levels/Level1.dart';

void main() {
  runApp(const RacktangleApp());
}

class RacktangleApp extends StatelessWidget {
  const RacktangleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Racktangle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _sfxPlayer = AudioPlayer();

  static const Color _backgroundColor = Color(0xFF171725);
  static const double _topImageOffset = 10;
  static const double _gapCircuitsToRack = 2;
  static const double _gapRackToTangle = 8;
  static const double _gapTangleToUntangle = 24;

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _playButtonSfx() async {
    await _sfxPlayer.play(AssetSource('sfx/sfx_button.ogg'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: _topImageOffset),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Image(
                    image: AssetImage('assets/images/circuits.png'),
                    width: 440,
                  ),
                  SizedBox(height: _gapCircuitsToRack),
                  Image(
                    image: AssetImage('assets/images/RACK.png'),
                    width: 180,
                  ),
                  SizedBox(height: _gapRackToTangle),
                  Image(
                    image: AssetImage('assets/images/TANGLE.png'),
                    width: 300,
                  ),
                  SizedBox(height: _gapTangleToUntangle),
                  Image(
                    image: AssetImage('assets/images/untangle.png'),
                    width: 240,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _playButtonSfx();
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const Level1Screen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF235DB5),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                minimumSize: const Size(340, 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 38,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Play',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _playButtonSfx();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7D7DB2),
                    side: const BorderSide(
                      color: Color(0xFF7D7DB2),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 37,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'How to play',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    _playButtonSfx();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7D7DB2),
                    side: const BorderSide(
                      color: Color(0xFF7D7DB2),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 37,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
