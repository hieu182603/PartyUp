import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/player_provider.dart';
import '../../core/theme/app_colors.dart';
import 'penalty_screen.dart';

class SkipScreen extends StatelessWidget {
  const SkipScreen({super.key});

  void _onContinue(BuildContext context) async {
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final player = todProvider.currentPlayer;

    if (player != null) {
      final points = todProvider.penaltyPoints;
      // Deduct points
      await playerProvider.updatePlayerScore(player.id!, points);
      todProvider.recordSkip(points);
    }

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PenaltyScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 24, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 3),
            // Sad Star Mascot
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: SadStarMascotPainter(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Red Close/Cross Badge
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4B72),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Titles
            const Text(
              'Đã bỏ qua',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn sẽ nhận ít điểm hơn nếu bỏ qua.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 1),
            // Peach/Orange Deducted Points Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFCCD3), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.warning, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '${Provider.of<TruthOrDareProvider>(context).penaltyPoints} điểm',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF4B72),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            // Continue button (Orange/Red)
            ElevatedButton(
              onPressed: () => _onContinue(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6536),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: const Color(0xFFFF6536).withOpacity(0.3),
              ),
              child: const Text(
                'Tiếp tục',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Sad Star Mascot
class SadStarMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = size.width * 0.38; // Outer radius
    final r = size.width * 0.17; // Inner radius

    // Paint definition
    final Paint lightPaint = Paint()..style = PaintingStyle.fill;
    final Paint darkPaint = Paint()..style = PaintingStyle.fill;

    // Draw 3D beveled star
    for (int i = 0; i < 5; i++) {
      double thetaA = -math.pi / 2 + i * 2 * math.pi / 5;
      double thetaInner = -math.pi / 2 + (i + 0.5) * 2 * math.pi / 5;
      double thetaPrevInner = -math.pi / 2 + (i - 0.5) * 2 * math.pi / 5;

      Offset pOuter = Offset(cx + R * math.cos(thetaA), cy + R * math.sin(thetaA));
      Offset pInnerRight = Offset(cx + r * math.cos(thetaInner), cy + r * math.sin(thetaInner));
      Offset pInnerLeft = Offset(cx + r * math.cos(thetaPrevInner), cy + r * math.sin(thetaPrevInner));

      // Light face (left half of point)
      lightPaint.color = const Color(0xFFFFD54F);
      final Path pathLight = Path()
        ..moveTo(cx, cy)
        ..lineTo(pOuter.dx, pOuter.dy)
        ..lineTo(pInnerLeft.dx, pInnerLeft.dy)
        ..close();
      canvas.drawPath(pathLight, lightPaint);

      // Dark face (right half of point)
      darkPaint.color = const Color(0xFFFFB300);
      final Path pathDark = Path()
        ..moveTo(cx, cy)
        ..lineTo(pOuter.dx, pOuter.dy)
        ..lineTo(pInnerRight.dx, pInnerRight.dy)
        ..close();
      canvas.drawPath(pathDark, darkPaint);
    }

    // Rosy cheeks
    final Paint cheekPaint = Paint()
      ..color = const Color(0xFFFF8E9C).withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 24, cy + 12), 10, cheekPaint);
    canvas.drawCircle(Offset(cx + 24, cy + 12), 10, cheekPaint);

    // Sad dot eyes
    final Paint eyePaint = Paint()
      ..color = const Color(0xFF1E202C)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx - 18, cy + 2), 6, eyePaint);
    canvas.drawCircle(Offset(cx + 18, cy + 2), 6, eyePaint);

    // Sad frowning mouth
    final Paint mouthPaint = Paint()
      ..color = const Color(0xFF1E202C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final Path mouthPath = Path()
      ..moveTo(cx - 8, cy + 19)
      ..quadraticBezierTo(cx, cy + 12, cx + 8, cy + 19);
    canvas.drawPath(mouthPath, mouthPaint);

    // Background sparkles
    final Paint sparklePaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    _drawSparkle(canvas, Offset(cx - R - 10, cy - R + 20), 8, sparklePaint);
    _drawSparkle(canvas, Offset(cx + R + 15, cy - 20), 10, sparklePaint);
  }

  void _drawSparkle(Canvas canvas, Offset offset, double size, Paint paint) {
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
