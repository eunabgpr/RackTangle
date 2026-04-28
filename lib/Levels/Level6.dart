import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:racktangle/Levels/Level7.dart';

class Level6Screen extends StatefulWidget {
  const Level6Screen({super.key});

  @override
  State<Level6Screen> createState() => _Level6ScreenState();
}

class _Level6ScreenState extends State<Level6Screen> {
  static const Color _backgroundColor = Color(0xFF171725);
  static const Color _outlineColor = Color(0xFFD0D0D0);

  static const double _buttonSize = 40;
  static const double _buttonRadius = 10;
  static const double _buttonOuterPadding = 10;

  static const List<double> _routerPortX = [0.34, 0.46, 0.58, 0.70];
  static const double _routerPortY = 0.70;

  static const List<double> _leftSwitchPortX = [
    0.22,
    0.40,
    0.58,
    0.22,
    0.40,
    0.58
  ];
  static const List<double> _leftSwitchPortY = [
    0.42,
    0.42,
    0.42,
    0.62,
    0.62,
    0.62
  ];

  static const List<double> _rightSwitchPortX = [
    0.22,
    0.40,
    0.58,
    0.22,
    0.40,
    0.58
  ];
  static const List<double> _rightSwitchPortY = [
    0.42,
    0.42,
    0.42,
    0.62,
    0.62,
    0.62
  ];

  static const List<double> _leftCpuPortX = [0.72, 0.72, 0.72];
  static const List<double> _leftCpuPortY = [0.46, 0.56, 0.70];

  static const List<double> _rightCpuPortX = [0.28, 0.28, 0.28];
  static const List<double> _rightCpuPortY = [0.46, 0.56, 0.70];

  static const List<Color> _wireColors = [
    Color(0xFF64C8FF),
    Color(0xFF39FF4A),
    Colors.redAccent,
    Colors.blueAccent,
    Color(0xFFB24DFF),
    Color(0xFFFF1ED2),
    Colors.orangeAccent,
  ];

  final GlobalKey _stackKey = GlobalKey();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // 0-1 router to switches, draggable on router.
  // Blue (wire 0) starts on right; green (wire 1) starts on left.
  List<int> _routerPortByWire = [3, 0];

  // 2-5 switch starts, draggable on either switch.
  List<int> _switchStartPortByWire = [4, 1, 3, 5];

  // 6 cpu to cpu, draggable on both CPUs.
  List<int> _cpuLeftPortByWire = [0];
  List<int> _cpuRightPortByWire = [2];

  // Blue/red wires can connect to any port on either switch.
  List<int> _routerEndLeftSwitchPort = [1];
  List<int> _routerEndRightSwitchPort = [1];
  List<int> _interSwitchEndRightPort = [9, 11];
  List<int> _toRightCpuEndPort = [0];
  List<int> _toLeftCpuEndPort = [1];

