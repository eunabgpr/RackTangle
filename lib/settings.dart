import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:racktangle/services/bgm_service.dart';
import 'package:racktangle/services/progress_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final BgmService _bgmService = BgmService();
  final ProgressService _progressService = ProgressService();

  bool _backgroundMusicEnabled = true;
  bool _soundEffectsEnabled = true;
  int _currentLevel = 1;
  int _maxLevel = 10;
  int _totalModules = 10;

  static const Color _backgroundColor = Color(0xFF171725);
  static const Color _panelColor = Color(0xFF222238);
  static const Color _panelBorderColor = Color(0xFF5B5B7A);
  static const Color _accentColor = Color(0xFF7D7DB2);
  static const Color _textColor = Color(0xFFF4F4FA);
  static const Color _subtleTextColor = Color(0xFFB9B9D3);
  static const Color _ruleColor = Color(0xFF6B6B8E);
  static const Color _dangerColor = Color(0xFFB00020);

  @override
  void initState() {
    super.initState();
    _backgroundMusicEnabled = _bgmService.bgmEnabled;
    unawaited(_loadProgress());
    unawaited(
      BgmService().setBgm('bgm_menu.mp3'),
    );
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _playButtonSfx() async {
    await _sfxPlayer.play(AssetSource('sfx/sfx_button.ogg'));
  }

  Future<void> _loadProgress() async {
    final unlockedLevel = await _progressService.getUnlockedLevel();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentLevel = unlockedLevel;
    });
  }

  int get _completedModules {
    return (_currentLevel - 1).clamp(0, _totalModules);
  }

  double get _levelProgress => _currentLevel / _maxLevel;

  Future<void> _toggleBackgroundMusic(bool value) async {
    setState(() {
      _backgroundMusicEnabled = value;
    });

    await _bgmService.setBgmEnabled(value);

    if (value) {
      await _bgmService.playBgm('bgm_menu.mp3');
    }
  }

  void _toggleSoundEffects(bool value) {
    setState(() {
      _soundEffectsEnabled = value;
    });
  }

  Future<void> _resetProgress() async {
    setState(() {
      _currentLevel = 1;
    });
    await _progressService.resetProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () async {
                      await _playButtonSfx();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(
                height: 1,
                thickness: 1,
                color: _ruleColor,
              ),
              const SizedBox(height: 34),
              const _SettingsSectionTitle(title: 'SOUNDS'),
              const SizedBox(height: 14),
              _ToggleSettingCard(
                label: 'Background Music',
                value: _backgroundMusicEnabled,
                onChanged: (value) => _toggleBackgroundMusic(value),
                accentColor: _accentColor,
                panelColor: _panelColor,
                panelBorderColor: _panelBorderColor,
                textColor: _textColor,
              ),
              const SizedBox(height: 14),
              _ToggleSettingCard(
                label: 'Sound Effects',
                value: _soundEffectsEnabled,
                onChanged: _toggleSoundEffects,
                accentColor: _accentColor,
                panelColor: _panelColor,
                panelBorderColor: _panelBorderColor,
                textColor: _textColor,
              ),
              const SizedBox(height: 28),
              const _SettingsSectionTitle(title: 'PROGRESS'),
              const SizedBox(height: 14),
              _ProgressCard(
                title: 'Current Level',
                subtitle: 'Level $_currentLevel of $_maxLevel unlocked',
                progress: _levelProgress,
                accentColor: _accentColor,
                panelColor: _panelColor,
                panelBorderColor: _panelBorderColor,
                textColor: _textColor,
                subtleTextColor: _subtleTextColor,
              ),
              const SizedBox(height: 14),
              _ProgressCard(
                title: 'Modules Completed',
                value: '$_completedModules/$_totalModules',
                accentColor: _accentColor,
                panelColor: _panelColor,
                panelBorderColor: _panelBorderColor,
                textColor: _textColor,
                subtleTextColor: _subtleTextColor,
              ),
              const SizedBox(height: 28),
              const _SettingsSectionTitle(title: 'DATA'),
              const SizedBox(height: 14),
              _DangerActionCard(
                label: 'Reset Progress',
                dangerColor: _dangerColor,
                panelColor: _panelColor,
                panelBorderColor: _panelBorderColor,
                textColor: _textColor,
                onTap: () async {
                  await _playButtonSfx();
                  await _resetProgress();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.title});

  final String title;

  static const Color _textColor = Color(0xFFB9B9D3);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _textColor,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ToggleSettingCard extends StatelessWidget {
  const _ToggleSettingCard({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    required this.panelColor,
    required this.panelBorderColor,
    required this.textColor,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accentColor;
  final Color panelColor;
  final Color panelBorderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: panelBorderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: accentColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    this.value,
    this.subtitle,
    this.progress,
    required this.accentColor,
    required this.panelColor,
    required this.panelBorderColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  final String title;
  final String? value;
  final String? subtitle;
  final double? progress;
  final Color accentColor;
  final Color panelColor;
  final Color panelBorderColor;
  final Color textColor;
  final Color subtleTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: panelBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 10,
              decoration: BoxDecoration(
                color: panelBorderColor.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress!.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: subtleTextColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

class _DangerActionCard extends StatelessWidget {
  const _DangerActionCard({
    required this.label,
    required this.onTap,
    required this.dangerColor,
    required this.panelColor,
    required this.panelBorderColor,
    required this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color dangerColor;
  final Color panelColor;
  final Color panelBorderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: panelBorderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                color: dangerColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: dangerColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  static const Color _buttonColor = Color(0xFF2A2A44);
  static const Color _borderColor = Color(0xFF5B5B7A);
  static const Color _iconColor = Color(0xFFF4F4FA);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _buttonColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor),
        ),
        child: Icon(
          icon,
          color: _iconColor,
          size: 18,
        ),
      ),
    );
  }
}
