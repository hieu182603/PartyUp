import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/player_provider.dart';
import '../services/database_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bảng Xếp Hạng',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C5CFF),
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: const Color(0xFF7C5CFF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Toàn Cầu'),
            Tab(text: 'Các Nhóm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalTab(),
          _buildGroupsTab(),
        ],
      ),
    );
  }

  Widget _buildGlobalTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getGlobalLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return _buildEmptyState('Chưa có dữ liệu người chơi.');
        }
        
        final mappedList = list.map((e) => {
          'name': e['name'] as String,
          'score': e['total_score'] as int,
          'avatarSeed': e['name'] as String,
        }).toList();

        return _buildLeaderboardContent(mappedList);
      },
    );
  }

  Widget _buildGroupsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getGroupLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return _buildEmptyState('Chưa có dữ liệu nhóm.');
        }
        
        final mappedList = list.map((e) => {
          'name': e['name'] as String,
          'score': e['total_score'] as int,
          'avatarSeed': e['name'] as String,
        }).toList();

        return _buildLeaderboardContent(mappedList);
      },
    );
  }


  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
      ),
    );
  }

  Widget _buildLeaderboardContent(List<Map<String, dynamic>> listData) {
    String firstPlaceName = '';
    int firstPlaceScore = 0;
    String secondPlaceName = '';
    int secondPlaceScore = 0;
    String thirdPlaceName = '';
    int thirdPlaceScore = 0;

    if (listData.isNotEmpty) {
      firstPlaceName = listData[0]['name'];
      firstPlaceScore = listData[0]['score'];
    }
    if (listData.length > 1) {
      secondPlaceName = listData[1]['name'];
      secondPlaceScore = listData[1]['score'];
    }
    if (listData.length > 2) {
      thirdPlaceName = listData[2]['name'];
      thirdPlaceScore = listData[2]['score'];
    }

    final remainingPlayers = listData.length > 3 ? listData.sublist(3) : [];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Podiums (Hạng 1, 2, 3)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (listData.length > 1)
                    _buildPodiumColumn(
                      name: secondPlaceName,
                      score: secondPlaceScore,
                      rank: 2,
                      height: 110,
                      avatarSeed: secondPlaceName,
                      color: const Color(0xFFE8EBF3),
                    )
                  else
                    const SizedBox(width: 80),
                  const SizedBox(width: 16),
                  if (listData.isNotEmpty)
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
                  if (listData.length > 2)
                    _buildPodiumColumn(
                      name: thirdPlaceName,
                      score: thirdPlaceScore,
                      rank: 3,
                      height: 95,
                      avatarSeed: thirdPlaceName,
                      color: const Color(0xFFFFECEF),
                    )
                  else
                    const SizedBox(width: 80),
                ],
              ),
              const SizedBox(height: 24),
              // Rest of Leaderboard list
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: remainingPlayers.length,
                  itemBuilder: (context, index) {
                    final item = remainingPlayers[index];
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
                              child: RandomAvatar(
                                item['avatarSeed'],
                                trBackground: false,
                                height: 36,
                                width: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name
                          Expanded(
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Points
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${item['score']} điểm',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
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
      ],
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
          // Avatar
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
                  top: -24,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFB300),
                    size: 26,
                  ),
                ),
              Positioned(
                bottom: -8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: rank == 1 ? const Color(0xFFFFB300) : (rank == 2 ? const Color(0xFF9E9E9E) : const Color(0xFFBCAAA4)),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Score
          Text(
            '$score pts',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Podium Block
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
