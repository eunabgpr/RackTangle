import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:racktangle/Levels/Level5.dart';

class Level4Screen extends StatefulWidget {
  const Level4Screen({super.key});

  @override
  State<Level4Screen> createState() => _Level4ScreenState();
}

class _Level4ScreenState extends State<Level4Screen> {
  static const Color _backgroundColor = Color(0xFF171725);
  static const Color _outlineColor = Color(0xFFD0D0D0);

  static const double _buttonSize = 40;
  static const double _buttonRadius = 10;
  static const double _buttonOuterPadding = 10;

  static const List<double> _routerPortX = [0.35, 0.47, 0.59, 0.72];
  static const double _routerPortY = 0.70;
  static const List<double> _hubPortX = [0.40, 0.50, 0.60, 0.72];
  static const double _hubPortY = 0.62;
  static const List<double> _cpuPortX = [0.18, 0.18, 0.18, 0.18];
  static const List<double> _cpuPortY = [0.24, 0.38, 0.52, 0.66];

  static const double _routerLabelX = 0.37;
  static const double _routerLabelY = 0.40;
  static const double _hubLabelX = 0.90;
  static const double _hubLabelY = 0.40;
  static const double _cpuLabelXOffset = -45;
  static const double _cpuLabelY = 0.42;

  static const List<Color> _wireColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.amber,
  ];

  final GlobalKey _stackKey = GlobalKey();

  List<int> _upperRouterPortByWire = [1, 2];
  final List<int> _upperHubPortByWire = [1, 0];
  List<int> _lowerHubPortByWire = [2, 3];
  List<int> _lowerCpuPortByWire = [3, 2];
  int? _draggingWire;
  Offset? _dragPosition;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _levelCleared = false;
  bool _showingClearDialog = false;
  bool _isPaused = false;
  int _currentCrossingCount = 0;
  bool _showPrePlayModule = true;

  @override
  void initState() {
    super.initState();
    _isPaused = true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      _upperRouterPortByWire = [1, 2];
      _lowerHubPortByWire = [2, 3];
      _lowerCpuPortByWire = [3, 2];
      _draggingWire = null;
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
                  'LEVEL 4',
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
                  'LEVEL 4',
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
                        value: '4',
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
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const Level5Screen(),
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await _showCompletionDialog();
    });
  }

  void _moveWireToPort(int wireIndex, int targetPort,
      {required bool moveStartSide}) {
    final upperWireCount = _upperRouterPortByWire.length;
    if (wireIndex < upperWireCount) {
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
    final lowerWireIndex = wireIndex - upperWireCount;
    if (moveStartSide) {
      if (_lowerHubPortByWire[lowerWireIndex] == targetPort) {
        return;
      }
      final otherWire = _lowerHubPortByWire.indexOf(targetPort);
      setState(() {
        if (otherWire != -1 && otherWire != lowerWireIndex) {
          final current = _lowerHubPortByWire[lowerWireIndex];
          _lowerHubPortByWire[lowerWireIndex] = targetPort;
          _lowerHubPortByWire[otherWire] = current;
        } else {
          _lowerHubPortByWire[lowerWireIndex] = targetPort;
        }
      });
      return;
    }

    if (_lowerCpuPortByWire[lowerWireIndex] == targetPort) {
      return;
    }
    final otherWire = _lowerCpuPortByWire.indexOf(targetPort);
    setState(() {
      if (otherWire != -1 && otherWire != lowerWireIndex) {
        final current = _lowerCpuPortByWire[lowerWireIndex];
        _lowerCpuPortByWire[lowerWireIndex] = targetPort;
        _lowerCpuPortByWire[otherWire] = current;
      } else {
        _lowerCpuPortByWire[lowerWireIndex] = targetPort;
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

  void _onWireDragStart(int wireIndex, DragStartDetails details) {
    final local = _toStackLocal(details.globalPosition);
    if (local == null) {
      return;
    }
    setState(() {
      _draggingWire = wireIndex;
      _dragPosition = local;
    });
  }

  void _onWireDragUpdate(
      int wireIndex, DragUpdateDetails details, List<Offset> routerPorts) {
    final local = _toStackLocal(details.globalPosition);
    if (local == null || _draggingWire != wireIndex) {
      return;
    }
    setState(() {
      _dragPosition = local;
    });
  }

  void _onWireDragEnd(int wireIndex, List<Offset> ports,
      {required bool moveStartSide}) {
    final drop = _dragPosition;
    if (drop != null) {
      final targetPort = _nearestPortIndex(drop, ports);
      _moveWireToPort(wireIndex, targetPort, moveStartSide: moveStartSide);
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
              onPressed: () => Navigator.of(context).pop(),
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
          'Level 4',
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

            final routerWidth = math.min(width * 0.62, 260.0);
            final routerLeft = (width - routerWidth) / 2;
            final routerTop = 38.0;

            final hubWidth = math.min(width * 0.48, 210.0);
            final hubLeft = (width - hubWidth) / 2;
            final hubTop = math.min(height * 0.36, 240.0);

            final cpuWidth = math.min(width * 0.72, 280.0);
            final cpuLeft = (width - cpuWidth) / 2 + 10;
            final cpuTop = math.min(height * 0.66, height - 240);

            final routerPorts = List<Offset>.generate(
              _routerPortX.length,
              (i) => Offset(
                routerLeft + (routerWidth * _routerPortX[i]),
                routerTop + (routerWidth * _routerPortY),
              ),
            );

            final hubPorts = List<Offset>.generate(
              _hubPortX.length,
              (i) => Offset(
                hubLeft + (hubWidth * _hubPortX[i]),
                hubTop + (hubWidth * _hubPortY),
              ),
            );

            final cpuPorts = List<Offset>.generate(
              _cpuPortX.length,
              (i) => Offset(
                cpuLeft + (cpuWidth * _cpuPortX[i]),
                cpuTop + (cpuWidth * _cpuPortY[i]),
              ),
            );

            final upperWireStarts = _upperRouterPortByWire
                .map((i) => routerPorts[i])
                .toList(growable: false);
            final upperWireEnds = _upperHubPortByWire
                .map((i) => hubPorts[i])
                .toList(growable: false);
            final lowerWireStarts = _lowerHubPortByWire
                .map((i) => hubPorts[i])
                .toList(growable: false);
            final lowerWireEnds = _lowerCpuPortByWire
                .map((i) => cpuPorts[i])
                .toList(growable: false);

            final wireStarts = <Offset>[...upperWireStarts, ...lowerWireStarts];
            final wireEnds = <Offset>[...upperWireEnds, ...lowerWireEnds];

            if (_draggingWire != null && _dragPosition != null) {
              if (_draggingWire! < _upperRouterPortByWire.length) {
                wireStarts[_draggingWire!] = _dragPosition!;
              } else {
                wireEnds[_draggingWire!] = _dragPosition!;
              }
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
                  top: routerTop,
                  left: routerLeft,
                  child: Image.asset('assets/images/modem.png',
                      width: routerWidth),
                ),
                Positioned(
                  top: routerTop + (routerWidth * _routerLabelY),
                  left: routerLeft + (routerWidth * _routerLabelX),
                  child: _UnitLabel(
                    text: 'Router',
                    textStyle:
                        TextStyle(fontSize: 12, color: const Color(0xFFD0D0D0)),
                  ),
                ),
                Positioned(
                  top: hubTop,
                  left: hubLeft,
                  child: Image.asset('assets/images/hub.png', width: hubWidth),
                ),
                Positioned(
                  top: hubTop + (hubWidth * _hubLabelY),
                  left: hubLeft + (hubWidth * _hubLabelX),
                  child: _UnitLabel(
                    text: 'Hub',
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
                    painter: _WirePainter(
                      starts: wireStarts,
                      ends: wireEnds,
                      colors: _wireColors,
                    ),
                  ),
                ),
                for (var i = 0; i < routerPorts.length; i++)
                  Positioned(
                    left: routerPorts[i].dx - 8,
                    top: routerPorts[i].dy - 8,
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
                for (var i = 0; i < hubPorts.length; i++)
                  Positioned(
                    left: hubPorts[i].dx - 8,
                    top: hubPorts[i].dy - 8,
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
                for (var wire = 0; wire < _upperRouterPortByWire.length; wire++)
                  Positioned(
                    left: wireStarts[wire].dx - 11,
                    top: wireStarts[wire].dy - 11,
                    child: GestureDetector(
                      onPanStart: (details) => _onWireDragStart(wire, details),
                      onPanUpdate: (details) =>
                          _onWireDragUpdate(wire, details, routerPorts),
                      onPanEnd: (_) => _onWireDragEnd(
                        wire,
                        routerPorts,
                        moveStartSide: true,
                      ),
                      onPanCancel: () => _onWireDragEnd(
                        wire,
                        routerPorts,
                        moveStartSide: true,
                      ),
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
                for (var wire = 0; wire < _lowerHubPortByWire.length; wire++)
                  Positioned(
                    left:
                        wireEnds[wire + _upperRouterPortByWire.length].dx - 11,
                    top: wireEnds[wire + _upperRouterPortByWire.length].dy - 11,
                    child: GestureDetector(
                      onPanStart: (details) => _onWireDragStart(
                          wire + _upperRouterPortByWire.length, details),
                      onPanUpdate: (details) => _onWireDragUpdate(
                          wire + _upperRouterPortByWire.length,
                          details,
                          cpuPorts),
                      onPanEnd: (_) => _onWireDragEnd(
                        wire + _upperRouterPortByWire.length,
                        cpuPorts,
                        moveStartSide: false,
                      ),
                      onPanCancel: () => _onWireDragEnd(
                        wire + _upperRouterPortByWire.length,
                        cpuPorts,
                        moveStartSide: false,
                      ),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color:
                              _wireColors[wire + _upperRouterPortByWire.length],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black54, width: 2),
                        ),
                      ),
                    ),
                  ),
                for (var wire = 0; wire < _upperRouterPortByWire.length; wire++)
                  Positioned(
                    left: upperWireEnds[wire].dx - 10,
                    top: upperWireEnds[wire].dy - 10,
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
                for (var wire = 0; wire < _lowerHubPortByWire.length; wire++)
                  Positioned(
                    left: lowerWireStarts[wire].dx - 10,
                    top: lowerWireStarts[wire].dy - 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color:
                            _wireColors[wire + _upperRouterPortByWire.length],
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
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: _PrePlayLearningCard(
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
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < starts.length; i++) {
      paint.color = colors[i % colors.length];
      canvas.drawLine(starts[i], ends[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WirePainter oldDelegate) {
    return oldDelegate.starts != starts ||
        oldDelegate.ends != ends ||
        oldDelegate.colors != colors;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF424579),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB7B9DA),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrePlayLearningCard extends StatelessWidget {
  const _PrePlayLearningCard({required this.onReady});

  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: const Color(0xFF171A34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3A3E66)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0BBFA7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: const Column(
              children: [
                Text(
                  'LEARNING MODULE',
                  style: TextStyle(
                    color: Color(0xFFD7FFFB),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'New Device Unlocked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Level 4 - Hub',
                  style: TextStyle(
                    color: Color(0xFFD7FFFB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D2455),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF3F4A8A)),
                        ),
                        child: const Text(
                          'Levels 1-3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF30375F)),
                        ),
                        child: const Text(
                          'Levels 4-6',
                          style: TextStyle(
                            color: Color(0xFF7C83AB),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '• Level 4 - New Device',
                    style: TextStyle(
                      color: Color(0xFF8D92B7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1E3A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2F3561)),
                  ),
                  child: const Column(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/hub.png'),
                        size: 34,
                        color: Color(0xFF0BBFA7),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'NETWORK HUB',
                        style: TextStyle(
                          color: Color(0xFF0BBFA7),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D2142),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30375F)),
                  ),
                  child: const Text(
                    'A Hub connects multiple Ethernet devices together. It runs on Layer 1 (Physical Layer) of the OSI model. When data arrives at one port, it is copied and blasted to every other port, which can cause collisions and slow the whole network down.',
                    style: TextStyle(
                      color: Color(0xFF9DA4C7),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                      fontSize: 13,
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
                      backgroundColor: const Color(0xFF0BBFA7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      '→ Ready to Play!',
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
        ],
      ),
    );
  }
}
