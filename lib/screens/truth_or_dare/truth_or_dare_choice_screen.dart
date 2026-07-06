import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/game_content_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/app_notification.dart';
import '../../services/audio_service.dart';
import 'package:random_avatar/random_avatar.dart';
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
    final favoritesOnly = todProvider.favoritesOnly;
    var content = await contentProvider.getRandomContent(type, categories: categories, difficulty: difficulty, favoritesOnly: favoritesOnly);
    if (!context.mounted) return;

    if (content == null) {
      contentProvider.resetUsedContents();
      AppNotification.success(context, 'Các bạn chơi quá đỉnh, kho bài đã cạn! Hệ thống đang xáo lại bộ bài để cuộc vui tiếp tục nhé!');
      
      content = await contentProvider.getRandomContent(type, categories: categories, difficulty: difficulty, favoritesOnly: favoritesOnly);
      if (!context.mounted) return;
    }

    if (content != null) {
      todProvider.chooseType(content);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ContentPlayingScreen()),
      );
    } else {
      AppNotification.error(context, 'Không tìm thấy câu hỏi/thử thách phù hợp! Hãy thử đổi cài đặt mức độ hoặc thể loại.');
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
          onPressed: () {
            // Không chọn lại người chơi mới khi bấm back
            // Chỉ hiển thị lại RandomPlayerScreen cho phép bấm cóng đồng
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header text with Avatar
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: RandomAvatar(player.name, trBackground: false, height: 80, width: 80),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '${player.name}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Chọn đi nào! Sự thật hay Thử thách?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // TRUTH Card (Red/Pink)
            Expanded(
              child: _buildChoiceCard(
                context,
                title: 'THẬT',
                gradient: AppColors.truthGradient, // Đỏ (đúng màu Truth)
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
                title: 'THÁCH',
                gradient: AppColors.dareGradient, // Xanh (dùng dare gradient cho THÁCH)
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
                  // Remove recordSkip to prevent skipping player
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
              color: gradient.colors.first.withValues(alpha: 0.35),
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
