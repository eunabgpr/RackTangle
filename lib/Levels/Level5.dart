import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:racktangle/Levels/Level6.dart';

class Level5Screen extends StatefulWidget {
  const Level5Screen({super.key});

  @override
  State<Level5Screen> createState() => _Level5ScreenState();
}

class _Level5ScreenState extends State<Level5Screen> {
  static const Color _backgroundColor = Color(0xFF171725);
  static const Color _outlineColor = Color(0xFFD0D0D0);

  static const double _buttonSize = 40;
  static const double _buttonRadius = 10;
  static const double _buttonOuterPadding = 10;

  static const List<double> _routerPortX = [0.36, 0.48, 0.60, 0.72];
  static const double _routerPortY = 0.69;

  static const List<double> _switchPortX = [0.20, 0.38, 0.56, 0.72];
  static const double _switchPortY = 0.62;

  static const List<double> _leftCpuPortX = [0.72, 0.72, 0.72];
  static const List<double> _leftCpuPortY = [0.47, 0.57, 0.67];
  static const List<double> _rightCpuPortX = [0.28, 0.28, 0.28];
  static const List<double> _rightCpuPortY = [0.48, 0.58, 0.67];

  static const double _routerLabelX = 0.33;
  static const double _routerLabelY = 0.40;
  static const double _switchLabelX = 1.10;
  static const double _switchLabelY = 0.40;
  static const double _cpuLabelX = 0.63;

