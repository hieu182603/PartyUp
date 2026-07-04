import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/player_provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../core/theme/app_colors.dart';
import 'truth_or_dare_choice_screen.dart';

class RandomPlayerScreen extends StatefulWidget {
  const RandomPlayerScreen({super.key});

  @override
  State<RandomPlayerScreen> createState() => _RandomPlayerScreenState();
}

class _RandomPlayerScreenState extends State<RandomPlayerScreen> with TickerProviderStateMixin {
  int _activeCountdown = 3;
  late AnimationController _confettiController;
  late AnimationController _avatarScaleController;

  @override
  void initState() {
    super.initState();
    // Choose the player immediately at start
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    todProvider.selectRandomPlayer(playerProvider.players);

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _avatarScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _avatarScaleController.forward();
    _startCountdownSequence();
  }

  void _startCountdownSequence() async {
    // 3 -> 2 -> 1
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _activeCountdown = 2);
    
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _activeCountdown = 1);

    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _activeCountdown = 0);
      
      // Auto navigate to the choice screen after selection is shown
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TruthOrDareChoiceScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _avatarScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);
    final currentPlayer = todProvider.currentPlayer;

    if (currentPlayer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Người tiếp theo là',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 24, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Custom Confetti falling particles in the background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(progress: _confettiController.value),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Crowned Avatar with scaling animation
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _avatarScaleController,
                    curve: Curves.elasticOut,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Avatar circle with border
                      Container(
                        width: 160,
                        height: 160,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF9D5CFF), width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9D5CFF).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: Container(
                            color: Colors.white,
                            child: Image.network(
                              'https://api.dicebear.com/7.x/lorelei/png?seed=${currentPlayer.name}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // 3D Cartoon Gold Crown on top right
                      Positioned(
                        top: -24,
                        right: -10,
                        child: Transform.rotate(
                          angle: 18 * math.pi / 180, // Rotate slightly
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CustomPaint(
                              painter: CrownPainter(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Player Name
                Text(
                  currentPlayer.name,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(flex: 1),
                // Single dynamic countdown indicator
                if (_activeCountdown > 0)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7C5CFF), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C5CFF).withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          '$_activeCountdown',
                          key: ValueKey<int>(_activeCountdown),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7C5CFF),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3DD99F), Color(0xFF30C28D)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3DD99F).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'BẮT ĐẦU!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a 3D-like cartoon crown
class CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint goldPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    final Paint shadowPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.fill;

    final Paint jewelPaint = Paint()
      ..color = const Color(0xFFFF5B7F)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw crown shadow/base back
    final Path backPath = Path()
      ..moveTo(w * 0.1, h * 0.75)
      ..lineTo(w * 0.05, h * 0.45)
      ..lineTo(w * 0.3, h * 0.55)
      ..lineTo(w * 0.5, h * 0.35)
      ..lineTo(w * 0.7, h * 0.55)
      ..lineTo(w * 0.95, h * 0.45)
      ..lineTo(w * 0.9, h * 0.75)
      ..close();
    canvas.drawPath(backPath, shadowPaint);

    // Draw main gold crown front
    final Path frontPath = Path()
      ..moveTo(w * 0.15, h * 0.7)
      ..lineTo(w * 0.08, h * 0.48)
      ..lineTo(w * 0.32, h * 0.58)
      ..lineTo(w * 0.5, h * 0.38)
      ..lineTo(w * 0.68, h * 0.58)
      ..lineTo(w * 0.92, h * 0.48)
      ..lineTo(w * 0.85, h * 0.7)
      ..close();
    canvas.drawPath(frontPath, goldPaint);

    // Draw base ring
    final Paint ringPaint = Paint()
      ..color = const Color(0xFFFF8F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.18, h * 0.68), Offset(w * 0.82, h * 0.68), ringPaint);

    // Draw small circles/jewels on top of peaks
    canvas.drawCircle(Offset(w * 0.08, h * 0.48), 4, jewelPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.38), 5.5, jewelPaint);
    canvas.drawCircle(Offset(w * 0.92, h * 0.48), 4, jewelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Background confetti falling particles painter
class ConfettiPainter extends CustomPainter {
  final double progress;
  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12345);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    final colors = [
      const Color(0xFFFF5B7F),
      const Color(0xFF7C5CFF),
      const Color(0xFF4FAAFF),
      const Color(0xFF3DD99F),
      const Color(0xFFFFAF36),
    ];

    for (int i = 0; i < 40; i++) {
      double startX = random.nextDouble() * size.width;
      double speed = 100 + random.nextDouble() * 200;
      double y = (progress * speed + random.nextDouble() * size.height) % size.height;

      // Add a slight horizontal sway
      double x = startX + math.sin(progress * 2 * math.pi + i) * 20;

      double sizeVal = 6 + random.nextDouble() * 8;
      paint.color = colors[random.nextInt(colors.length)].withOpacity(0.6);

      // Draw random shapes (circles, squares, triangles)
      int shape = random.nextInt(3);
      if (shape == 0) {
        // Circle
        canvas.drawCircle(Offset(x, y), sizeVal / 2, paint);
      } else if (shape == 1) {
        // Square
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: sizeVal, height: sizeVal), paint);
      } else {
        // Triangle
        final Path path = Path()
          ..moveTo(x, y - sizeVal / 2)
          ..lineTo(x + sizeVal / 2, y + sizeVal / 2)
          ..lineTo(x - sizeVal / 2, y + sizeVal / 2)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
