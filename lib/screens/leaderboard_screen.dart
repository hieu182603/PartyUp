import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/player_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedPeriod = 1; // 0: Tuần, 1: Tháng, 2: Tất cả

  final List<Map<String, dynamic>> _mockMonthlyLeaderboard = [
    {'name': 'Nam', 'score': 280, 'seed': 'Nam'},
    {'name': 'Huy', 'score': 210, 'seed': 'Huy'},
    {'name': 'Phương', 'score': 180, 'seed': 'Phuong'},
    {'name': 'Khoa', 'score': 120, 'seed': 'Khoa'},
    {'name': 'Trang', 'score': 90, 'seed': 'Trang'},
  ];

  final List<Map<String, dynamic>> _mockWeeklyLeaderboard = [
    {'name': 'Huy', 'score': 190, 'seed': 'Huy'},
    {'name': 'An', 'score': 150, 'seed': 'An'},
    {'name': 'Linh', 'score': 110, 'seed': 'Linh'},
    {'name': 'Nam', 'score': 90, 'seed': 'Nam'},
    {'name': 'Phương', 'score': 60, 'seed': 'Phuong'},
  ];

  final List<Map<String, dynamic>> _mockAllTimeLeaderboard = [
    {'name': 'Minh', 'score': 3540, 'seed': 'Minh'},
    {'name': 'An', 'score': 2980, 'seed': 'An'},
    {'name': 'Linh', 'score': 2750, 'seed': 'Linh'},
    {'name': 'Nam', 'score': 2100, 'seed': 'Nam'},
    {'name': 'Huy', 'score': 1890, 'seed': 'Huy'},
    {'name': 'Phương', 'score': 1520, 'seed': 'Phuong'},
  ];

  List<Map<String, dynamic>> _getLeaderboardData() {
    switch (_selectedPeriod) {
      case 0:
        return _mockWeeklyLeaderboard;
      case 1:
        return _mockMonthlyLeaderboard;
      default:
        return _mockAllTimeLeaderboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final activePlayers = playerProvider.players;

    // Default podium values for "Tháng"
    String firstPlaceName = 'Minh';
    int firstPlaceScore = 520;
    String secondPlaceName = 'An';
    int secondPlaceScore = 380;
    String thirdPlaceName = 'Linh';
    int thirdPlaceScore = 310;

    // If we have active players, we can override or merge them
    if (activePlayers.isNotEmpty) {
      final sortedActive = List.from(activePlayers)..sort((a, b) => b.score.compareTo(a.score));
      if (sortedActive.isNotEmpty) {
        firstPlaceName = sortedActive[0].name;
        firstPlaceScore = sortedActive[0].score;
      }
      if (sortedActive.length > 1) {
        secondPlaceName = sortedActive[1].name;
        secondPlaceScore = sortedActive[1].score;
      }
      if (sortedActive.length > 2) {
        thirdPlaceName = sortedActive[2].name;
        thirdPlaceScore = sortedActive[2].score;
      }
    }

    final listData = _getLeaderboardData();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                // Period tabs
                Row(
                  children: [
                    _buildPeriodTab('Tuần', 0),
                    const SizedBox(width: 8),
                    _buildPeriodTab('Tháng', 1),
                    const SizedBox(width: 8),
                    _buildPeriodTab('Tất cả', 2),
                  ],
                ),
                const SizedBox(height: 32),
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
                      height: 110,
                      avatarSeed: secondPlaceName,
                      color: const Color(0xFFE8EBF3),
                    ),
                    const SizedBox(width: 16),
                    // 1st Place (Center)
                    _buildPodiumColumn(
                      name: firstPlaceName,
                      score: firstPlaceScore,
                      rank: 1,
                      height: 145,
                      avatarSeed: firstPlaceName,
                      color: const Color(0xFFFFF7E6),
                      hasCrown: true,
                    ),
                    const SizedBox(width: 16),
                    // 3rd Place (Right)
                    _buildPodiumColumn(
                      name: thirdPlaceName,
                      score: thirdPlaceScore,
                      rank: 3,
                      height: 95,
                      avatarSeed: thirdPlaceName,
                      color: const Color(0xFFFFECEF),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Rest of Leaderboard list
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: listData.length,
                    itemBuilder: (context, index) {
                      final item = listData[index];
                      final name = item['name'] as String;
                      final score = item['score'] as int;
                      final seed = item['seed'] as String;
                      final rank = index + 4;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            // Rank Number
                            Text(
                              '$rank',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Avatar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 36,
                                height: 36,
                                color: const Color(0xFFF2F4F7),
                                child: Image.network(
                                  'https://api.dicebear.com/7.x/lorelei/png?seed=$seed',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            // Score
                            Text(
                              '$score',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Sticky Bottom "My Score" Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F5FF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E2FF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '7',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF7C5CFF)),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Điểm của bạn',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    '120',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF7C5CFF)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String title, int periodIndex) {
    final isSelected = _selectedPeriod == periodIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = periodIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7C5CFF) : const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rank == 1 ? const Color(0xFFFFB300) : Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://api.dicebear.com/7.x/lorelei/png?seed=$avatarSeed',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                  ),
                ),
              ),
              if (hasCrown)
                const Positioned(
                  top: -24,
                  child: Icon(
                    Icons.emoji_events_rounded, // trophy as a crown
                    color: Color(0xFFFFB300),
                    size: 26,
                  ),
                ),
              Positioned(
                bottom: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: rank == 1 ? const Color(0xFFFFB300) : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 11,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 15,
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
