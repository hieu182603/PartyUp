import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../providers/truth_or_dare_provider.dart';
import '../models/game_session.dart';
import '../services/database_helper.dart';
import 'truth_or_dare/random_player_screen.dart';

class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn chế độ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bạn muốn chơi chế độ nào?',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: _buildModeCard(
                context,
                title: 'Thật hay Thách',
                subtitle: 'Trả lời thật lòng\nhoặc làm thử thách',
                gradient: AppColors.truthGradient, // Sử dụng màu xanh tương tự thiết kế
                imagePath: null, // Placeholder for illustration
                onTap: () async {
                  final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                  final tdProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
                  if (groupProvider.currentGroup != null) {
                    final session = GameSession(groupId: groupProvider.currentGroup!.id!, gameMode: 'truth_or_dare');
                    final sessionId = await DatabaseHelper.instance.createGameSession(session);
                    tdProvider.currentSessionId = sessionId;
                  }
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RandomPlayerScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildModeCard(
                context,
                title: 'Luật bí mật',
                subtitle: 'Tuân thủ luật bí mật\nvà bắt vi phạm',
                gradient: AppColors.primaryGradient,
                imagePath: null, // Placeholder for illustration
                onTap: () {
                  AppNotification.info(context, 'Chế độ Luật bí mật sớm ra mắt! 🤫');
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, {
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    String? imagePath,
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
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward, color: gradient.colors.first),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