  static const List<Color> _wireColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.orangeAccent,
  ];

  final GlobalKey _stackKey = GlobalKey();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // 0-1: router -> switch, draggable on router
  List<int> _upperRouterPortByWire = [0, 1];
  final List<int> _upperSwitchPortByWire = [1, 0];

  // 2-3: switch -> cpu, draggable on switch
  List<int> _middleSwitchPortByWire = [3, 2];
  final List<int> _middleTargetByWire = [1, 0]; // 0 right cpu, 1 left cpu
  List<int> _middleCpuPortByWire = [2, 1];

  // 4: left cpu -> right cpu, draggable on left cpu
  List<int> _bottomLeftCpuPortByWire = [0];
  List<int> _bottomRightCpuPortByWire = [2];

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
      _upperRouterPortByWire = [0, 1];
      _middleSwitchPortByWire = [3, 2];
      _bottomLeftCpuPortByWire = [0];
      _middleTargetByWire[0] = 1;
      _middleTargetByWire[1] = 0;
      _middleCpuPortByWire = [2, 1];
      _bottomRightCpuPortByWire = [2];
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
                  'LEVEL 5',
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
                  'LEVEL 5',
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
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      unawaited(_playSfx('sfx_button.ogg'));
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const Level6Screen(),
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
                      'Next Level',
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
      if (_upperRouterPortByWire[wireIndex] == targetPort) {
        return;
      }
      final otherWire = _upperRouterPortByWire.indexOf(targetPort);
      setState(() {
        if (otherWire != -1 && otherWire != wireIndex) {
          final current = _upperRouterPortByWire[wireIndex];
          _upperRouterPortByWire[wireIndex] = targetPort;
          _upperRouterPortByWire[otherWire] = current;
        } else {
          _upperRouterPortByWire[wireIndex] = targetPort;
        }
      });
      return;
    }

    if (wireIndex < 4) {
      final middleWire = wireIndex - 2;
      if (_middleSwitchPortByWire[middleWire] == targetPort) {
        return;
      }
      final otherWire = _middleSwitchPortByWire.indexOf(targetPort);
      setState(() {
        if (otherWire != -1 && otherWire != middleWire) {
          final current = _middleSwitchPortByWire[middleWire];
          _middleSwitchPortByWire[middleWire] = targetPort;
          _middleSwitchPortByWire[otherWire] = current;
        } else {
          _middleSwitchPortByWire[middleWire] = targetPort;
        }
      });
      return;
    }

    if (_bottomLeftCpuPortByWire[0] == targetPort) {
      return;
    }
    _bottomLeftCpuPortByWire[0] = targetPort;
    setState(() {});
  }

  void _moveWireEndToPort(int wireIndex, int targetPort) {
    if (wireIndex < 2) {
      return;
    }

    if (wireIndex < 4) {
      final middleWire = wireIndex - 2;
      final rightPortCount = _rightCpuPortX.length;
      final targetSide = targetPort < rightPortCount ? 0 : 1;
      final targetCpuPort =
          targetSide == 0 ? targetPort : targetPort - rightPortCount;

      if (_middleTargetByWire[middleWire] == targetSide &&
          _middleCpuPortByWire[middleWire] == targetCpuPort) {
        return;
      }
      _middleTargetByWire[middleWire] = targetSide;
      _middleCpuPortByWire[middleWire] = targetCpuPort;
      setState(() {});
      return;
    }

    if (_bottomRightCpuPortByWire[0] == targetPort) {
      return;
    }
    _bottomRightCpuPortByWire[0] = targetPort;
    setState(() {});
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
    int? previousPort;
    if (dragEnd) {
      if (wireIndex >= 2 && wireIndex < 4) {
        final middleWire = wireIndex - 2;
        previousPort = _middleTargetByWire[middleWire] == 0
            ? _middleCpuPortByWire[middleWire]
            : _rightCpuPortX.length + _middleCpuPortByWire[middleWire];
      } else if (wireIndex == 4) {
        previousPort = _bottomRightCpuPortByWire[0];
      }
    } else {
      if (wireIndex < 2) {
        previousPort = _upperRouterPortByWire[wireIndex];
      } else if (wireIndex < 4) {
        previousPort = _middleSwitchPortByWire[wireIndex - 2];
      } else if (wireIndex == 4) {
        previousPort = _bottomLeftCpuPortByWire[0];
      }
    }
    if (drop != null) {
      final targetPort = _nearestPortIndex(drop, ports);
      if (dragEnd) {
        _moveWireEndToPort(wireIndex, targetPort);
      } else {
        _moveWireToPort(wireIndex, targetPort);
      }
      if (previousPort != null && targetPort != previousPort) {
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
          'Level 5',
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

            final routerWidth = math.min(width * 0.56, 230.0);
            final routerLeft = (width - routerWidth) / 2;
            final routerTop = 54.0;

            final switchWidth = math.min(width * 0.56, 150.0);
            final switchLeft = (width - switchWidth) / 2;
            final switchTop = math.min(height * 0.43, 250.0);

            final leftCpuWidth = math.min(width * 0.62, 220.0);
            final rightCpuWidth = math.min(width * 0.62, 220.0);
            final leftCpuLeft = math.max(2.0, (width / 2) - leftCpuWidth - 18);
            final rightCpuLeft =
                math.min(width - rightCpuWidth - 2, (width / 2) + 18);
            final cpuTop = math.min(
              height * 0.67,
              height - math.max(leftCpuWidth, rightCpuWidth) - 20,
            );

            final routerPorts = List<Offset>.generate(
              _routerPortX.length,
              (i) => Offset(
                routerLeft + (routerWidth * _routerPortX[i]),
                routerTop + (routerWidth * _routerPortY),
              ),
            );
            final switchPorts = List<Offset>.generate(
              _switchPortX.length,
              (i) => Offset(
                switchLeft + (switchWidth * _switchPortX[i]),
                switchTop + (switchWidth * _switchPortY),
              ),
            );
            final leftCpuPorts = List<Offset>.generate(
              _leftCpuPortX.length,
              (i) => Offset(
                leftCpuLeft + (leftCpuWidth * _leftCpuPortX[i]),
                cpuTop + (leftCpuWidth * _leftCpuPortY[i]),
              ),
            );
            final rightCpuPorts = List<Offset>.generate(
              _rightCpuPortX.length,
              (i) => Offset(
                rightCpuLeft + (rightCpuWidth * _rightCpuPortX[i]),
                cpuTop + (rightCpuWidth * _rightCpuPortY[i]),
              ),
            );

            final upperStarts = _upperRouterPortByWire
                .map((i) => routerPorts[i])
                .toList(growable: false);
            final upperEnds = _upperSwitchPortByWire
                .map((i) => switchPorts[i])
                .toList(growable: false);

            final middleStarts = _middleSwitchPortByWire
                .map((i) => switchPorts[i])
                .toList(growable: false);
            final middleEnds = List<Offset>.generate(2, (i) {
              if (_middleTargetByWire[i] == 0) {
                return rightCpuPorts[_middleCpuPortByWire[i]];
              }
              return leftCpuPorts[_middleCpuPortByWire[i]];
            });

            final bottomStarts = _bottomLeftCpuPortByWire
                .map((i) => leftCpuPorts[i])
                .toList(growable: false);
            final bottomEnds = _bottomRightCpuPortByWire
                .map((i) => rightCpuPorts[i])
                .toList(growable: false);

            final cpuDropPorts = <Offset>[...rightCpuPorts, ...leftCpuPorts];

            final wireStarts = <Offset>[
              ...upperStarts,
              ...middleStarts,
              ...bottomStarts
            ];
            final wireEnds = <Offset>[
              ...upperEnds,
              ...middleEnds,
              ...bottomEnds
            ];

            if (_draggingWire != null && _dragPosition != null) {
              if (_draggingWireEnd) {
                wireEnds[_draggingWire!] = _dragPosition!;
              } else {
                wireStarts[_draggingWire!] = _dragPosition!;
              }
            }

            final crossingCount = _crossingsFromLines(wireStarts, wireEnds);
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
                  top: routerTop,
                  left: routerLeft,
                  child: Image.asset('assets/images/modem.png',
                      width: routerWidth),
                ),
                Positioned(
                  top: routerTop + (routerWidth * _routerLabelY),
                  left: routerLeft + (routerWidth * _routerLabelX),
                  child: const _UnitLabel(text: 'Router'),
                ),
                Positioned(
                  top: switchTop,
                  left: switchLeft,
                  child: Image.asset('assets/images/switch.png',
                      width: switchWidth),
                ),
                Positioned(
                  top: switchTop + (switchWidth * _switchLabelY),
                  left: switchLeft + (switchWidth * _switchLabelX),
                  child: const _UnitLabel(text: 'Switch'),
                ),
                Positioned(
                  top: cpuTop,
                  left: leftCpuLeft,
                  child: Image.asset('assets/images/leftCPU.png',
                      width: leftCpuWidth),
                ),
                Positioned(
                  top: cpuTop,
                  left: rightCpuLeft,
                  child: Image.asset('assets/images/rightCPU.png',
                      width: rightCpuWidth),
                ),
                Positioned(
                  top: cpuTop - 30,
                  left: (width * _cpuLabelX),
                  child: const _UnitLabel(text: 'CPU'),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WirePainter(
                      starts: wireStarts,
                      ends: wireEnds,
                      colors: _wireColors,
                    ),
                  ),
                ),
                for (var i = 0; i < routerPorts.length; i++)
                  _ghostPort(routerPorts[i]),
                for (var i = 0; i < switchPorts.length; i++)
                  _ghostPort(switchPorts[i]),
                for (var i = 0; i < leftCpuPorts.length; i++)
                  _ghostPort(leftCpuPorts[i]),
                for (var i = 0; i < rightCpuPorts.length; i++)
                  _ghostPort(rightCpuPorts[i]),

                // Draggable starts: wires 0-1 on router
                for (var wire = 0; wire < 2; wire++)
                  _dragHandle(
                    position: wireStarts[wire],
                    color: _wireColors[wire],
                    onPanStart: (details) => _onWireDragStart(wire, details),
                    onPanUpdate: (details) => _onWireDragUpdate(wire, details),
                    onPanEnd: (_) => _onWireDragEnd(wire, routerPorts),
                    onPanCancel: () => _onWireDragEnd(wire, routerPorts),
                  ),

                // Draggable starts: wires 2-3 on switch
                for (var wire = 2; wire < 4; wire++)
                  _dragHandle(
                    position: wireStarts[wire],
                    color: _wireColors[wire],
                    onPanStart: (details) => _onWireDragStart(wire, details),
                    onPanUpdate: (details) => _onWireDragUpdate(wire, details),
                    onPanEnd: (_) => _onWireDragEnd(wire, switchPorts),
                    onPanCancel: () => _onWireDragEnd(wire, switchPorts),
                  ),

                // Draggable ends: wires 2-3 on cpu
                for (var wire = 2; wire < 4; wire++)
                  _dragHandle(
                    position: wireEnds[wire],
                    color: _wireColors[wire],
                    onPanStart: (details) =>
                        _onWireDragStart(wire, details, dragEnd: true),
                    onPanUpdate: (details) => _onWireDragUpdate(wire, details),
                    onPanEnd: (_) => _onWireDragEnd(
                      wire,
                      cpuDropPorts,
                      dragEnd: true,
                    ),
                    onPanCancel: () => _onWireDragEnd(
                      wire,
                      cpuDropPorts,
                      dragEnd: true,
                    ),
                  ),

                // Draggable start: wire 4 on left cpu
                _dragHandle(
                  position: wireStarts[4],
                  color: _wireColors[4],
                  onPanStart: (details) => _onWireDragStart(4, details),
                  onPanUpdate: (details) => _onWireDragUpdate(4, details),
                  onPanEnd: (_) => _onWireDragEnd(4, leftCpuPorts),
                  onPanCancel: () => _onWireDragEnd(4, leftCpuPorts),
                ),

                // Draggable end: wire 4 on right cpu
                _dragHandle(
                  position: wireEnds[4],
                  color: _wireColors[4],
                  onPanStart: (details) =>
                      _onWireDragStart(4, details, dragEnd: true),
                  onPanUpdate: (details) => _onWireDragUpdate(4, details),
                  onPanEnd: (_) =>
                      _onWireDragEnd(4, rightCpuPorts, dragEnd: true),
                  onPanCancel: () =>
                      _onWireDragEnd(4, rightCpuPorts, dragEnd: true),
                ),

                // Fixed colorful ends
                for (var wire = 0; wire < 2; wire++)
                  Positioned(
                    left: wireEnds[wire].dx - 10,
                    top: wireEnds[wire].dy - 10,
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
                        child: _PrePlayLearningCard(
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
        ..strokeWidth = 6
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

class _PrePlayLearningCard extends StatelessWidget {
  const _PrePlayLearningCard({required this.onReady});

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
            child: Column(
              children: const [
                Text(
                  'LEARNING MODULE',
                  style: TextStyle(
                    color: Color(0xFFB8FFF2),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'New Device Unlocked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Level 5 - Switch',
                  style: TextStyle(
                    color: Color(0xFFE0FFFA),
                    fontSize: 22,
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
                  'Level 5 - New Device',
                  style: TextStyle(
                    color: Color(0xFF29D9C0),
                    fontSize: 20,
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
                        AssetImage('assets/images/switch.png'),
                        size: 34,
                        color: Color(0xFF0BBFA7),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'NETWORK SWITCH',
                        style: TextStyle(
                          color: Color(0xFF0BBFA7),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _pill('The "Traffic Cop"', const Color(0xFF1E2E58), true),
                const SizedBox(height: 12),
                const Text(
                  'A Switch is smarter than a Hub. It runs on Layer 2 (Data Link Layer). '
                  'It records the unique MAC address of every connected device in a table. '
                  'When data arrives, the switch sends the packet only to the specific port.',
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
                    '💡 FUN FACT\nHubs are half-duplex — they can\'t send and receive at the same time. Like a walkie-talkie!',
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
