import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import '../providers/player_provider.dart';
import '../providers/group_provider.dart';
import 'statistics_screen.dart';
import 'history_screen.dart';
import 'tutorial_screen.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;

  @override
  void initState() {
    super.initState();
    _isSoundEnabled = AudioService.instance.isSoundEnabled;
    _isMusicEnabled = AudioService.instance.isMusicEnabled;
  }

  void _onResetData() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đặt lại dữ liệu', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử chơi và danh sách người chơi hiện tại?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await playerProvider.resetScores();
                final currentGroup = groupProvider.currentGroup;
                if (currentGroup != null) {
                  await groupProvider.deleteGroup(currentGroup.id!);
                }
                if (mounted) {
                  AppNotification.success(context, 'Đã đặt lại toàn bộ dữ liệu thành công! ✅');
                }
              },
              child: const Text('Đặt lại', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 12),
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE8EBF3), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        'https://api.dicebear.com/7.x/lorelei/png?seed=Minh',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name and Points
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Minh',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.edit_rounded, color: AppColors.textSecondary.withOpacity(0.6), size: 16),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                            SizedBox(width: 4),
                            Text(
                              '120 điểm',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
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
            const SizedBox(height: 24),
            // Settings Rows
            _buildSwitchRow(
              icon: Icons.volume_up_rounded,
              iconColor: const Color(0xFF7C5CFF),
              title: 'Âm thanh',
              value: _isSoundEnabled,
              onChanged: (val) async {
                setState(() {
                  _isSoundEnabled = val;
                });
                await AudioService.instance.setSoundEnabled(val);
              },
            ),
            const SizedBox(height: 12),
            _buildSwitchRow(
              icon: Icons.music_note_rounded,
              iconColor: const Color(0xFFFF5B7F),
              title: 'Nhạc nền',
              value: _isMusicEnabled,
              onChanged: (val) async {
                setState(() {
                  _isMusicEnabled = val;
                });
                await AudioService.instance.setMusicEnabled(val);
              },
            ),
            const SizedBox(height: 12),
            _buildNavigationRow(
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF368DFF),
              title: 'Ngôn ngữ',
              valueText: 'Tiếng Việt',
              onTap: () {
                AppNotification.info(context, 'Chức năng đổi ngôn ngữ sớm ra mắt! 🌍');
              },
            ),
            const SizedBox(height: 12),
            _buildNavigationRow(
              icon: Icons.bar_chart_rounded,
              iconColor: const Color(0xFF3DD99F),
              title: 'Thống kê thành tích',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildNavigationRow(
              icon: Icons.history_rounded,
              iconColor: const Color(0xFFFFAF36),
              title: 'Lịch sử chơi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildNavigationRow(
              icon: Icons.color_lens_rounded,
              iconColor: const Color(0xFF9D5CFF),
              title: 'Chủ đề',
              valueText: 'Sáng',
              onTap: () {
                AppNotification.info(context, 'Chức năng đổi chủ đề sớm ra mắt! 🎨');
              },
            ),
            const SizedBox(height: 12),
            _buildNavigationRow(
              icon: Icons.menu_book_rounded,
              iconColor: const Color(0xFFFF7657),
              title: 'Hướng dẫn',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TutorialScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildNavigationRow(
              icon: Icons.star_outline_rounded,
              iconColor: const Color(0xFFFFAF36),
              title: 'Đánh giá ứng dụng',
              onTap: () {
                AppNotification.info(context, 'Chức năng đánh giá sớm ra mắt! ⭐');
              },
            ),
            const SizedBox(height: 12),
            _buildNavigationRow(
              icon: Icons.share_rounded,
              iconColor: const Color(0xFF7C5CFF),
              title: 'Chia sẻ ứng dụng',
              onTap: () {
                AppNotification.info(context, 'Chức năng chia sẻ sớm ra mắt! 📤');
              },
            ),
            const SizedBox(height: 12),
            _buildNavigationRow(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF707E94),
              title: 'Giới thiệu',
              onTap: () {
                AppNotification.info(context, 'Trang giới thiệu sớm ra mắt! ℹ️');
              },
            ),
            const SizedBox(height: 28),
            // Actions
            OutlinedButton(
              onPressed: _onResetData,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE8EBF3), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Đặt lại dữ liệu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7C5CFF),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                AppNotification.info(context, 'Chức năng đăng xuất sớm ra mắt! 🚪');
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF4B72),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C5CFF),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? valueText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (valueText != null)
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}
