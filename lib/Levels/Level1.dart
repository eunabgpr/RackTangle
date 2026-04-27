import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:racktangle/Levels/Level2.dart';

class Level1Screen extends StatefulWidget {
  const Level1Screen({super.key});

  @override
  State<Level1Screen> createState() => _Level1ScreenState();
}

class _Level1ScreenState extends State<Level1Screen> {
  static const Color _backgroundColor = Color(0xFF171725);
  static const Color _outlineColor = Color(0xFFD0D0D0);

  static const double _buttonSize = 40;
  static const double _buttonRadius = 10;
  static const double _buttonOuterPadding = 10;

  // Port position controls (ratios against each unit size)
  static const List<double> _modemPortX = [0.35, 0.48, 0.60];
  static const double _modemPortY = 0.70;
  static const List<double> _cpuPortX = [0.15, 0.15];
  static const List<double> _cpuPortY = [0.38, 0.52];

  // Label position controls (ratios against each unit size)
  static const double _routerLabelX = 0.37;
  static const double _routerLabelY = 0.42;
  static const double _cpuLabelXOffset = -45;
  static const double _cpuLabelY = 0.42;

  static const List<Color> _wireColors = [
    Colors.redAccent,
    Colors.yellowAccent
  ];

  final GlobalKey _stackKey = GlobalKey();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Wire i starts at modem port _modemPortByWire[i] and ends at CPU port _cpuPortByWire[i].
  List<int> _modemPortByWire = [0, 2];
  final List<int> _cpuPortByWire = [1, 0];
  int? _draggingWire;
  Offset? _dragPosition;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _levelCleared = false;
  bool _showingClearDialog = false;
  bool _isPaused = false;
  int _currentCrossingCount = 0;

  @override
  void initState() {
    super.initState();
    _isPaused = false;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSfx(String fileName) async {
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sfx/$fileName'));
  }

  void _startTimer() {
    if (_isPaused) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _levelCleared || _isPaused) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isPaused = true;
  }

  void _resumeTimer() {
    if (_levelCleared) {
      return;
    }
    _isPaused = false;
    _startTimer();
  }

