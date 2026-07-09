import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/player_provider.dart';
import '../../providers/secret_rule_provider.dart';

import '../../services/database_helper.dart';

class SecretRuleResultScreen extends StatefulWidget {
  const SecretRuleResultScreen({super.key});

  @override
  State<SecretRuleResultScreen> createState() => _SecretRuleResultScreenState();
}

class _SecretRuleResultScreenState extends State<SecretRuleResultScreen> {
  
  @override
  void initState() {
    super.initState();
    _endGameSession();
  }
  
  Future<void> _endGameSession() async {
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    final players = Provider.of<PlayerProvider>(context, listen: false).players;
    
    if (provider.currentSessionId != null) {
      // Create a copy of players with their scores set to negative violations
      // so it records who got how many violations
      final finalPlayers = players.map((p) {
        final violations = provider.violations[p.id] ?? 0;
        return p.copyWith(score: -violations);
      }).toList();
      
      await DatabaseHelper.instance.endSession(
        provider.currentSessionId!,
        finalPlayers,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    final players = Provider.of<PlayerProvider>(context, listen: false).players;
    
    int totalViolations = 0;
    for (final count in provider.violations.values) {
      totalViolations += count;
    }

    // Sort players by violations (ascending: fewest violations first = best)
    final sortedPlayers = List.of(players);
    sortedPlayers.sort((a, b) {
      final aCount = provider.violations[a.id] ?? 0;
      final bCount = provider.violations[b.id] ?? 0;
      return aCount.compareTo(bCount);
    });

    final bestPlayer = sortedPlayers.isNotEmpty ? sortedPlayers.first : null;
    final worstPlayer = sortedPlayers.isNotEmpty && sortedPlayers.length > 1 ? sortedPlayers.last : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kết quả trò chơi'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Vòng chơi', '${provider.totalRounds}', const Color(0xFF3DD99F)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('Tổng vi phạm', '$totalViolations', const Color(0xFF4FAAFF)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text(
              'DANH HIỆU',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            if (bestPlayer != null)
              _buildTitleCard(bestPlayer.name, '🥇 Người tuân thủ nhất', const Color(0xFF7C5CFF)),
            const SizedBox(height: 12),
            if (worstPlayer != null)
              _buildTitleCard(worstPlayer.name, '💥 Thánh phá luật', const Color(0xFFFF4B72)),
            
            const SizedBox(height: 32),
            const Text(
              'BẢNG XẾP HẠNG VI PHẠM',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedPlayers.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE8EBF3)),
                itemBuilder: (context, index) {
                  final player = sortedPlayers[index];
                  final count = provider.violations[player.id] ?? 0;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        RandomAvatar(player.name, trBackground: false, height: 40, width: 40),
                      ],
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    trailing: Text(
                      '$count vi phạm',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'Về Trang Chủ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard(String playerName, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          RandomAvatar(playerName, trBackground: false, height: 48, width: 48),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                playerName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
