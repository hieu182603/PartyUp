import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../core/theme/app_colors.dart';
import 'penalty_screen.dart';

/// Shown briefly when a player taps "Skip". Then goes to PenaltyScreen.
/// SkipScreen does NOT record points — PenaltyScreen's initState does that.
class SkipScreen extends StatelessWidget {
  const SkipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 3),

            const Center(
              child: Text('😬', style: TextStyle(fontSize: 90)),
            ),
            const SizedBox(height: 24),

            const Text(
              'Bỏ qua thử thách!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Bạn sẽ bị trừ ${todProvider.penaltyPoints.abs()} điểm\nvà phải thực hiện hình phạt.',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 4),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PenaltyScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B72),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: const Color(0xFFFF4B72).withValues(alpha: 0.4),
              ),
              child: const Text(
                'Nhận hình phạt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
