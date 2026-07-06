import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'dart:math' as math;
import '../../providers/player_provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/database_helper.dart';
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
    final isGameOver = todProvider.isGameOver;

    final correct = todProvider.correctCount;
    final skip = todProvider.skipCount;
    final pointsThisRound = todProvider.pointsGainedThisRound;

    // Sort players by score descending for display
    final players = List.from(playerProvider.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: ResultConfettiWidget()),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    isGameOver ? '🏆 Trò chơi kết thúc!' : '🎉 Vòng $round kết thúc!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGameOver
                        ? 'Cùng xem kết quả cuối cùng!'
                        : 'Còn ${totalRounds - round} vòng nữa',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Round stats row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFFE8EBF3), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        _statChip(
                          icon: Icons.check_rounded,
                          iconColor: const Color(0xFF3DD99F),
                          bgColor: const Color(0xFFE8F9F3),
                          label: 'Đúng',
                          value: '$correct lần',
                        ),
                        const SizedBox(width: 12),
                        _statChip(
                          icon: Icons.close_rounded,
                          iconColor: const Color(0xFFFF4B72),
                          bgColor: const Color(0xFFFFECEF),
                          label: 'Bỏ qua',
                          value: '$skip lần',
                        ),
                        const SizedBox(width: 12),
                        _statChip(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.warning,
                          bgColor: const Color(0xFFFEF7E6),
                          label: 'Vòng này',
                          value: pointsThisRound >= 0
                              ? '+$pointsThisRound đ'
                              : '$pointsThisRound đ',
                          valueColor: pointsThisRound >= 0
                              ? const Color(0xFF3DD99F)
                              : const Color(0xFFFF4B72),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scoreboard
                  Text(
                    isGameOver ? 'Điểm cuối cùng' : 'Tổng điểm tích lũy',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final p = players[index];
                        final isFirst = index == 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isFirst
                                ? const Color(0xFFFFF7E6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isFirst
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFFE8EBF3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Rank
                              SizedBox(
                                width: 28,
                                child: Text(
                                  index == 0
                                      ? '🥇'
                                      : index == 1
                                          ? '🥈'
                                          : index == 2
                                              ? '🥉'
                                              : '${index + 1}',
                                  style: TextStyle(
                                    fontSize: index < 3 ? 20 : 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Avatar
                              ClipOval(
                                child: RandomAvatar(
                                  p.name,
                                  trBackground: false,
                                  height: 36,
                                  width: 36,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Name
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isFirst
                                        ? const Color(0xFFC69100)
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              // Score
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.warning, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${p.score}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF7C5CFF),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Next action button
                  ElevatedButton(
                    onPressed: () async {
                      if (isGameOver) {
                        if (todProvider.currentSessionId != null) {
                          await DatabaseHelper.instance.endSession(
                            todProvider.currentSessionId!,
                            playerProvider.players,
                          );
                        }
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GameLeaderboardScreen()),
                          );
                        }
                      } else {
                        todProvider.nextRound();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RandomPlayerScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGameOver
                          ? const Color(0xFFFFAF36)
                          : const Color(0xFF7C5CFF),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      isGameOver ? '🏆 Xem kết quả cuối' : '▶ Vòng tiếp theo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Back home
                  TextButton(
                    onPressed: () {
                      // Luôn reset state khi về trang chủ, dù game chưa kết thúc
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: valueColor ?? AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class GoldenTrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final Color goldLight = const Color(0xFFFFD54F);
    final Color goldDark = const Color(0xFFFFB300);
    final Color goldShadow = const Color(0xFFFF8F00);

    paint.color = goldShadow;
    final Path leftEar = Path()
      ..moveTo(cx - 20, cy - 25)
      ..cubicTo(cx - 50, cy - 40, cx - 50, cy + 5, cx - 20, cy - 5)
      ..close();
    canvas.drawPath(leftEar, paint);

    final Path rightEar = Path()
      ..moveTo(cx + 20, cy - 25)
      ..cubicTo(cx + 50, cy - 40, cx + 50, cy + 5, cx + 20, cy - 5)
      ..close();
    canvas.drawPath(rightEar, paint);

    paint.color = AppColors.background;
    canvas.drawCircle(Offset(cx - 32, cy - 14), 10, paint);
    canvas.drawCircle(Offset(cx + 32, cy - 14), 10, paint);

    paint.color = goldLight;
    final Path bowlLeft = Path()
      ..moveTo(cx, cy - 45)
      ..lineTo(cx - 30, cy - 45)
      ..quadraticBezierTo(cx - 30, cy, cx, cy + 10)
      ..close();
    canvas.drawPath(bowlLeft, paint);

    paint.color = goldDark;
    final Path bowlRight = Path()
      ..moveTo(cx, cy - 45)
      ..lineTo(cx + 30, cy - 45)
      ..quadraticBezierTo(cx + 30, cy, cx, cy + 10)
      ..close();
    canvas.drawPath(bowlRight, paint);

    paint.color = const Color(0xFFFFE082);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy - 45), width: 60, height: 10),
        paint);

    paint.color = goldShadow;
    canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy + 20), width: 14, height: 20),
        paint);

    paint.color = const Color(0xFF5D4037);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 38), width: 50, height: 16),
        const Radius.circular(4),
      ),
      paint,
    );

    paint.color = Colors.white;
    _drawStar(canvas, Offset(cx, cy - 18), 8, paint);
  }

  void _drawStar(Canvas canvas, Offset offset, double size, Paint paint) {
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

class ResultConfettiWidget extends StatelessWidget {
  const ResultConfettiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ResultConfettiPainter());
  }
}

class _ResultConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(10);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    const colors = [
      Color(0xFFFF5B7F),
      Color(0xFF7C5CFF),
      Color(0xFF368DFF),
      Color(0xFF3DD99F),
      Color(0xFFFFAF36),
    ];

    for (int i = 0; i < 30; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double wSize = 4 + random.nextDouble() * 8;
      double hSize = 4 + random.nextDouble() * 8;
      paint.color =
          colors[random.nextInt(colors.length)].withValues(alpha: 0.4);
      canvas.drawRect(Rect.fromLTWH(x, y, wSize, hSize), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
