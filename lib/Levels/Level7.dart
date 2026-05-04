import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:racktangle/Levels/Level8.dart';

class Level7Screen extends StatefulWidget {
  const Level7Screen({super.key});

  @override
  State<Level7Screen> createState() => _Level7ScreenState();
}

class _Level7ScreenState extends State<Level7Screen> {
  static const Color _backgroundColor = Color(0xFF171725);
  static const Color _outlineColor = Color(0xFFD0D0D0);

  static const double _buttonSize = 40;
  static const double _buttonRadius = 10;
  static const double _buttonOuterPadding = 10;

  static const double _serverLeftPortX = 0.25;
  static const double _serverRightPortX = 0.38;
  static const double _leftPortsYOffsetPx = -30;
  static const List<double> _serverPortY = [
    0.37,
    0.47,
    0.57,
    0.67,
    0.77,
    0.84,
  ];

  static const List<Color> _wireColors = [
    Color(0xFF39FF4A),
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.blueAccent,
    Color(0xFFB24DFF),
  ];

  final GlobalKey _stackKey = GlobalKey();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Five cables: left-side endpoint is draggable among left ports,
  // right-side endpoint is draggable among right ports.
  List<int> _leftPortByWire = [0, 1, 2, 3, 4];
  List<int> _rightPortByWire = [3, 1, 0, 4, 2]; // 5 crossings initial

  int? _draggingWire;
  bool _draggingWireEnd = false;
  Offset? _dragPosition;

  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _levelCleared = false;
  bool _showingClearDialog = false;
  bool _isPaused = false;
  bool _showPrePlayModule = true;
  int _currentCrossingCount = 0;

  @override
  void initState() {
    super.initState();
    _isPaused = true;
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

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isPaused = true;
  }

