import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/game_content_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/app_notification.dart';
import '../../services/audio_service.dart';
import 'content_playing_screen.dart';
import 'random_player_screen.dart';

class TruthOrDareChoiceScreen extends StatelessWidget {
  const TruthOrDareChoiceScreen({super.key});

  void _onChoice(BuildContext context, String type) async {
    // Play selection SFX
    AudioService.instance.playSFX('tap.mp3');

    final contentProvider = Provider.of<GameContentProvider>(context, listen: false);
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);

    final categories = todProvider.currentCategories;
    final difficulty = todProvider.currentDifficulty;
    final content = await contentProvider.getRandomContent(type, categories: categories, difficulty: difficulty);
    if (!context.mounted) return;

    if (content != null) {
      todProvider.chooseType(content);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ContentPlayingScreen()),
      );
    } else {
      AppNotification.error(context, 'Không còn câu hỏi/thử thách loại này! Hãy đổi lượt.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);
    final player = todProvider.currentPlayer;

    if (player == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RandomPlayerScreen()),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Header text
            Center(
              child: Text(
                '${player.name} ơi, chọn đi!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Truth hay Dare?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            // TRUTH Card (Red/Pink)
            Expanded(
              child: _buildChoiceCard(
                context,
                title: 'TRUTH',
                gradient: AppColors.truthGradient,
                bubbleChild: const Text(
                  '?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF4B72),
                  ),
                ),
                onTap: () => _onChoice(context, 'truth'),
              ),
            ),
            const SizedBox(height: 20),
            // DARE Card (Blue)
            Expanded(
              child: _buildChoiceCard(
                context,
                title: 'DARE',
                gradient: AppColors.dareGradient,
                bubbleChild: const Icon(
                  Icons.bolt_rounded,
                  size: 36,
                  color: Color(0xFF368DFF),
                ),
                onTap: () => _onChoice(context, 'dare'),
              ),
            ),
            const SizedBox(height: 32),
            // Change Turn button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RandomPlayerScreen()),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
                label: const Text(
                  'Đổi lượt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard(
    BuildContext context, {
    required String title,
    required LinearGradient gradient,
    required Widget bubbleChild,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: [
            // Text TRUTH/DARE
            Text(
              title,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            // Speech Bubble Icon Container
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: bubbleChild,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
