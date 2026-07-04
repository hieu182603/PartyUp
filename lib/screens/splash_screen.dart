import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_content_provider.dart';
import '../providers/group_provider.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';
import 'group_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Load necessary database contents in the background immediately on startup
    _loadInitialData();
  }

  void _loadInitialData() async {
    Provider.of<GameContentProvider>(context, listen: false).loadContents();
    Provider.of<GroupProvider>(context, listen: false).loadGroups();

    // Initialize Audio Service and start Background Music
    await AudioService.instance.init();
    await AudioService.instance.playBGM();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3F1FF), // Soft lavender
              Color(0xFFFFFFFF), // Pristine white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background cloud/confetti decorations
            Positioned.fill(
              child: CustomPaint(
                painter: SplashBackgroundPainter(),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.08),

                    // ========== 3D LOGO GRAPHIC ==========
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: Center(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 340,
                                  maxHeight: 340,
                                ),
                                child: Image.asset(
                                  'assets/images/imgnen.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ========== TEXT CONTENT ==========
                    const Text(
                      'Một trò chơi. Vô vàn khoảnh khắc.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A), // Slate 900
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(
                            text: 'Thật ',
                            style: TextStyle(color: Color(0xFFFF5B7F)),
                          ),
                          TextSpan(
                            text: 'hay ',
                            style: TextStyle(color: Color(0xFFFFB800)),
                          ),
                          TextSpan(
                            text: 'Thách?',
                            style: TextStyle(color: Color(0xFF7C5CFF)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Cùng bạn bè khám phá những thử thách thú vị và bùng nổ niềm vui!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569), // Slate 600
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // ========== BUTTONS ==========
                    // Button 1: Bắt đầu ngay
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: Container(
                        height: 58,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7C5CFF),
                              Color(0xFF5A3DFF),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(29),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C5CFF).withOpacity(0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 6,
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF7C5CFF),
                                  size: 26,
                                ),
                              ),
                            ),
                            const Text(
                              'Bắt đầu ngay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Button 2: Chơi cùng bạn bè
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GroupSetupScreen()),
                        );
                      },
                      child: Container(
                        height: 58,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(29),
                          border: Border.all(
                            color: const Color(0xFF7C5CFF).withOpacity(0.18),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: Color(0xFF7C5CFF),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Chơi cùng bạn bè',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Background painter for SplashScreen matching the style
class SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12345);

    // 1. Glow spots
    final glowPaint = Paint()..style = PaintingStyle.fill;
    glowPaint.color = const Color(0xFF7C5CFF).withOpacity(0.04);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 150, glowPaint);
    glowPaint.color = const Color(0xFFFF5B7F).withOpacity(0.03);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.65), 180, glowPaint);

    // 2. Clouds at the bottom
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.65);

    final cloudPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.84, size.width * 0.35, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.92, size.width * 0.75, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.83, size.width, size.height * 0.87)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(cloudPath, cloudPaint);

    final cloudPaint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.45);

    final cloudPath2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.91)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.87, size.width * 0.5, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.95, size.width, size.height * 0.9)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(cloudPath2, cloudPaint2);

    // 3. Scattered confetti wiggles/stars
    final confettiColors = [
      const Color(0xFF7C5CFF), // Purple
      const Color(0xFFFF5B7F), // Pink
      const Color(0xFFFFD54F), // Yellow/Gold
      const Color(0xFF3DD99F), // Mint Green
    ];

    for (int i = 0; i < 20; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height * 0.8;

      double distToCenter = math.sqrt(math.pow(x - size.width / 2, 2) + math.pow(y - size.height / 2, 2));
      if (distToCenter < 120) continue;

      final color = confettiColors[random.nextInt(confettiColors.length)].withOpacity(0.35);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;

      int shapeType = random.nextInt(3);
      double scale = 4.0 + random.nextDouble() * 5.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * math.pi);

      if (shapeType == 0) {
        _drawSparkle(canvas, Offset.zero, scale, paint);
      } else if (shapeType == 1) {
        final rrect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: scale * 1.8, height: scale * 0.7),
          Radius.circular(scale * 0.35),
        );
        canvas.drawRRect(rrect, paint);
      } else {
        final crossPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..color = color;
        canvas.drawLine(Offset(-scale * 0.6, 0), Offset(scale * 0.6, 0), crossPaint);
        canvas.drawLine(Offset(0, -scale * 0.6), Offset(0, scale * 0.6), crossPaint);
      }
      canvas.restore();
    }
  }

  void _drawSparkle(Canvas canvas, Offset offset, double s, Paint paint) {
    final path = Path()
      ..moveTo(offset.dx, offset.dy - s)
      ..quadraticBezierTo(offset.dx, offset.dy, offset.dx + s, offset.dy)
      ..quadraticBezierTo(offset.dx, offset.dy, offset.dx, offset.dy + s)
      ..quadraticBezierTo(offset.dx, offset.dy, offset.dx - s, offset.dy)
      ..quadraticBezierTo(offset.dx, offset.dy, offset.dx, offset.dy - s)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
