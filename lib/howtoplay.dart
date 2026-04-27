import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _playButtonSfx() async {
    await _sfxPlayer.play(AssetSource('sfx/sfx_button.ogg'));
  }

  static const Color _backgroundColor = Color(0xFF171725);
  static const Color _panelColor = Color(0xFF222238);
  static const Color _panelBorderColor = Color(0xFF5B5B7A);
  static const Color _accentColor = Color(0xFF7D7DB2);
  static const Color _textColor = Color(0xFFF4F4FA);
  static const Color _subtleTextColor = Color(0xFFB9B9D3);
  static const Color _ruleColor = Color(0xFF6B6B8E);

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
                    'How to Play',
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
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                decoration: BoxDecoration(
                  color: _panelColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _panelBorderColor),
                ),
                child: const Text(
                  'Untangle a network rack\'s cabling by rearranging cable endpoints so no wires cross each other.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 18,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const _StepCard(
                number: '1',
                title: 'Spot the Crossings',
                body:
                    'Cables that cross are highlighted in red. Eliminate all red crossings to complete the level.',
                accent: Color(0xFF7D7DB2),
              ),
              const SizedBox(height: 14),
              const _CrossingDemo(),
              const SizedBox(height: 14),
              const _StepCard(
                number: '2',
                title: 'Drag Endpoints',
                body:
                    'Touch and drag any cable endpoint (colored circles) to move it to a new position on the rack.',
                accent: Color(0xFF7D7DB2),
              ),
              const SizedBox(height: 14),
              const _StepCard(
                number: '3',
                title: 'Clear All Crossings',
                body:
                    'Rearrange endpoints until all cables are untangled. When no cables cross, the level is complete!',
                accent: Color(0xFF7D7DB2),
              ),
              const SizedBox(height: 14),
              const _StepCard(
                number: '4',
                title: 'Advance Levels',
                body:
                    'Each level adds more cables and complexity. How far can you go?',
                accent: Color(0xFF7D7DB2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.body,
    required this.accent,
  });

  final String number;
  final String title;
  final String body;
  final Color accent;

  static const Color _panelColor = Color(0xFF222238);
  static const Color _textColor = Color(0xFFF4F4FA);
  static const Color _subtleTextColor = Color(0xFFB9B9D3);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.85), width: 1.8),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    color: _subtleTextColor,
                    fontSize: 14,
                    height: 1.35,
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

class _CrossingDemo extends StatelessWidget {
  const _CrossingDemo();

  static const Color _panelColor = Color(0xFF222238);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96,
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF5B5B7A)),
      ),
      child: CustomPaint(
        painter: _CrossingDemoPainter(),
      ),
    );
  }
}

class _CrossingDemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final redPaint = Paint()
      ..color = const Color(0xFFE31818)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final yellowPaint = Paint()
      ..color = const Color(0xFFE8DD39)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leftTop = Offset(size.width * 0.12, size.height * 0.30);
    final leftBottom = Offset(size.width * 0.12, size.height * 0.70);
    final rightTop = Offset(size.width * 0.34, size.height * 0.30);
    final rightBottom = Offset(size.width * 0.34, size.height * 0.70);

    final yellowLeftTop = Offset(size.width * 0.62, size.height * 0.30);
    final yellowRightTop = Offset(size.width * 0.88, size.height * 0.30);
    final yellowLeftBottom = Offset(size.width * 0.62, size.height * 0.70);
    final yellowRightBottom = Offset(size.width * 0.88, size.height * 0.70);

    canvas.drawLine(leftTop, rightBottom, redPaint);
    canvas.drawLine(leftBottom, rightTop, redPaint);
    canvas.drawLine(yellowLeftTop, yellowRightTop, yellowPaint);
    canvas.drawLine(yellowLeftBottom, yellowRightBottom, yellowPaint);

    _drawNode(canvas, leftTop, const Color(0xFFE31818));
    _drawNode(canvas, leftBottom, const Color(0xFFE31818));
    _drawNode(canvas, rightTop, const Color(0xFFE31818));
    _drawNode(canvas, rightBottom, const Color(0xFFE31818));
    _drawNode(canvas, yellowLeftTop, const Color(0xFFE8DD39));
    _drawNode(canvas, yellowRightTop, const Color(0xFFE8DD39));
    _drawNode(canvas, yellowLeftBottom, const Color(0xFFE8DD39));
    _drawNode(canvas, yellowRightBottom, const Color(0xFFE8DD39));
  }

  void _drawNode(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, 5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2A44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: const Color(0xFFF4F4FA),
            size: 20,
          ),
        ),
      ),
    );
  }
}
