import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/player_provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../services/database_helper.dart';
import '../home_screen.dart';
import 'result_screen.dart';

class GameLeaderboardScreen extends StatelessWidget {
  const GameLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final sessionId = todProvider.currentSessionId;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: sessionId != null
          ? DatabaseHelper.instance.getSessionScores(sessionId)
          : Future.value(playerProvider.players
              .map((p) => {'player_name': p.name, 'player_avatar': p.avatar ?? '', 'score': p.score})
              .toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final scores = snapshot.data ?? [];
        // Sort by score descending
        final sorted = List<Map<String, dynamic>>.from(scores)
          ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

        final String firstPlaceName = sorted.isNotEmpty ? sorted[0]['player_name'] as String : '';
        final int firstPlaceScore = sorted.isNotEmpty ? sorted[0]['score'] as int : 0;
        final String secondPlaceName = sorted.length > 1 ? sorted[1]['player_name'] as String : '';
        final int secondPlaceScore = sorted.length > 1 ? sorted[1]['score'] as int : 0;
        final String thirdPlaceName = sorted.length > 2 ? sorted[2]['player_name'] as String : '';
        final int thirdPlaceScore = sorted.length > 2 ? sorted[2]['score'] as int : 0;
        final remainingPlayers = sorted.length > 3 ? sorted.sublist(3) : <Map<String, dynamic>>[];

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
                  const SizedBox(height: 16),
                  // Title: Game Over / Final Rankings
                  const Text(
                    'Kết quả chung cuộc',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Chúc mừng người chiến thắng! 🏆',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Trophy illustration
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CustomPaint(
                        painter: GoldenTrophyPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Podiums (Hạng 1, 2, 3)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 2nd Place (Left)
                      _buildPodiumColumn(
                        name: secondPlaceName,
                        score: secondPlaceScore,
                        rank: 2,
                        height: 100,
                        avatarSeed: secondPlaceName,
                        color: const Color(0xFFE8EBF3),
                      ),
                      const SizedBox(width: 12),
                      // 1st Place (Center)
                      _buildPodiumColumn(
                        name: firstPlaceName,
                        score: firstPlaceScore,
                        rank: 1,
                        height: 135,
                        avatarSeed: firstPlaceName,
                        color: const Color(0xFFFFF7E6),
                        hasCrown: true,
                      ),
                      const SizedBox(width: 12),
                      // 3rd Place (Right)
                      _buildPodiumColumn(
                        name: thirdPlaceName,
                        score: thirdPlaceScore,
                        rank: 3,
                        height: 85,
                        avatarSeed: thirdPlaceName,
                        color: const Color(0xFFFFECEF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Rest of Leaderboard list header
                  if (remainingPlayers.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Thứ hạng khác',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Rest of Leaderboard list
                  Expanded(
                    child: remainingPlayers.isEmpty
                        ? const Center(
                            child: Text(
                              'Không còn người chơi nào khác',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: remainingPlayers.length,
                            itemBuilder: (context, index) {
                              final p = remainingPlayers[index];
                              final pName = p['player_name'] as String;
                              final pScore = p['score'] as int;
                              final rank = index + 4;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '$rank',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        color: const Color(0xFFF2F4F7),
                                        child: RandomAvatar(pName, trBackground: false, height: 36, width: 36),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        pName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$pScoređ',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF7C5CFF),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                   const SizedBox(height: 16),

                  // Complete / Finish button
                  ElevatedButton(
                    onPressed: () async {
                      final tod = Provider.of<TruthOrDareProvider>(context, listen: false);
                      final pp = Provider.of<PlayerProvider>(context, listen: false);
                      // Reset game session and scores
                      tod.reset();
                      await pp.resetScores();

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
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
                      shadowColor: const Color(0xFF7C5CFF).withValues(alpha: 0.3),
                    ),
                    child: const Text(
                      'Hoàn thành',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      }, // end FutureBuilder builder
    ); // end FutureBuilder
  }

  Widget _buildPodiumColumn({
    required String name,
    required int score,
    required int rank,
    required double height,
    required String avatarSeed,
    required Color color,
    bool hasCrown = false,
  }) {
    if (name.isEmpty) {
      return const Expanded(child: SizedBox());
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar with optional crown
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rank == 1 ? const Color(0xFFFFB300) : Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: RandomAvatar(
                    avatarSeed,
                    trBackground: false,
                    height: 64,
                    width: 64,
                  ),
                ),
              ),
              if (hasCrown)
                const Positioned(
                  top: -22,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFB300),
                    size: 24,
                  ),
                ),
              Positioned(
                bottom: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: rank == 1 ? const Color(0xFFFFB300) : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Podium pedestal
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$scoređ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: rank == 1 ? const Color(0xFFC69100) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