  void _startLevelFromLearningCard() {
    if (!_showPrePlayModule) {
      return;
    }
    unawaited(_playSfx('sfx_button.ogg'));
    setState(() {
      _showPrePlayModule = false;
      _isPaused = false;
    });
    _startTimer();
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
      _leftPortByWire = [0, 1, 2, 3, 4];
      _rightPortByWire = [3, 1, 0, 4, 2];
      _draggingWire = null;
      _draggingWireEnd = false;
      _dragPosition = null;
      _elapsedSeconds = 0;
      _isPaused = false;
      _levelCleared = false;
      _showingClearDialog = false;
    });
    _startTimer();
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
                  'LEVEL 7',
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
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7E84A4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Exit Level',
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
    if (shouldResume && mounted) {
      _resumeTimer();
    }
  }

  Widget _dialogButton(
      {required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF7E84A4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _showCompletionDialog() async {
    if (!mounted) {
      return;
    }
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
                    border: Border.all(color: Colors.greenAccent, width: 1.4),
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.greenAccent, size: 48),
                ),
                const SizedBox(height: 14),
                const Text(
                  'LEVEL 7',
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
                        value: _formatTime(_elapsedSeconds),
                        label: 'Time',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _StatCard(
                        value: '5',
                        label: 'Cables',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _dialogButton(
                  text: 'Next Level',
                  onPressed: () {
                    unawaited(_playSfx('sfx_button.ogg'));
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const Level8Screen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _dialogButton(
                  text: 'Back to home',
                  onPressed: () {
                    unawaited(_playSfx('sfx_button.ogg'));
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    _showingClearDialog = false;
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
      await _showCompletionDialog();
    });
  }

  void _moveWireToPort(int wireIndex, int targetPort) {
    if (_leftPortByWire[wireIndex] == targetPort) {
      return;
    }
    final otherWire = _leftPortByWire.indexOf(targetPort);
    setState(() {
      if (otherWire != -1 && otherWire != wireIndex) {
        final current = _leftPortByWire[wireIndex];
        _leftPortByWire[wireIndex] = targetPort;
        _leftPortByWire[otherWire] = current;
      } else {
        _leftPortByWire[wireIndex] = targetPort;
      }
    });
  }

  void _moveWireEndToPort(int wireIndex, int targetPort) {
    if (_rightPortByWire[wireIndex] == targetPort) {
      return;
    }
    final otherWire = _rightPortByWire.indexOf(targetPort);
    setState(() {
      if (otherWire != -1 && otherWire != wireIndex) {
        final current = _rightPortByWire[wireIndex];
        _rightPortByWire[wireIndex] = targetPort;
        _rightPortByWire[otherWire] = current;
      } else {
        _rightPortByWire[wireIndex] = targetPort;
      }
    });
  }

  int _nearestPortIndex(Offset point, List<Offset> ports) {
    var index = 0;
    var best = double.infinity;
    for (var i = 0; i < ports.length; i++) {
      final dx = ports[i].dx - point.dx;
      final dy = ports[i].dy - point.dy;
      final d = (dx * dx) + (dy * dy);
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

  void _onWireDragStart(int wireIndex, DragStartDetails details,
      {bool dragEnd = false}) {
    final local = _toStackLocal(details.globalPosition);
    if (local == null) {
      return;
    }
    unawaited(_playSfx('sfx_remove.wav'));
    setState(() {
      _draggingWire = wireIndex;
      _draggingWireEnd = dragEnd;
      _dragPosition = local;
    });
  }

  void _onWireDragUpdate(int wireIndex, DragUpdateDetails details) {
    final local = _toStackLocal(details.globalPosition);
    if (local == null || _draggingWire != wireIndex) {
      return;
    }
    setState(() {
      _dragPosition = local;
    });
  }

  void _onWireDragEnd(int wireIndex, List<Offset> ports,
      {bool dragEnd = false}) {
    final drop = _dragPosition;
    final previousPort =
        dragEnd ? _rightPortByWire[wireIndex] : _leftPortByWire[wireIndex];
    if (drop != null) {
      final targetPort = _nearestPortIndex(drop, ports);
      if (dragEnd) {
        _moveWireEndToPort(wireIndex, targetPort);
      } else {
        _moveWireToPort(wireIndex, targetPort);
      }
      if (targetPort != previousPort) {
        unawaited(_playSfx('sfx_attach.wav'));
      }
    }
    setState(() {
      _draggingWire = null;
      _draggingWireEnd = false;
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
              child: const Icon(Icons.chevron_left, size: 22),
            ),
          ),
        ),
        title: const Text(
          'Level 7',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 44,
            letterSpacing: -0.5,
          ),
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

            final serverWidth = math.min(width * 0.95, 800.0);
            final availableForServer = math.max(220.0, height - 100.0);
            final serverHeight =
                math.min(serverWidth * 1.30, availableForServer);
            final serverLeft = (width - serverWidth) / 2;
            final serverTop = 118.0;

            final leftPorts = List<Offset>.generate(
              _serverPortY.length,
              (i) => Offset(
                serverLeft + (serverWidth * _serverLeftPortX),
                serverTop +
                    (serverHeight * _serverPortY[i]) +
                    _leftPortsYOffsetPx,
              ),
            );

            final rightPorts = List<Offset>.generate(
              _serverPortY.length,
              (i) => Offset(
                serverLeft + (serverWidth * _serverRightPortX),
                serverTop + (serverHeight * _serverPortY[i]),
              ),
            );

            final starts = List<Offset>.generate(
              _wireColors.length,
              (i) => leftPorts[_leftPortByWire[i]],
            );
            final ends = List<Offset>.generate(
              _wireColors.length,
              (i) => rightPorts[_rightPortByWire[i]],
            );

            if (_draggingWire != null && _dragPosition != null) {
              if (_draggingWireEnd) {
                ends[_draggingWire!] = _dragPosition!;
              } else {
                starts[_draggingWire!] = _dragPosition!;
              }
            }

            final crossingCount = _crossingsFromLines(starts, ends);
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
                        width: 260,
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
                  top: serverTop,
                  left: serverLeft,
                  child: SizedBox(
                    width: serverWidth,
                    height: serverHeight,
                    child: Image.asset(
                      'assets/images/server.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: serverTop + serverHeight + 12,
                  left: (width / 2) - 34,
                  child: const _UnitLabel(text: 'Server'),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WirePainter(
                      starts: starts,
                      ends: ends,
                      colors: _wireColors,
                    ),
                  ),
                ),
                for (var i = 0; i < leftPorts.length; i++)
                  _ghostPort(leftPorts[i]),
                for (var i = 0; i < rightPorts.length; i++)
                  _ghostPort(rightPorts[i]),
                for (var wire = 0; wire < _wireColors.length; wire++)
                  _dragHandle(
                    position: starts[wire],
                    color: _wireColors[wire],
                    onPanStart: (details) => _onWireDragStart(wire, details),
                    onPanUpdate: (details) => _onWireDragUpdate(wire, details),
                    onPanEnd: (_) => _onWireDragEnd(wire, leftPorts),
                    onPanCancel: () => _onWireDragEnd(wire, leftPorts),
                  ),
                for (var wire = 0; wire < _wireColors.length; wire++)
                  _dragHandle(
                    position: ends[wire],
                    color: _wireColors[wire],
                    onPanStart: (details) =>
                        _onWireDragStart(wire, details, dragEnd: true),
                    onPanUpdate: (details) => _onWireDragUpdate(wire, details),
                    onPanEnd: (_) =>
                        _onWireDragEnd(wire, rightPorts, dragEnd: true),
                    onPanCancel: () =>
                        _onWireDragEnd(wire, rightPorts, dragEnd: true),
                  ),
                if (_showPrePlayModule)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: _Level7LearningCard(
                          onReady: _startLevelFromLearningCard,
                        ),
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

  Widget _ghostPort(Offset p) {
    return Positioned(
      left: p.dx - 8,
      top: p.dy - 8,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: const Color(0xFFD0D0D0), width: 2),
        ),
      ),
    );
  }

  Widget _dragHandle({
    required Offset position,
    required Color color,
    required GestureDragStartCallback onPanStart,
    required GestureDragUpdateCallback onPanUpdate,
    required GestureDragEndCallback onPanEnd,
    required VoidCallback onPanCancel,
  }) {
    return Positioned(
      left: position.dx - 11,
      top: position.dy - 11,
      child: GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onPanCancel: onPanCancel,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black54, width: 2),
          ),
        ),
      ),
    );
  }
}

