import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/player_provider.dart';
import '../services/database_helper.dart';
import 'group_details_screen.dart';

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
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
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

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: _buildLeaderboardContent(mappedList),
        );
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
          'id': e['id'] as int,
          'name': e['name'] as String,
          'score': (e['total_score'] as num?)?.toInt() ?? 0,
          'avatarSeed': e['name'] as String,
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: _buildLeaderboardContent(mappedList, isGroup: true, onItemTap: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailsScreen(
                  groupId: item['id'] as int,
                  groupName: item['name'] as String,
                ),
              ),
            );
          }),
        );
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

  Color _getGroupColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.dareColor,
      AppColors.warning,
      const Color(0xFF8F5BFF),
      const Color(0xFFFF8C4B),
    ];
    int hash = 0;
    for (var i = 0; i < name.length; i++) {
      hash += name.codeUnitAt(i);
    }
    return colors[hash % colors.length];
  }

  Widget _buildLeaderboardContent(List<Map<String, dynamic>> listData, {bool isGroup = false, void Function(Map<String, dynamic>)? onItemTap}) {
    Map<String, dynamic>? firstItem;
    Map<String, dynamic>? secondItem;
    Map<String, dynamic>? thirdItem;

    if (listData.isNotEmpty) {
      firstItem = listData[0];
    }
    if (listData.length > 1) {
      secondItem = listData[1];
    }
    if (listData.length > 2) {
      thirdItem = listData[2];
    }

    bool isGameStarted = true;
    if (listData.isNotEmpty) {
      bool allZeros = true;
      for (var i = 0; i < (listData.length < 3 ? listData.length : 3); i++) {
        if (listData[i]['score'] != 0) {
          allZeros = false;
          break;
        }
      }
      if (allZeros) {
        isGameStarted = false;
      }
    }

    final List<Map<String, dynamic>> remainingPlayers = isGameStarted 
        ? (listData.length > 3 ? listData.sublist(3) : [])
        : listData;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Podiums (Hạng 1, 2, 3)
              if (isGameStarted)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (secondItem != null)
                      _buildPodiumColumn(
                        name: secondItem['name'],
                        score: secondItem['score'],
                        rank: 2,
                        height: 120,
                        avatarSeed: secondItem['avatarSeed'],
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        isGroup: isGroup,
                        onTap: onItemTap != null ? () => onItemTap(secondItem!) : null,
                      )
                    else
                      const SizedBox(width: 80),
                    const SizedBox(width: 16),
                    if (firstItem != null)
                      _buildPodiumColumn(
                        name: firstItem['name'],
                        score: firstItem['score'],
                        rank: 1,
                        height: 170,
                        avatarSeed: firstItem['avatarSeed'],
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF9800)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        hasCrown: true,
                        isGroup: isGroup,
                        onTap: onItemTap != null ? () => onItemTap(firstItem!) : null,
                      ),
                    const SizedBox(width: 16),
                    if (thirdItem != null)
                      _buildPodiumColumn(
                        name: thirdItem['name'],
                        score: thirdItem['score'],
                        rank: 3,
                        height: 90,
                        avatarSeed: thirdItem['avatarSeed'],
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        isGroup: isGroup,
                        onTap: onItemTap != null ? () => onItemTap(thirdItem!) : null,
                      )
                    else
                      const SizedBox(width: 80),
                  ],
                ),
              if (isGameStarted) const SizedBox(height: 24),
              // Rest of Leaderboard list
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: remainingPlayers.length,
                  itemBuilder: (context, index) {
                    final item = remainingPlayers[index];
                    final rank = isGameStarted ? (index + 4) : (index + 1);

                    return GestureDetector(
                      onTap: onItemTap != null ? () => onItemTap(item) : null,
                      child: Container(
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
                          isGroup
                              ? Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getGroupColor(item['name']),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['name'].toString().isNotEmpty ? item['name'].toString()[0].toUpperCase() : 'G',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : ClipRRect(
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
                          const SizedBox(width: 20),
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
                              color: const Color(0xFFF3F0FF),
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
    required Gradient gradient,
    bool hasCrown = false,
    bool isGroup = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
                    color: rank == 1 ? const Color(0xFFFFB300) : (rank == 2 ? const Color(0xFFBDBDBD) : const Color(0xFFFFB74D)),
                    width: 3.0,
                  ),
                  boxShadow: rank == 1 ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isGroup
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getGroupColor(name),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'G',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : ClipOval(
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
                    gradient: rank == 1 ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF9800)]) 
                            : (rank == 2 ? const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)]) 
                                         : const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFF57C00)])),
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
          const SizedBox(height: 12),
          // Podium Block
          Container(
            height: height,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ]
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Faint Rank Number (Watermark)
                Positioned(
                  bottom: -28,
                  right: -16,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.15),
                      height: 1.0,
                    ),
                  ),
                ),
                // Name and Score inside the block
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(
                        '$score đ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
