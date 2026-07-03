import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/game_content_provider.dart';
import '../../core/theme/app_colors.dart';
import 'content_playing_screen.dart';

class TruthOrDareChoiceScreen extends StatelessWidget {
  const TruthOrDareChoiceScreen({super.key});

  void _onChoice(BuildContext context, String type) {
    final contentProvider = Provider.of<GameContentProvider>(context, listen: false);
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);

    final content = contentProvider.getRandomContent(type);
    if (content != null) {
      todProvider.chooseType(content);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ContentPlayingScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không còn câu hỏi/thử thách loại này!')),
      );
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
      appBar: AppBar(
        title: const Text('Chọn Thật hoặc Thách'),
        automaticallyImplyLeading: false, // Prevent going back randomly
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.warning,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Chọn đi nào!', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildChoiceCard(
                      title: 'THẬT',
                      icon: Icons.help_outline,
                      gradient: AppColors.truthGradient,
                      onTap: () => _onChoice(context, 'truth'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildChoiceCard(
                      title: 'THÁCH',
                      icon: Icons.emoji_events,
                      gradient: AppColors.dareGradient,
                      onTap: () => _onChoice(context, 'dare'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextButton.icon(
              onPressed: () {
                // Đổi lượt
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TruthOrDareChoiceScreen()), // Ideally should go back to RandomPlayerScreen
                );
              },
              icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
              label: const Text('Đổi lượt', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required IconData icon,
    required LinearGradient gradient,
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
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
