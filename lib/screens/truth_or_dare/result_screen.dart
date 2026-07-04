import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/player_provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../core/theme/app_colors.dart';
import 'random_player_screen.dart';
import 'game_leaderboard_screen.dart';
import '../home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final todProvider = Provider.of<TruthOrDareProvider>(context);

    final round = todProvider.currentRound;
    final totalRounds = todProvider.totalRounds;
    final isGameOver = round >= totalRounds;

    // Correct/skips in this round
    final correct = todProvider.correctCount;
    final skip = todProvider.skipCount;
    final points = todProvider.pointsGained;

    // Get current main player score
    final currentPlayerObj = playerProvider.players.firstWhere(
      (p) => p.id == todProvider.currentPlayer?.id,
      orElse: () => todProvider.currentPlayer ?? playerProvider.players.first,
    );
    final totalScore = currentPlayerObj.score;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background confetti
          const Positioned.fill(
            child: ResultConfettiWidget(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // Title: Round X Finished!
                  Text(
                    'Vòng $round kết thúc!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  // Trophy Custom Painter
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: GoldenTrophyPainter(),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Result Card
                  Container(
                    padding: const EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card title
                        Text(
                          'Kết quả vòng $round',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Correct & Skips counts
                        Row(
                          children: [
                            // Correct
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F9F3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, color: Color(0xFF3DD99F), size: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Trả lời đúng',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$correct',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF3DD99F)),
                                  ),
                                  const Text(
                                    'lần',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            // Vertical Divider
                            Container(
                              width: 1.5,
                              height: 80,
                              color: const Color(0xFFE8EBF3),
                            ),
                            // Skip
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFECEF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, color: Color(0xFFFF4B72), size: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Bỏ qua',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$skip',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF4B72)),
                                  ),
                                  const Text(
                                    'lần',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Current points
                        const Text(
                          'Điểm của bạn',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.warning, size: 28),
                            const SizedBox(width: 6),
                            Text(
                              '$totalScore',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF7C5CFF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          points >= 0 ? '+$points điểm' : '$points điểm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: points >= 0 ? const Color(0xFF3DD99F) : const Color(0xFFFF4B72),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Next action button
                  ElevatedButton(
                    onPressed: () {
                      if (isGameOver) {
                        // Navigate to GameLeaderboardScreen instead of simple dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const GameLeaderboardScreen()),
                        );
                      } else {
                        // Next round
                        todProvider.nextRound();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RandomPlayerScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CFF),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                      shadowColor: const Color(0xFF7C5CFF).withOpacity(0.3),
                    ),
                    child: Text(
                      isGameOver ? 'Hoàn thành' : 'Tiếp tục',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Back home button
                  TextButton(
                    onPressed: () {
                      todProvider.reset();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Về trang chủ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ), // SafeArea closed
        ],
      ),
    );
  }
}

// Custom Painter to draw a beautiful 3D Golden Trophy
class GoldenTrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Trophy highlight gold colors
    final Color goldLight = const Color(0xFFFFD54F);
    final Color goldDark = const Color(0xFFFFB300);
    final Color goldShadow = const Color(0xFFFF8F00);

    // 1. Handles (Left and Right)
    paint.color = goldShadow;
    // Left ear
    final Path leftEar = Path()
      ..moveTo(cx - 20, cy - 25)
      ..cubicTo(cx - 50, cy - 40, cx - 50, cy + 5, cx - 20, cy - 5)
      ..close();
    canvas.drawPath(leftEar, paint);

    // Right ear
    final Path rightEar = Path()
      ..moveTo(cx + 20, cy - 25)
      ..cubicTo(cx + 50, cy - 40, cx + 50, cy + 5, cx + 20, cy - 5)
      ..close();
    canvas.drawPath(rightEar, paint);

    // Cover inside of ears to make hollow rings
    paint.color = AppColors.background;
    canvas.drawCircle(Offset(cx - 32, cy - 14), 10, paint);
    canvas.drawCircle(Offset(cx + 32, cy - 14), 10, paint);

    // 2. Bowl (Main body)
    // Left side (light gold)
    paint.color = goldLight;
    final Path bowlLeft = Path()
      ..moveTo(cx, cy - 45)
      ..lineTo(cx - 30, cy - 45)
      ..quadraticBezierTo(cx - 30, cy, cx, cy + 10)
      ..close();
    canvas.drawPath(bowlLeft, paint);

    // Right side (dark gold)
    paint.color = goldDark;
    final Path bowlRight = Path()
      ..moveTo(cx, cy - 45)
      ..lineTo(cx + 30, cy - 45)
      ..quadraticBezierTo(cx + 30, cy, cx, cy + 10)
      ..close();
    canvas.drawPath(bowlRight, paint);

    // Rim of the bowl (Ellipse top)
    paint.color = const Color(0xFFFFE082);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 45), width: 60, height: 10), paint);

    // 3. Stem (Connection base)
    paint.color = goldShadow;
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 20), width: 14, height: 20), paint);

    // 4. Base (Pedestal)
    paint.color = const Color(0xFF5D4037); // Dark brown wood base
    final RRect base = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 38), width: 50, height: 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(base, paint);

    // 5. Star on trophy
    paint.color = Colors.white;
    _drawTrophyStar(canvas, Offset(cx, cy - 18), 8, paint);
  }

  void _drawTrophyStar(Canvas canvas, Offset offset, double size, Paint paint) {
    final Path path = Path()
      ..moveTo(offset.dx, offset.dy - size)
      ..quadraticBezierTo(offset.dx, offset.dy, offset.dx + size, offset.dy)
      ..quadraticBezierTo(offset.dx, offset.dy, offset.dx, offset.dy + size)
      ..quadraticBezierTo(offset.dx, offset.dy, offset.dx - size, offset.dy)
      ..quadraticBezierTo(offset.dx, offset.dy, offset.dx, offset.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Background confetti painter decoration
class ResultConfettiWidget extends StatelessWidget {
  const ResultConfettiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ResultConfettiPainter(),
    );
  }
}

class _ResultConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(10);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    final List<Color> colors = [
      const Color(0xFFFF5B7F),
      const Color(0xFF7C5CFF),
      const Color(0xFF368DFF),
      const Color(0xFF3DD99F),
      const Color(0xFFFFAF36),
    ];

    for (int i = 0; i < 30; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double wSize = 4 + random.nextDouble() * 8;
      double hSize = 4 + random.nextDouble() * 8;
      paint.color = colors[random.nextInt(colors.length)].withOpacity(0.5);

      final Rect rect = Rect.fromLTWH(x, y, wSize, hSize);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
