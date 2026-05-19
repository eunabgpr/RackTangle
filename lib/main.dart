import 'dart:async';

import 'package:flutter/material.dart';
import 'package:racktangle/Levels/Level10.dart';
import 'package:racktangle/Levels/Level2.dart';
import 'package:racktangle/Levels/Level3.dart';
import 'package:racktangle/Levels/Level4.dart';
import 'package:racktangle/Levels/Level5.dart';
import 'package:racktangle/Levels/Level6.dart';
import 'package:racktangle/Levels/Level7.dart';
import 'package:racktangle/Levels/Level8.dart';
import 'package:racktangle/Levels/Level9.dart';
import 'package:racktangle/Levels/Level1.dart';
import 'package:racktangle/howtoplay.dart';
import 'package:racktangle/settings.dart';
import 'package:racktangle/services/bgm_service.dart';
import 'package:racktangle/services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bgmService = BgmService();
  await bgmService.initialize();
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
  final ProgressService _progressService = ProgressService();

  static const Color _backgroundColor = Color(0xFF171725);
  static const double _topImageOffset = 10;
  static const double _gapCircuitsToRack = 2;
  static const double _gapRackToTangle = 8;
  static const double _gapTangleToUntangle = 24;

  @override
  void initState() {
    super.initState();
    unawaited(
      BgmService().setBgm('bgm_menu.mp3'),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _playButtonSfx() async {
    try {
      await BgmService().playSfx('sfx_button.ogg');
    } catch (e) {
      print('Error playing button SFX: $e');
    }
  }

  Widget _screenForLevel(int level) {
    switch (level) {
      case 1:
        return const Level1Screen();
      case 2:
        return const Level2Screen();
      case 3:
        return const Level3Screen();
      case 4:
        return const Level4Screen();
      case 5:
        return const Level5Screen();
      case 6:
        return const Level6Screen();
      case 7:
        return const Level7Screen();
      case 8:
        return const Level8Screen();
      case 9:
        return const Level9Screen();
      case 10:
      default:
        return const Level10Screen();
    }
  }

  Future<void> _startGame() async {
    await _playButtonSfx();
    final unlockedLevel = await _progressService.getUnlockedLevel();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _screenForLevel(unlockedLevel),
      ),
    );
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
              onPressed: _startGame,
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
                  onPressed: () async {
                    await _playButtonSfx();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const HowToPlayScreen(),
                      ),
                    );
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 8),
                      Text(
                        'How to Play',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () async {
                    await _playButtonSfx();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
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