  int? _draggingWire;
  bool _draggingWireEnd = false;
  Offset? _dragPosition;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _levelCleared = false;
  bool _showingClearDialog = false;
  bool _isPaused = false;
  bool _showPrePlayModule = true;

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
      _routerPortByWire = [3, 0];
      _switchStartPortByWire = [4, 1, 3, 5];
      _cpuLeftPortByWire = [0];
      _cpuRightPortByWire = [2];
      _routerEndLeftSwitchPort = [1];
      _routerEndRightSwitchPort = [1];
      _interSwitchEndRightPort = [9, 11];
      _toRightCpuEndPort = [0];
      _toLeftCpuEndPort = [1];
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
                  'LEVEL 6',
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
                _dialogButton(
                  text: 'Resume',
                  onPressed: () {
                    shouldResume = true;
                    Navigator.of(dialogContext).pop();
                  },
                ),
                const SizedBox(height: 12),
                _dialogButton(
                  text: 'Restart Level',
                  onPressed: () {
                    unawaited(_playSfx('sfx_button.ogg'));
                    Navigator.of(dialogContext).pop();
                    _resetLevel();
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

    if (shouldResume) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
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
                  'LEVEL 6',
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
                        value: '6',
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
                      MaterialPageRoute(
                        builder: (_) => const Level7Screen(),
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
    if (wireIndex < 2) {
      if (_routerPortByWire[wireIndex] == targetPort) {
        return;
      }
      final other = _routerPortByWire.indexOf(targetPort);
      setState(() {
        if (other != -1 && other != wireIndex) {
          final current = _routerPortByWire[wireIndex];
          _routerPortByWire[wireIndex] = targetPort;
          _routerPortByWire[other] = current;
        } else {
          _routerPortByWire[wireIndex] = targetPort;
        }
      });
      return;
    }

    if (wireIndex >= 2 && wireIndex <= 5) {
      final idx = wireIndex - 2;
      if (_switchStartPortByWire[idx] == targetPort) {
        return;
      }
      final other = _switchStartPortByWire.indexOf(targetPort);
      setState(() {
        if (other != -1 && other != idx) {
          final current = _switchStartPortByWire[idx];
          _switchStartPortByWire[idx] = targetPort;
          _switchStartPortByWire[other] = current;
        } else {
          _switchStartPortByWire[idx] = targetPort;
        }
      });
      unawaited(_playSfx('sfx_attach.wav'));
      return;
    }

    if (wireIndex == 6) {
      if (_cpuLeftPortByWire[0] == targetPort) {
        return;
      }
      _cpuLeftPortByWire[0] = targetPort;
      setState(() {});
      unawaited(_playSfx('sfx_attach.wav'));
    }
  }

  void _moveWireEndToPort(int wireIndex, int targetPort) {
    if (wireIndex == 0) {
      if (_routerEndLeftSwitchPort[0] == targetPort) {
        return;
      }
      _routerEndLeftSwitchPort[0] = targetPort;
      setState(() {});
      unawaited(_playSfx('sfx_attach.wav'));
      return;
    }

    if (wireIndex == 1) {
      if (_routerEndRightSwitchPort[0] == targetPort) {
        return;
      }
      _routerEndRightSwitchPort[0] = targetPort;
      setState(() {});
      unawaited(_playSfx('sfx_attach.wav'));
      return;
    }

    if (wireIndex == 2 || wireIndex == 3) {
      final idx = wireIndex - 2;
      if (_interSwitchEndRightPort[idx] == targetPort) {
        return;
      }
      final other = _interSwitchEndRightPort.indexOf(targetPort);
      setState(() {
        if (other != -1 && other != idx) {
          final current = _interSwitchEndRightPort[idx];
          _interSwitchEndRightPort[idx] = targetPort;
          _interSwitchEndRightPort[other] = current;
        } else {
          _interSwitchEndRightPort[idx] = targetPort;
        }
      });
      unawaited(_playSfx('sfx_attach.wav'));
      return;
    }

    if (wireIndex == 4) {
      if (_toRightCpuEndPort[0] == targetPort) {
        return;
      }
      _toRightCpuEndPort[0] = targetPort;
      setState(() {});
      unawaited(_playSfx('sfx_attach.wav'));
      return;
    }

    if (wireIndex == 5) {
      if (_toLeftCpuEndPort[0] == targetPort) {
        return;
      }
      _toLeftCpuEndPort[0] = targetPort;
      setState(() {});
      unawaited(_playSfx('sfx_attach.wav'));
      return;
    }

    if (wireIndex == 6) {
      if (_cpuRightPortByWire[0] == targetPort) {
        return;
      }
      _cpuRightPortByWire[0] = targetPort;
      setState(() {});
      unawaited(_playSfx('sfx_attach.wav'));
    }
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
    if (drop != null) {
      final targetPort = _nearestPortIndex(drop, ports);
      if (dragEnd) {
        _moveWireEndToPort(wireIndex, targetPort);
      } else {
        _moveWireToPort(wireIndex, targetPort);
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
          'Level 6',
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
                  _showPauseDialog(0);
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

            final routerWidth = math.min(width * 0.44, 170.0);
            final routerLeft = (width - routerWidth) / 2;
            final routerTop = 52.0;

            final switchWidth = math.min(width * 0.40, 130.0);
            final leftSwitchLeft =
                math.max(6.0, (width / 2) - switchWidth - 28);
            final rightSwitchLeft =
                math.min(width - switchWidth - 6.0, (width / 2) + 28);
            final switchTop = math.min(height * 0.41, 260.0);

            final cpuWidth = math.min(width * 0.52, 180.0);
            final leftCpuLeft = math.max(4.0, (width / 2) - cpuWidth - 22);
            final rightCpuLeft =
                math.min(width - cpuWidth - 4.0, (width / 2) + 22);
            final cpuTop = math.min(height * 0.64, height - cpuWidth - 22);

            final routerPorts = List<Offset>.generate(
              _routerPortX.length,
              (i) => Offset(
                routerLeft + (routerWidth * _routerPortX[i]),
                routerTop + (routerWidth * _routerPortY),
              ),
            );

            final leftSwitchPorts = List<Offset>.generate(
              _leftSwitchPortX.length,
              (i) => Offset(
                leftSwitchLeft + (switchWidth * _leftSwitchPortX[i]),
                switchTop + (switchWidth * _leftSwitchPortY[i]),
              ),
            );

            final rightSwitchPorts = List<Offset>.generate(
              _rightSwitchPortX.length,
              (i) => Offset(
                rightSwitchLeft + (switchWidth * _rightSwitchPortX[i]),
                switchTop + (switchWidth * _rightSwitchPortY[i]),
              ),
            );
            final switchPorts = <Offset>[
              ...leftSwitchPorts,
              ...rightSwitchPorts
            ];

            final leftCpuPorts = List<Offset>.generate(
              _leftCpuPortX.length,
              (i) => Offset(
                leftCpuLeft + (cpuWidth * _leftCpuPortX[i]),
                cpuTop + (cpuWidth * _leftCpuPortY[i]),
              ),
            );

            final rightCpuPorts = List<Offset>.generate(
              _rightCpuPortX.length,
              (i) => Offset(
                rightCpuLeft + (cpuWidth * _rightCpuPortX[i]),
                cpuTop + (cpuWidth * _rightCpuPortY[i]),
              ),
            );

            final starts = <Offset>[
              routerPorts[_routerPortByWire[0]],
              routerPorts[_routerPortByWire[1]],
              ..._switchStartPortByWire
                  .map((portIndex) => switchPorts[portIndex]),
              leftCpuPorts[_cpuLeftPortByWire[0]],
            ];

            final ends = <Offset>[
              leftSwitchPorts[_routerEndLeftSwitchPort[0]],
              rightSwitchPorts[_routerEndRightSwitchPort[0]],
              switchPorts[_interSwitchEndRightPort[0]],
              switchPorts[_interSwitchEndRightPort[1]],
              rightCpuPorts[_toRightCpuEndPort[0]],
              leftCpuPorts[_toLeftCpuEndPort[0]],
              rightCpuPorts[_cpuRightPortByWire[0]],
            ];

            if (_draggingWire != null && _dragPosition != null) {
              if (_draggingWireEnd) {
                ends[_draggingWire!] = _dragPosition!;
              } else {
                starts[_draggingWire!] = _dragPosition!;
              }
            }

            final crossingCount = _crossingsFromLines(starts, ends);
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
                              '- $crossingCount Crossings',
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
                  top: routerTop,
                  left: routerLeft,
                  child: Image.asset('assets/images/modem.png',
                      width: routerWidth),
                ),
                Positioned(
                  top: routerTop + (routerWidth * 0.40),
                  left: routerLeft + (routerWidth * 0.36),
                  child: const _UnitLabel(text: 'Router'),
                ),
                Positioned(
                  top: switchTop,
                  left: leftSwitchLeft,
                  child: Image.asset('assets/images/switch.png',
                      width: switchWidth),
                ),
                Positioned(
                  top: switchTop,
                  left: rightSwitchLeft,
                  child: Image.asset('assets/images/switch.png',
                      width: switchWidth),
                ),
                Positioned(
                  top: switchTop - 34,
                  left: (width * 0.43),
                  child: const _UnitLabel(text: 'Switch'),
                ),
                Positioned(
                  top: cpuTop,
                  left: leftCpuLeft,
                  child:
                      Image.asset('assets/images/leftCPU.png', width: cpuWidth),
                ),
                Positioned(
                  top: cpuTop,
                  left: rightCpuLeft,
                  child: Image.asset('assets/images/rightCPU.png',
                      width: cpuWidth),
                ),
                Positioned(
                  top: cpuTop - 28,
                  left: (width * 0.44),
                  child: const _UnitLabel(text: 'CPU'),
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
                for (var i = 0; i < routerPorts.length; i++)
                  _ghostPort(routerPorts[i]),
                for (var i = 0; i < leftSwitchPorts.length; i++)
                  _ghostPort(leftSwitchPorts[i]),
                for (var i = 0; i < rightSwitchPorts.length; i++)
                  _ghostPort(rightSwitchPorts[i]),
                for (var i = 0; i < leftCpuPorts.length; i++)
                  _ghostPort(leftCpuPorts[i]),
                for (var i = 0; i < rightCpuPorts.length; i++)
                  _ghostPort(rightCpuPorts[i]),

                // Draggable switch ends: wires 0-3
                _dragHandle(
                  position: ends[0],
                  color: _wireColors[0],
                  onPanStart: (details) =>
                      _onWireDragStart(0, details, dragEnd: true),
                  onPanUpdate: (details) => _onWireDragUpdate(0, details),
                  onPanEnd: (_) =>
                      _onWireDragEnd(0, switchPorts, dragEnd: true),
                  onPanCancel: () =>
                      _onWireDragEnd(0, switchPorts, dragEnd: true),
                ),
                _dragHandle(
                  position: ends[1],
                  color: _wireColors[1],
                  onPanStart: (details) =>
                      _onWireDragStart(1, details, dragEnd: true),
                  onPanUpdate: (details) => _onWireDragUpdate(1, details),
                  onPanEnd: (_) =>
                      _onWireDragEnd(1, switchPorts, dragEnd: true),
                  onPanCancel: () =>
                      _onWireDragEnd(1, switchPorts, dragEnd: true),
                ),
                _dragHandle(
                  position: ends[2],
                  color: _wireColors[2],
                  onPanStart: (details) =>
                      _onWireDragStart(2, details, dragEnd: true),
                  onPanUpdate: (details) => _onWireDragUpdate(2, details),
                  onPanEnd: (_) =>
                      _onWireDragEnd(2, switchPorts, dragEnd: true),
                  onPanCancel: () =>
                      _onWireDragEnd(2, switchPorts, dragEnd: true),
                ),
                _dragHandle(
                  position: ends[3],
                  color: _wireColors[3],
                  onPanStart: (details) =>
                      _onWireDragStart(3, details, dragEnd: true),
                  onPanUpdate: (details) => _onWireDragUpdate(3, details),
                  onPanEnd: (_) =>
                      _onWireDragEnd(3, switchPorts, dragEnd: true),
                  onPanCancel: () =>
                      _onWireDragEnd(3, switchPorts, dragEnd: true),
                ),
                for (var wire = 0; wire < 2; wire++)
                  _dragHandle(
                    position: starts[wire],
                    color: _wireColors[wire],
                    onPanStart: (details) => _onWireDragStart(wire, details),
                    onPanUpdate: (details) => _onWireDragUpdate(wire, details),
                    onPanEnd: (_) => _onWireDragEnd(wire, routerPorts),
                    onPanCancel: () => _onWireDragEnd(wire, routerPorts),
                  ),
                for (var wire = 2; wire < 6; wire++)
                  _dragHandle(
                    position: starts[wire],
                    color: _wireColors[wire],
                    onPanStart: (details) => _onWireDragStart(wire, details),
                    onPanUpdate: (details) => _onWireDragUpdate(wire, details),
                    onPanEnd: (_) => _onWireDragEnd(wire, switchPorts),
                    onPanCancel: () => _onWireDragEnd(wire, switchPorts),
                  ),

                // Draggable CPU endpoints
                _dragHandle(
                  position: ends[4],
                  color: _wireColors[4],
                  onPanStart: (details) =>
                      _onWireDragStart(4, details, dragEnd: true),
                  onPanUpdate: (details) => _onWireDragUpdate(4, details),
                  onPanEnd: (_) =>
                      _onWireDragEnd(4, rightCpuPorts, dragEnd: true),
                  onPanCancel: () =>
                      _onWireDragEnd(4, rightCpuPorts, dragEnd: true),
                ),
                _dragHandle(
                  position: ends[5],
                  color: _wireColors[5],
                  onPanStart: (details) =>
                      _onWireDragStart(5, details, dragEnd: true),
                  onPanUpdate: (details) => _onWireDragUpdate(5, details),
                  onPanEnd: (_) =>
                      _onWireDragEnd(5, leftCpuPorts, dragEnd: true),
                  onPanCancel: () =>
                      _onWireDragEnd(5, leftCpuPorts, dragEnd: true),
                ),
                _dragHandle(
                  position: starts[6],
                  color: _wireColors[6],
                  onPanStart: (details) => _onWireDragStart(6, details),
                  onPanUpdate: (details) => _onWireDragUpdate(6, details),
                  onPanEnd: (_) => _onWireDragEnd(6, leftCpuPorts),
                  onPanCancel: () => _onWireDragEnd(6, leftCpuPorts),
                ),
                _dragHandle(
                  position: ends[6],
                  color: _wireColors[6],
                  onPanStart: (details) =>
                      _onWireDragStart(6, details, dragEnd: true),
                  onPanUpdate: (details) => _onWireDragUpdate(6, details),
                  onPanEnd: (_) =>
                      _onWireDragEnd(6, rightCpuPorts, dragEnd: true),
                  onPanCancel: () =>
                      _onWireDragEnd(6, rightCpuPorts, dragEnd: true),
                ),

                for (var wire = 4; wire < 7; wire++)
                  Positioned(
                    left: ends[wire].dx - 10,
                    top: ends[wire].dy - 10,
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
                if (_showPrePlayModule)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: _Level6LearningCard(
                            onReady: _startLevelFromLearningCard),
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

class _Level6LearningCard extends StatelessWidget {
  const _Level6LearningCard({required this.onReady});

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
              color: Color(0xFF13BDA4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Column(
              children: [
                Text(
                  'LEARNING MODULE',
                  style: TextStyle(
                    color: Color(0xFFB8FFF2),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Scaling Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'Level 6 - LANs',
                  style: TextStyle(
                    color: Color(0xFFE0FFFA),
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
                      child: _pill('Levels 4-6', const Color(0xFF1A2D5A), true),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '- Level 6 - Concept',
                  style: TextStyle(
                    color: Color(0xFF29D9C0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
                      Icon(Icons.device_hub,
                          color: Color(0xFF0BBFA7), size: 34),
                      SizedBox(height: 8),
                      Text(
                        'LOCAL AREA NETWORK',
                        style: TextStyle(
                          color: Color(0xFF0BBFA7),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _pill('Introduction to LANs', const Color(0xFF1E2E58), true),
                const SizedBox(height: 12),
                const Text(
                  'A LAN is a group of computers and devices sharing a common communication line '
                  'within a small area such as an office or home. You can expand a network to support many users while maintaining high speeds.',
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
                    'FUN FACT\nOne of the largest LAN events in the world gathers thousands of gamers on a single local network.',
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
                      backgroundColor: const Color(0xFF13BDA4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '-> Ready to Play!',
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