  void _resetLevel() {
    setState(() {
      _modemPortByWire = [0, 2];
      _draggingWire = null;
      _dragPosition = null;
      _elapsedSeconds = 0;
      _isPaused = false;
      _levelCleared = false;
      _showingClearDialog = false;
    });
    _startTimer();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showPauseDialog(int crossingCount) async {
    if (_showingClearDialog) {
      return;
    }
    _pauseTimer();

    var shouldResume = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF232545),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFF6D7391)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1D2455),
                    border: Border.all(color: Colors.blueAccent, width: 1.4),
                  ),
                  child: const Icon(Icons.pause,
                      color: Colors.blueAccent, size: 48),
                ),
                const SizedBox(height: 14),
                const Text(
                  'LEVEL 1',
                  style: TextStyle(
                    color: Color(0xFF8A90A8),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Paused',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: _formatTime(_elapsedSeconds),
                        label: 'Time',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '$crossingCount',
                        label: 'Crossings Left',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      unawaited(_playSfx('sfx_button.ogg'));
                      shouldResume = true;
                      Navigator.of(dialogContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7E84A4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Resume',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      unawaited(_playSfx('sfx_button.ogg'));
                      Navigator.of(dialogContext).pop();
                      _resetLevel();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7E84A4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Restart Level',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      unawaited(_playSfx('sfx_button.ogg'));
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7E84A4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Back to home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldResume) {
      _resumeTimer();
    }
  }

  void _checkAndHandleLevelClear(int crossingCount) {
    final allWiresPlugged = _draggingWire == null && _dragPosition == null;
    if (_levelCleared ||
        _showingClearDialog ||
        crossingCount != 0 ||
        !allWiresPlugged) {
      return;
    }
    _levelCleared = true;
    _timer?.cancel();
    _showingClearDialog = true;
    unawaited(_playSfx('sfx_complete.mp3'));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final timeSpent = _elapsedSeconds;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: const Color(0xFF232545),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFF6D7391)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1D5C3B),
                      border: Border.all(color: Colors.greenAccent, width: 1.4),
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.greenAccent, size: 54),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'LEVEL 1',
                    style: TextStyle(
                      color: Color(0xFF8A90A8),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Complete!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: _formatTime(timeSpent),
                          label: 'Time',
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _StatCard(
                          value: '2',
                          label: 'Cables',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        unawaited(_playSfx('sfx_button.ogg'));
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const Level2Screen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7E84A4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Next Level >',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        unawaited(_playSfx('sfx_button.ogg'));
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7E84A4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _showingClearDialog = false;
    });
  }

  void _moveWireToPort(int wireIndex, int targetPort) {
    if (_modemPortByWire[wireIndex] == targetPort) {
      return;
    }
    final otherWire = _modemPortByWire.indexOf(targetPort);
    setState(() {
      if (otherWire != -1 && otherWire != wireIndex) {
        final current = _modemPortByWire[wireIndex];
        _modemPortByWire[wireIndex] = targetPort;
        _modemPortByWire[otherWire] = current;
      } else {
        _modemPortByWire[wireIndex] = targetPort;
      }
    });
  }

  int _nearestPortIndex(double x, List<Offset> ports) {
    var index = 0;
    var best = double.infinity;
    for (var i = 0; i < ports.length; i++) {
      final d = (ports[i].dx - x).abs();
      if (d < best) {
        best = d;
        index = i;
      }
    }
    return index;
  }

  Offset? _toStackLocal(Offset globalPosition) {
    final renderObject = _stackKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) {
      return null;
    }
    return renderObject.globalToLocal(globalPosition);
  }

  void _onWireDragStart(int wireIndex, DragStartDetails details) {
    final local = _toStackLocal(details.globalPosition);
    if (local == null) {
      return;
    }
    unawaited(_playSfx('sfx_remove.wav'));
    setState(() {
      _draggingWire = wireIndex;
      _dragPosition = local;
    });
  }

  void _onWireDragUpdate(
      int wireIndex, DragUpdateDetails details, List<Offset> modemPorts) {
    final local = _toStackLocal(details.globalPosition);
    if (local == null || _draggingWire != wireIndex) {
      return;
    }
    setState(() {
      _dragPosition = local;
    });
  }

  void _onWireDragEnd(int wireIndex, List<Offset> modemPorts) {
    final drop = _dragPosition;
    final previousPort = _modemPortByWire[wireIndex];
    if (drop != null) {
      final targetPort = _nearestPortIndex(drop.dx, modemPorts);
      _moveWireToPort(wireIndex, targetPort);
      if (targetPort != previousPort) {
        unawaited(_playSfx('sfx_attach.wav'));
      }
    }
    setState(() {
      _draggingWire = null;
      _dragPosition = null;
    });
  }

  static double _cross(Offset a, Offset b) => (a.dx * b.dy) - (a.dy * b.dx);

  static bool _segmentsIntersect(Offset p1, Offset p2, Offset q1, Offset q2) {
    final r = p2 - p1;
    final s = q2 - q1;
    final rxs = _cross(r, s);
    if (rxs.abs() < 0.0001) {
      return false;
    }
    final qp = q1 - p1;
    final t = _cross(qp, s) / rxs;
    final u = _cross(qp, r) / rxs;
    return t > 0 && t < 1 && u > 0 && u < 1;
  }

  int _crossings(List<Offset> modemPorts, List<Offset> cpuPorts) {
    var count = 0;
    for (var i = 0; i < _modemPortByWire.length; i++) {
      for (var j = i + 1; j < _modemPortByWire.length; j++) {
        final a1 = modemPorts[_modemPortByWire[i]];
        final a2 = cpuPorts[_cpuPortByWire[i]];
        final b1 = modemPorts[_modemPortByWire[j]];
        final b2 = cpuPorts[_cpuPortByWire[j]];
        if (_segmentsIntersect(a1, a2, b1, b2)) {
          count++;
        }
      }
    }
    return count;
  }

  int _crossingsFromLines(List<Offset> starts, List<Offset> ends) {
    var count = 0;
    for (var i = 0; i < starts.length; i++) {
      for (var j = i + 1; j < starts.length; j++) {
        if (_segmentsIntersect(starts[i], ends[i], starts[j], ends[j])) {
          count++;
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        leadingWidth: _buttonSize + (_buttonOuterPadding * 2),
        leading: Padding(
          padding: const EdgeInsets.all(_buttonOuterPadding),
          child: SizedBox(
            width: _buttonSize,
            height: _buttonSize,
            child: OutlinedButton(
              onPressed: () {
                unawaited(_playSfx('sfx_button.ogg'));
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _outlineColor,
                side: const BorderSide(color: _outlineColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_buttonRadius),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
          ),
        ),
        title: const Text(
          'Level 1',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(_buttonOuterPadding),
            child: SizedBox(
              width: _buttonSize,
              height: _buttonSize,
              child: OutlinedButton(
                onPressed: () {
                  unawaited(_playSfx('sfx_button.ogg'));
                  _showPauseDialog(_currentCrossingCount);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _outlineColor,
                  side: const BorderSide(color: _outlineColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_buttonRadius),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.pause, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final modemWidth = math.min(width * 0.64, 280.0);
            final modemLeft = (width - modemWidth) / 2;
            final modemTop = 50.0;

            final cpuWidth = math.min(width * 0.72, 280.0);
            final cpuLeft = (width - cpuWidth) / 2 + 10;
            final cpuTop = math.min(height * 0.56, height - 260);

            final modemPorts = List<Offset>.generate(
              3,
              (i) => Offset(
                modemLeft + (modemWidth * _modemPortX[i]),
                modemTop + (modemWidth * _modemPortY),
              ),
            );

            final cpuPorts = List<Offset>.generate(
              _cpuPortX.length,
              (i) => Offset(
                cpuLeft + (cpuWidth * _cpuPortX[i]),
                cpuTop + (cpuWidth * _cpuPortY[i]),
              ),
            );

            final wireStarts = _modemPortByWire
                .map((i) => modemPorts[i])
                .toList(growable: false);
            final wireEnds =
                _cpuPortByWire.map((i) => cpuPorts[i]).toList(growable: false);
            if (_draggingWire != null && _dragPosition != null) {
              wireStarts[_draggingWire!] = _dragPosition!;
            }

            final crossingCount = _crossingsFromLines(wireStarts, wireEnds);
            _currentCrossingCount = crossingCount;
            _checkAndHandleLevelClear(crossingCount);

            return Stack(
              key: _stackKey,
              children: [
                Positioned(
                  top: 10,
                  left: 25,
                  right: 16,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Center(
                            child: Text(
                              '• $crossingCount Crossings',
                              style: TextStyle(
                                color: crossingCount > 0
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatTime(_elapsedSeconds),
                              style: const TextStyle(
                                color: Color(0xFFD0D0D0),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const SizedBox(
                        width: 250,
                        child: Text(
                          'Drag cable endpoints to untangle all connection',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFD0D0D0),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: modemTop,
                  left: modemLeft,
                  child:
                      Image.asset('assets/images/modem.png', width: modemWidth),
                ),
                Positioned(
                  top: modemTop + (modemWidth * _routerLabelY),
                  left: modemLeft + (modemWidth * _routerLabelX),
                  child: _UnitLabel(
                    text: 'Router',
                    textStyle:
                        TextStyle(fontSize: 12, color: const Color(0xFFD0D0D0)),
                  ),
                ),
                Positioned(
                  top: cpuTop,
                  left: cpuLeft,
                  child: Image.asset('assets/images/CPU.png', width: cpuWidth),
                ),
                Positioned(
                  top: cpuTop + (cpuWidth * _cpuLabelY),
                  left: cpuLeft + _cpuLabelXOffset,
                  child: _UnitLabel(
                    text: 'CPU',
                    textStyle:
                        TextStyle(fontSize: 12, color: const Color(0xFFD0D0D0)),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WiresPainter(
                      starts: wireStarts,
                      ends: wireEnds,
                      colors: _wireColors,
                    ),
                  ),
                ),
                for (var i = 0; i < modemPorts.length; i++)
                  Positioned(
                    left: modemPorts[i].dx - 8,
                    top: modemPorts[i].dy - 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: const Color(0xFFD0D0D0), width: 2),
                      ),
                    ),
                  ),
                for (var i = 0; i < cpuPorts.length; i++)
                  Positioned(
                    left: cpuPorts[i].dx - 8,
                    top: cpuPorts[i].dy - 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: const Color(0xFFD0D0D0), width: 2),
                      ),
                    ),
                  ),
                for (var wire = 0; wire < _modemPortByWire.length; wire++)
                  Positioned(
                    left: wireStarts[wire].dx - 11,
                    top: wireStarts[wire].dy - 11,
                    child: GestureDetector(
                      onPanStart: (details) => _onWireDragStart(wire, details),
                      onPanUpdate: (details) =>
                          _onWireDragUpdate(wire, details, modemPorts),
                      onPanEnd: (_) => _onWireDragEnd(wire, modemPorts),
                      onPanCancel: () => _onWireDragEnd(wire, modemPorts),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _wireColors[wire],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black54, width: 2),
                        ),
                      ),
                    ),
                  ),
                for (var wire = 0; wire < _cpuPortByWire.length; wire++)
                  Positioned(
                    left: cpuPorts[_cpuPortByWire[wire]].dx - 10,
                    top: cpuPorts[_cpuPortByWire[wire]].dy - 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _wireColors[wire],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black54, width: 2),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UnitLabel extends StatelessWidget {
  const _UnitLabel({required this.text, this.textStyle});

  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D0D0), width: 1.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: textStyle ??
            const TextStyle(
              color: Color(0xFFD0D0D0),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3E66),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA2BD),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WiresPainter extends CustomPainter {
  const _WiresPainter(
      {required this.starts, required this.ends, required this.colors});

  final List<Offset> starts;
  final List<Offset> ends;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < starts.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(starts[i], ends[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WiresPainter oldDelegate) {
    return oldDelegate.starts != starts || oldDelegate.ends != ends;
  }
}