class _UnitLabel extends StatelessWidget {
  const _UnitLabel({required this.text});

  final String text;

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
        style: const TextStyle(
          color: Color(0xFFD0D0D0),
          fontWeight: FontWeight.bold,
          fontSize: 14,
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

class _WirePainter extends CustomPainter {
  const _WirePainter({
    required this.starts,
    required this.ends,
    required this.colors,
  });

  final List<Offset> starts;
  final List<Offset> ends;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < starts.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(starts[i], ends[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WirePainter oldDelegate) {
    return oldDelegate.starts != starts || oldDelegate.ends != ends;
  }
}

class _Level7LearningCard extends StatelessWidget {
  const _Level7LearningCard({required this.onReady});

  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2040),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2D3360), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFE27255),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Column(
              children: [
                Text(
                  'LEARNING MODULE',
                  style: TextStyle(
                    color: Color(0xFFFFE7E0),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'New Device Unlocked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'Level 7 - Redundancy',
                  style: TextStyle(
                    color: Color(0xFFFFF4F1),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                          _pill('Levels 1-3', const Color(0xFF1C2144), false),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _pill('Levels 7-9', const Color(0xFF1A2D5A), true),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Level 7 - New Device',
                  style: TextStyle(
                    color: Color(0xFFE27255),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21264A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF323767)),
                  ),
                  child: const Column(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/server.png'),
                        size: 34,
                        color: Color(0xFFE27255),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'SERVER RACK',
                        style: TextStyle(
                          color: Color(0xFFE27255),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _pill('The "Service Provider"', const Color(0xFF1E2E58), true),
                const SizedBox(height: 12),
                const Text(
                  'A Server is a powerful computer dedicated to providing data or services to other "client" computers. '
                  'Unlike a PC, servers have specialized hardware to handle many connections at once. '
                  'They are usually mounted in racks, where cabling and redundancy help keep services online.',
                  style: TextStyle(
                    color: Color(0xFFC8D5FF),
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF302D3D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF584E70)),
                  ),
                  child: const Text(
                    'FUN FACT\nSome data centers contain millions of servers, kept cool because they generate enough heat to warm a building.',
                    style: TextStyle(
                      color: Color(0xFFC5B7DF),
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onReady,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE27255),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '→ Ready to Play!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? const Color(0xFF3E5FA6) : const Color(0xFF2E345A),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: active ? const Color(0xFFE4EEFF) : const Color(0xFFA5ADCF),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
