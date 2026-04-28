import 'package:flutter/material.dart';

class Level8Screen extends StatelessWidget {
  const Level8Screen({super.key});

  static const Color _backgroundColor = Color(0xFF171725);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Level 8',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final boardWidth = constraints.maxWidth.clamp(320.0, 860.0);
          final boardHeight =
              (constraints.maxHeight * 0.82).clamp(520.0, 980.0);

          return Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Level 8 Draft',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pinch to zoom and inspect the server rack',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.70,
                    maxScale: 2.6,
                    boundaryMargin: const EdgeInsets.all(200),
                    clipBehavior: Clip.none,
                    child: Container(
                      width: boardWidth,
                      height: boardHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D2040),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF2D3360),
                          width: 1.6,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/images/server.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            child: _pill('Level 8 Draft'),
                          ),
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: _pill('Zoom Enabled'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF235DB5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Back to home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF171725).withOpacity(0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0D0D0), width: 1.2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFD0D0D0),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
