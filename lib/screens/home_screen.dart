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
import 'truth_or_dare/result_screen.dart';
import 'group_setup_screen.dart';
import 'secret_rule/secret_rule_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  void _onGameCardTap(BuildContext context, String modeName) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (modeName == 'truth_or_dare') {
      final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
      todProvider.reset();
      playerProvider.resetScores();
      groupProvider.clearCurrentGroup();

      Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
    } else if (modeName == 'secret_rule') {
      playerProvider.resetScores();
      groupProvider.clearCurrentGroup();
      
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const GroupSetupScreen(
          gameMode: 'secret_rule',
          nextRoute: SecretRuleSetupScreen(),
        ),
      ));
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
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFF7C5CFF).withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7C5CFF),
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            );
          }),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentTabIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 0,
            height: 70,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 26),
                selectedIcon: Icon(Icons.home_filled, color: AppColors.primary, size: 30),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined, size: 26),
                selectedIcon: Icon(Icons.history_rounded, color: AppColors.primary, size: 30),
                label: 'Lịch sử',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined, size: 26),
                selectedIcon: Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 30),
                label: 'Xếp hạng',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, size: 26),
                selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primary, size: 30),
                label: 'Cài đặt',
              ),
            ],
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
                
                // Coins Pill Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF7E6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFECC0), width: 1),
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
}
