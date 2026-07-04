import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _activeTab = 0; // 0: Cách chơi, 1: Mẹo chơi hay

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hướng dẫn',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            // Sub-tabs
            Row(
              children: [
                _buildSubTab('Cách chơi', 0),
                const SizedBox(width: 16),
                _buildSubTab('Mẹo chơi hay', 1),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Text(
                    _activeTab == 0 ? 'Cách chơi' : 'Mẹo chơi hay',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_activeTab == 0) ...[
                    // Step 1
                    _buildStepCard(
                      stepNumber: 1,
                      icon: Icons.layers_rounded,
                      iconColor: const Color(0xFF7C5CFF),
                      title: 'Chọn chủ đề',
                      subtitle: 'Chọn chủ đề bạn thích để bắt đầu trò chơi.',
                    ),
                    const SizedBox(height: 16),
                    // Step 2
                    _buildStepCard(
                      stepNumber: 2,
                      icon: Icons.chat_bubble_rounded,
                      iconColor: const Color(0xFFFF5B7F),
                      title: 'Đọc câu hỏi Truth / Dare',
                      subtitle: 'Đọc câu hỏi được hiển thị trên màn hình.',
                    ),
                    const SizedBox(height: 16),
                    // Step 3
                    _buildStepCard(
                      stepNumber: 3,
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: const Color(0xFF3DD99F),
                      title: 'Trả lời hoặc bỏ qua',
                      subtitle: 'Trả lời để nhận điểm cao hoặc bỏ qua nếu muốn.',
                    ),
                    const SizedBox(height: 16),
                    // Step 4
                    _buildStepCard(
                      stepNumber: 4,
                      icon: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFFFFAF36),
                      title: 'Tích điểm và chiến thắng',
                      subtitle: 'Người có số điểm cao nhất sau các vòng chơi sẽ chiến thắng!',
                    ),
                  ] else ...[
                    // Tip 1
                    _buildStepCard(
                      stepNumber: 1,
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFFF5B7F),
                      title: 'Thành thật tuyệt đối',
                      subtitle: 'Spinix vui nhất khi mọi người cởi mở và chia sẻ bí mật của mình.',
                    ),
                    const SizedBox(height: 16),
                    // Tip 2
                    _buildStepCard(
                      stepNumber: 2,
                      icon: Icons.sports_kabaddi_rounded,
                      iconColor: const Color(0xFF368DFF),
                      title: 'Hình phạt lầy lội',
                      subtitle: 'Đừng ngại chịu phạt! Những hình phạt lầy lội sẽ tạo nên những tiếng cười sảng khoái.',
                    ),
                    const SizedBox(height: 16),
                    // Tip 3
                    _buildStepCard(
                      stepNumber: 3,
                      icon: Icons.timer_rounded,
                      iconColor: const Color(0xFF3DD99F),
                      title: 'Thời gian kịch tính',
                      subtitle: 'Trả lời nhanh trong 30 giây để tạo không khí kịch tính và hào hứng cho cả nhóm.',
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Yellow Bulb Tip card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF7E6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFFECC0), width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFAF36), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _activeTab == 0
                                ? 'Mẹo: Hãy thành thật và vui vẻ để trò chơi trở nên thú vị hơn nhé!'
                                : 'Mẹo: Bạn có thể tự đặt ra hình phạt riêng để tăng độ hấp dẫn!',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC69100),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Video Button
                  OutlinedButton(
                    onPressed: () {
                      AppNotification.info(context, 'Video hướng dẫn sớm ra mắt! 🎬');
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE8EBF3), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_fill_rounded, color: Color(0xFF707E94), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Xem video hướng dẫn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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

  Widget _buildSubTab(String title, int tabIndex) {
    final isSelected = _activeTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = tabIndex;
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

  Widget _buildStepCard({
    required int stepNumber,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF7C5CFF),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    height: 1.4,
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
