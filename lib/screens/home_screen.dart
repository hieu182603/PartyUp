import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../providers/player_provider.dart';
import '../providers/truth_or_dare_provider.dart';
import '../services/database_helper.dart';
import 'categories_screen.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'truth_or_dare/random_player_screen.dart';
import 'truth_or_dare/truth_or_dare_choice_screen.dart';
import 'truth_or_dare/content_playing_screen.dart';
import 'truth_or_dare/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  bool _isLoadingContinue = false;

  void _onGameCardTap(BuildContext context, String modeName) {
    if (modeName == 'truth_or_dare') {
      final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
      final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      
      todProvider.reset();
      playerProvider.resetScores();
      groupProvider.clearCurrentGroup();

      Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
    } else {
      AppNotification.info(context, 'Chức năng đang phát triển, sớm ra mắt! 🚀');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabBodies = [
      _buildHomeBody(context),
      const HistoryScreen(),
      const LeaderboardScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: tabBodies[_currentTabIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: BottomNavigationBar(
              currentIndex: _currentTabIndex,
              selectedItemColor: const Color(0xFF7C5CFF),
              unselectedItemColor: AppColors.textSecondary,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12.0,
              unselectedFontSize: 12.0,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
                BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
                BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Bảng xếp hạng'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header Row: Avatar, Name, Coins display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: RandomAvatar('Minh', trBackground: false, height: 48, width: 48),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Xin chào, Minh! 👋',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Level 5',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Coins Pill Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF7E6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFECC0), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '1200',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC69100),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Main Heading
            const Text(
              'Sẵn sàng cho\nđêm tiệc chưa?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            // Scrollable Menu List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Game Card 1: Truth or Dare
                  _buildGameCard(
                    context,
                    title: 'Truth or Dare',
                    subtitle: 'Chơi ngay',
                    icon: Icons.casino_outlined,
                    gradient: AppColors.truthGradient,
                    onTap: () => _onGameCardTap(context, 'truth_or_dare'),
                  ),
                  const SizedBox(height: 16),
                  // Game Card 2: Lucky Wheel
                  _buildGameCard(
                    context,
                    title: 'Lucky Wheel',
                    subtitle: 'Vòng quay may mắn',
                    icon: Icons.wb_sunny_outlined,
                    gradient: AppColors.luckyWheelGradient,
                    onTap: () => _onGameCardTap(context, 'lucky_wheel'),
                  ),
                  const SizedBox(height: 16),
                  // Game Card 3: Secret Rule
                  _buildGameCard(
                    context,
                    title: 'Secret Rule',
                    subtitle: 'Luật bí mật',
                    icon: Icons.theater_comedy_outlined,
                    gradient: AppColors.secretRuleGradient,
                    onTap: () => _onGameCardTap(context, 'secret_rule'),
                  ),
                  const SizedBox(height: 16),
                  // Game Card 4: Mini Games
                  _buildGameCard(
                    context,
                    title: 'Mini Games',
                    subtitle: 'Thử thách vui nhộn',
                    icon: Icons.sports_esports_outlined,
                    gradient: AppColors.miniGamesGradient,
                    onTap: () => _onGameCardTap(context, 'mini_games'),
                  ),
                  const SizedBox(height: 24),
                  // Continue Game Card - only show when there is an ongoing game
                  Consumer<TruthOrDareProvider>(
                    builder: (context, todProvider, _) {
                      if (todProvider.currentSessionId == null || todProvider.isGameOver) return const SizedBox.shrink();
                      final roundInfo = 'Vòng ${todProvider.currentRound}/${todProvider.totalRounds} • Truth or Dare';
                      return Column(
                        children: [
                          _buildContinueCard(
                            context,
                            title: 'Tiếp tục trò chơi',
                            subtitle: roundInfo,
                            isLoading: _isLoadingContinue,
                            onTap: _isLoadingContinue ? null : () async {
                              setState(() => _isLoadingContinue = true);
                              try {
                                final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
                                final groupProvider = Provider.of<GroupProvider>(context, listen: false);

                                // If players list is empty, reload from DB
                                if (playerProvider.players.isEmpty) {
                                final groupId = groupProvider.currentGroup?.id;
                                if (groupId != null) {
                                  // Group is already set — just reload players
                                  await playerProvider.loadPlayersForGroup(groupId);
                                } else {
                                  // No group set — find the group for this session
                                  final groups = await DatabaseHelper.instance.getGroups();
                                  if (groups.isNotEmpty && context.mounted) {
                                    groupProvider.setCurrentGroup(groups.first);
                                    await playerProvider.loadPlayersForGroup(groups.first.id!);
                                  }
                                }
                              }

                              if (!context.mounted) return;

                              // Navigate based on current game state
                              final state = todProvider.state;
                              if (state == 'choosing_type') {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const TruthOrDareChoiceScreen()));
                              } else if (state == 'playing') {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentPlayingScreen()));
                              } else if (state == 'result') {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
                              } else {
                                // selecting_player — go to random player screen
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const RandomPlayerScreen()));
                              }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoadingContinue = false);
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background circle
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4FD),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFF)),
                      ),
                    )
                  : const Icon(Icons.restore, color: Color(0xFF7C5CFF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
