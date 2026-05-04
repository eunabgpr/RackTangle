import 'dart:async';

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

  static const double _boardWidth = 760;
  static const double _boardHeight = 1160;

  static const List<Color> _wireColors = [
    Color(0xFF64C8FF),
    Color(0xFF39FF4A),
    Colors.redAccent,
    Colors.blueAccent,
    Color(0xFFB24DFF),
    Color(0xFFFF1ED2),
    Colors.orangeAccent,
  ];

  static const List<double> _leftPortY = [
    0.24,
    0.32,
    0.40,
    0.48,
    0.56,
    0.64,
    0.72,
  ];
  static const List<double> _rightPortY = [
    0.22,
    0.30,
    0.38,
    0.46,
    0.54,
    0.62,
    0.70,
  ];

  final GlobalKey _boardKey = GlobalKey();

  final List<int> _startPortByWire = [0, 1, 2, 3, 4, 5, 6];
  final List<int> _endPortByWire = [6, 4, 5, 3, 1, 2, 0];

  int? _draggingWire;
  Offset? _dragPosition;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isPaused = false;
  bool _showPrePlayModule = true;
  bool _levelCleared = false;
  bool _showingClearDialog = false;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _isPaused = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showLearningModulePopup();
      }
    });
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
      if (!mounted || _isPaused) {
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
    _isPaused = false;
    _startTimer();
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

  Future<void> _showLearningModulePopup() async {
    if (!_showPrePlayModule || !mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            child: _Level7LearningCard(
              onReady: () {
                Navigator.of(dialogContext).pop();
                _startLevelFromLearningCard();
              },
            ),
          ),
        );
      },
    );
  }

  void _resetLevel() {
    setState(() {
      _startPortByWire
        ..clear()
        ..addAll([0, 1, 2, 3, 4, 5, 6]);
      _endPortByWire
        ..clear()
        ..addAll([6, 4, 5, 3, 1, 2, 0]);
      _draggingWire = null;
      _dragPosition = null;
      _elapsedSeconds = 0;
      _isPaused = false;
      _levelCleared = false;
      _showingClearDialog = false;
      _hasInteracted = false;
    });
    _startTimer();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showPauseDialog(int crossingCount) async {
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
                    Navigator.of(dialogContext).pop();
                    _resetLevel();
                  },
                ),
                const SizedBox(height: 12),
                _dialogButton(
                  text: 'Back to home',
                  onPressed: () {
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

    if (shouldResume && mounted) {
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
                        value: '7',
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
                          builder: (_) => const Level8Screen(),
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

  void _checkAndHandleLevelClear(int crossingCount) {
    final allWiresPlugged = _draggingWire == null && _dragPosition == null;
    if (_levelCleared ||
        _showingClearDialog ||
        !_hasInteracted ||
        crossingCount != 0 ||
        !allWiresPlugged) {
      return;
    }
    _levelCleared = true;
    _showingClearDialog = true;
    _pauseTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await _showCompletionDialog();
    });
  }

  Offset? _toBoardLocal(Offset globalPosition) {
    final renderObject = _boardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) {
      return null;
    }
    return renderObject.globalToLocal(globalPosition);
  }

  void _onWireDragStart(int wireIndex, DragStartDetails details,
      {bool dragEnd = false}) {
    final local = _toBoardLocal(details.globalPosition);
    if (local == null) {
      return;
    }
    setState(() {
      _draggingWire = wireIndex;
      _dragPosition = local;
      _hasInteracted = true;
    });
  }

  void _onWireDragUpdate(int wireIndex, DragUpdateDetails details) {
    final local = _toBoardLocal(details.globalPosition);
    if (local == null || _draggingWire != wireIndex) {
      return;
    }
    setState(() {
      _dragPosition = local;
    });
  }

  int _nearestPortIndex(Offset point, List<Offset> ports) {
    var index = 0;
    var best = double.infinity;
    for (var i = 0; i < ports.length; i++) {
      final dx = ports[i].dx - point.dx;
      final dy = ports[i].dy - point.dy;
      final distance = (dx * dx) + (dy * dy);
      if (distance < best) {
        best = distance;
        index = i;
      }
    }
    return index;
  }

  void _moveWireToPort(int wireIndex, int targetPort, bool dragEnd) {
    if (dragEnd) {
      final current = _endPortByWire[wireIndex];
      final other = _endPortByWire.indexOf(targetPort);
      if (current == targetPort) {
        return;
      }
      setState(() {
        if (other != -1 && other != wireIndex) {
          _endPortByWire[wireIndex] = targetPort;
          _endPortByWire[other] = current;
        } else {
          _endPortByWire[wireIndex] = targetPort;
        }
      });
      return;
    }

    final current = _startPortByWire[wireIndex];
    final other = _startPortByWire.indexOf(targetPort);
    if (current == targetPort) {
      return;
    }
    setState(() {
      if (other != -1 && other != wireIndex) {
        _startPortByWire[wireIndex] = targetPort;
        _startPortByWire[other] = current;
      } else {
        _startPortByWire[wireIndex] = targetPort;
      }
    });
  }

  void _onWireDragEnd(int wireIndex, List<Offset> ports,
      {bool dragEnd = false}) {
    final drop = _dragPosition;
    if (drop != null) {
      final targetPort = _nearestPortIndex(drop, ports);
      _moveWireToPort(wireIndex, targetPort, dragEnd);
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
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(_buttonOuterPadding),
          child: _iconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(_buttonOuterPadding),
            child: _iconButton(
              icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              onTap: () {
                if (_isPaused) {
                  _resumeTimer();
                } else {
                  _showPauseDialog(_crossingsFromLines(
                    _wireStartPositions,
                    _wireEndPositions,
                  ));
                }
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        const Text(
                          'Level 7 Draft',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '- ${_crossingsFromLines(_wireStartPositions, _wireEndPositions)} Crossings',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Draft layout preview without pinch zoom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _boardWidth,
                          height: _boardHeight,
                          child: _buildBoard(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<Offset> get _wireStartPositions {
    final ports = _buildPorts();
    return [
      for (final portIndex in _startPortByWire) ports[portIndex],
    ];
  }

  List<Offset> get _wireEndPositions {
    final ports = _buildPorts();
    return [
      for (final portIndex in _endPortByWire) ports[portIndex],
    ];
  }

  List<Offset> _buildPorts() {
    final ports = <Offset>[];
    const leftX = _boardWidth * 0.18;
    const rightX = _boardWidth * 0.82;
    for (var i = 0; i < _leftPortY.length; i++) {
      ports.add(Offset(leftX, _boardHeight * _leftPortY[i]));
    }
    for (var i = 0; i < _rightPortY.length; i++) {
      ports.add(Offset(rightX, _boardHeight * _rightPortY[i]));
    }
    return ports;
  }

  Widget _buildBoard() {
    final ports = _buildPorts();
    final starts = _wireStartPositions;
    final ends = _wireEndPositions;
    final crossingCount = _crossingsFromLines(starts, ends);

    _checkAndHandleLevelClear(crossingCount);

    return Stack(
      key: _boardKey,
      children: [
        Positioned(
          top: 130,
          left: 132,
          child: Image.asset(
            'assets/images/server.png',
            width: 520,
            fit: BoxFit.contain,
          ),
        ),
        const Positioned(
          top: 114,
          left: 318,
          child: _UnitLabel(text: 'Server'),
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
        for (var i = 0; i < ports.length; i++) _ghostPort(ports[i]),
        for (var wire = 0; wire < starts.length; wire++)
          _dragHandle(
            position: starts[wire],
            color: _wireColors[wire],
            onPanStart: (details) => _onWireDragStart(wire, details),
            onPanUpdate: (details) => _onWireDragUpdate(wire, details),
            onPanEnd: (_) => _onWireDragEnd(wire, ports),
            onPanCancel: () => _onWireDragEnd(wire, ports),
          ),
        for (var wire = 0; wire < ends.length; wire++)
          _dragHandle(
            position: ends[wire],
            color: _wireColors[wire],
            onPanStart: (details) =>
                _onWireDragStart(wire, details, dragEnd: true),
            onPanUpdate: (details) => _onWireDragUpdate(wire, details),
            onPanEnd: (_) => _onWireDragEnd(wire, ports, dragEnd: true),
            onPanCancel: () => _onWireDragEnd(wire, ports, dragEnd: true),
          ),
        Positioned(
          top: 22,
          left: 24,
          child: _StatCard(
            value: _formatTime(_elapsedSeconds),
            label: 'Time',
          ),
        ),
      ],
    );
  }

  Widget _ghostPort(Offset position) {
    return Positioned(
      left: position.dx - 8,
      top: position.dy - 8,
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
        behavior: HitTestBehavior.opaque,
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

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_buttonRadius),
      child: Container(
        width: _buttonSize,
        height: _buttonSize,
        decoration: BoxDecoration(
          border: Border.all(color: _outlineColor, width: 1.4),
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
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
        ..strokeWidth = 7
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
        color: const Color(0xFF1C1E38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2D3360), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEA775A),
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
                    color: Color(0xFFFFE0D7),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _pill(
                        'Levels 1-3',
                        const Color(0xFF23284A),
                        false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _pill(
                        'Levels 7-9',
                        const Color(0xFF1D2C58),
                        true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _SectionLabel(text: '• Level 8 - New Device'),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232545),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF31365E)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.dns_rounded,
                          color: Color(0xFFEA775A), size: 34),
                      SizedBox(height: 8),
                      Text(
                        'SERVER RACK',
                        style: TextStyle(
                          color: Color(0xFFEA775A),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _Tag(text: 'The "Service Provider"'),
                const SizedBox(height: 10),
                const Text(
                  'A Server is a powerful computer dedicated to providing data or services to other "client" computers. Unlike a PC, servers have specialized hardware to handle thousands of simultaneous connections. They\'re usually mounted in Racks requiring complex cooling and cabling.',
                  style: TextStyle(
                    color: Color(0xFFBFC9F1),
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2740),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF5B4F6D)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.ac_unit, color: Color(0xFF59C6FF), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'FUN FACT\nGoogle\'s data centers have millions of servers, kept in cold rooms because they generate enough heat to warm an entire building!',
                          style: TextStyle(
                            color: Color(0xFFC8D5FF),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onReady,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA775A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFEA775A),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEA775A), width: 1.1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFEA775A),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
