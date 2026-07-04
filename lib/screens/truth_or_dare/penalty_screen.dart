import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/player_provider.dart';
import '../../core/theme/app_colors.dart';
import 'result_screen.dart';

class PenaltyScreen extends StatelessWidget {
  const PenaltyScreen({super.key});

  void _onCompletePenalty(BuildContext context, int penaltyPoints) async {
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final player = todProvider.currentPlayer;

    if (player != null) {
      // Add penalty points
      await playerProvider.updatePlayerPenalty(player.id!, penaltyPoints);
    }

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);
    final content = todProvider.currentContent;

    final penaltyText = content?.penaltyText ?? 'Hát một bài hát bất kỳ hoặc nhảy trong 30 giây';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F2), // Light Pink background
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
            // Red Skull Circle Badge
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4B72),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CustomPaint(
                      painter: SkullPainter(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Titles
            const Text(
              'Penalty',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF4B72),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vì bạn đã bỏ qua,\nhãy thực hiện thử thách sau!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 1),
            // Pink Penalty Content Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E9),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFFFCCD3), width: 1.5),
              ),
              child: Column(
                children: [
                  // Microphone & Music notes icon container
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_external_on_rounded,
                        color: Color(0xFFFF4B72),
                        size: 40,
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.music_note_rounded,
                        color: Color(0xFFFF4B72),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Penalty text
                  Text(
                    penaltyText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF4B72),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            // Action Buttons
            ElevatedButton(
              onPressed: () => _onCompletePenalty(context, 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B72),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: const Color(0xFFFF4B72).withOpacity(0.3),
              ),
              child: const Text(
                'Tôi đã hoàn thành',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _onCompletePenalty(context, 2), // +2 penalty points if they still refuse
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: Color(0xFFE8EBF3), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Vẫn chưa thể làm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
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

// Custom Painter to draw a stylized white skull
class SkullPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint hollowPaint = Paint()
      ..color = const Color(0xFFFF4B72) // Same color as badge background
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Cranium (top head)
    canvas.drawCircle(Offset(cx, cy - 4), 16, paint);

    // Jaw (bottom head)
    final RRect jaw = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 18, height: 14),
      const Radius.circular(4),
    );
    canvas.drawRRect(jaw, paint);

    // Left & Right eye sockets
    canvas.drawCircle(Offset(cx - 6, cy - 4), 4.5, hollowPaint);
    canvas.drawCircle(Offset(cx + 6, cy - 4), 4.5, hollowPaint);

    // Nasal cavity (Nose)
    final Path nosePath = Path()
      ..moveTo(cx, cy + 2)
      ..lineTo(cx + 2, cy + 5)
      ..lineTo(cx - 2, cy + 5)
      ..close();
    canvas.drawPath(nosePath, hollowPaint);

    // Teeth lines
    final Paint teethPaint = Paint()
      ..color = const Color(0xFFFF4B72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx - 4, cy + 8), Offset(cx - 4, cy + 14), teethPaint);
    canvas.drawLine(Offset(cx, cy + 8), Offset(cx, cy + 14), teethPaint);
    canvas.drawLine(Offset(cx + 4, cy + 8), Offset(cx + 4, cy + 14), teethPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
