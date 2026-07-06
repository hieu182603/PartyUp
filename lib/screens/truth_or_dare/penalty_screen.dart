import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/player_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/audio_service.dart';
import 'result_screen.dart';
import 'random_player_screen.dart';

/// Shown when player skips. Applies penalty then decides next screen.
class PenaltyScreen extends StatefulWidget {
  const PenaltyScreen({super.key});

  @override
  State<PenaltyScreen> createState() => _PenaltyScreenState();
}

class _PenaltyScreenState extends State<PenaltyScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.instance.playSFX('siren.mp3');
    _recordPenalty();
  }

  Future<void> _recordPenalty() async {
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final player = todProvider.currentPlayer;

    if (player != null) {
      final points = todProvider.penaltyPoints; // negative value
      // Apply penalty to player score
      await playerProvider.updatePlayerScore(player.id!, points);
      // Track penalty count in player profile
      await playerProvider.updatePlayerPenalty(player.id!, points.abs());
      // Mark player as played + update round stats
      todProvider.recordSkip(points);
    }
  }

  void _onContinue(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    final roundComplete = todProvider.isRoundComplete(playerProvider.players.length);
    todProvider.completeTurn(roundComplete);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => roundComplete ? const ResultScreen() : const RandomPlayerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);
    // Lưu content type trước khi recordSkip() xóa currentContent
    // (PenaltyScreen được xây dựng sau khi recordSkip đã chạy trong initState)
    // Cần penaltyText trước khi content bị null
    final penaltyText = todProvider.currentContent?.penaltyText ??
        'Hát một bài hát bất kỳ hoặc nhảy trong 30 giây';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F2),
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
            const Spacer(flex: 2),

            const Center(
              child: Text('😅', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 24),

            // Tiêu đề cố định vì currentContent đã bị xóa trong recordSkip()
            const Text(
              'Chịu phạt thôi!',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF4B72),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              '${todProvider.penaltyPoints} điểm',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF4B72),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Penalty task card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD6DE), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4B72).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '🎭 Hình phạt',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF4B72),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    penaltyText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),

            ElevatedButton(
              onPressed: () => _onContinue(context),
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
                'Đã thực hiện xong',
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
