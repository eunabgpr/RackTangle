import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BgmService {
  static final BgmService _instance = BgmService._internal();

  factory BgmService() {
    return _instance;
  }

  BgmService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _bgmEnabled = true;
  String? _currentBgm;
  bool _isInitialized = false;

  bool get bgmEnabled => _bgmEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _bgmEnabled = prefs.getBool('bgm_enabled') ?? true;

      // Set audio context
      await _bgmPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
          ),
          android: AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
          ),
        ),
      );

      // Set release mode to loop by default
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

      _isInitialized = true;
      print('BgmService initialized successfully');
    } catch (e) {
      print('BgmService initialization error: $e');
    }
  }

  Future<void> setBgmEnabled(bool enabled) async {
    _bgmEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bgm_enabled', enabled);

    if (!enabled) {
      await _bgmPlayer.stop();
      _currentBgm = null;
    } else if (_currentBgm != null) {
      // Resume current BGM
      await playBgm(_currentBgm!);
    }
  }

  Future<void> playBgm(String filename) async {
    try {
      // Ensure service is initialized
      if (!_isInitialized) {
        await initialize();
      }

      if (!_bgmEnabled) {
        _currentBgm = filename;
        return;
      }

      // Don't restart if already playing the same track
      if (_currentBgm == filename) {
        return;
      }

      _currentBgm = filename;

      // Stop previous audio
      await _bgmPlayer.stop();

      // Small delay to ensure clean stop
      await Future.delayed(const Duration(milliseconds: 100));

      // Set volume and release mode before playing
      await _bgmPlayer.setVolume(0.7);
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

      // Play the audio
      final source = AssetSource('bgm/$filename');
      await _bgmPlayer.play(source);

      print('Playing BGM: $filename');
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  Future<void> setBgm(String filename) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_currentBgm == filename) return;

    if (!_bgmEnabled) {
      _currentBgm = filename;
      return;
    }

    _currentBgm = filename;

    await _bgmPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 100));

    final source = AssetSource('bgm/$filename');
    await _bgmPlayer.play(source);

    print('BGM switched to: $filename');
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _currentBgm = null;
    } catch (e) {
      print('Error stopping BGM: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.release();
    } catch (e) {
      print('Error disposing BGM player: $e');
    }
  }
}
