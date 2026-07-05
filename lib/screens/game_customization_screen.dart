import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import '../providers/truth_or_dare_provider.dart';
import '../providers/player_provider.dart';
import '../providers/group_provider.dart';
import '../providers/game_content_provider.dart';
import 'group_setup_screen.dart';

class GameCustomizationScreen extends StatefulWidget {
  final List<String> categories;

  const GameCustomizationScreen({super.key, required this.categories});

  @override
  State<GameCustomizationScreen> createState() =>
      _GameCustomizationScreenState();
}

class _GameCustomizationScreenState extends State<GameCustomizationScreen> {
  int _timeLimitIndex = 1; // 0: 15s, 1: 20s, 2: 30s, 3: 45s
  int _rewardPointsIndex = 1; // 0: +10, 1: +20, 2: +30
  int _penaltyPointsIndex = 1; // 0: -5, 1: -10, 2: -15
  int _roundsIndex = 1; // 0: 3 vòng, 1: 5 vòng, 2: 7 vòng, 3: 10 vòng
  int _difficultyIndex = 0; // 0: Tất cả, 1: Dễ, 2: Vừa, 3: Khó, 4: Kịch tính

  final List<int> _timeLimits = [15, 20, 30, 45];
  final List<int> _rewardPoints = [10, 20, 30];
  final List<int> _penaltyPoints = [-15, -10, -5];
  final List<int> _rounds = [3, 5, 7, 10];
  List<String> _difficultyLabels = ['Tất cả'];
  List<String?> _difficultyValues = [null];
  final TextEditingController _teamNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDifficulties();
      // Đã xóa đoạn gán tên groupProvider.currentGroup!.name vào _teamNameController
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _loadDifficulties() {
    final provider = Provider.of<GameContentProvider>(context, listen: false);
    var contents = [...provider.truths, ...provider.dares, ...provider.rules];

    if (widget.categories.isNotEmpty &&
        !widget.categories.contains('Tổng hợp') &&
        !widget.categories.contains('Tất cả')) {
      contents = contents
          .where((c) => widget.categories.contains(c.category))
          .toList();
    }

    final uniqueLevels = contents
        .map((c) => c.level)
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList();

    // Sort to have a consistent order (e.g., easy, medium, hard) if possible
    final predefinedOrder = ['easy', 'medium', 'hard', 'extreme', '18+'];
    uniqueLevels.sort((a, b) {
      int indexA = predefinedOrder.indexOf(a);
      int indexB = predefinedOrder.indexOf(b);
      if (indexA == -1) indexA = 999;
      if (indexB == -1) indexB = 999;
      if (indexA == indexB) return a.compareTo(b);
      return indexA.compareTo(indexB);
    });

    setState(() {
      _difficultyLabels = ['Tất cả', ...uniqueLevels];
      _difficultyValues = [null, ...uniqueLevels];
      _difficultyIndex = 0;
    });
  }

  void _onStart() async {
    final teamName = _teamNameController.text.trim();
    if (teamName.isEmpty) {
      AppNotification.warning(context, 'Vui lòng nhập tên đội chơi!');
      return;
    }

    try {
      final todProvider = Provider.of<TruthOrDareProvider>(
        context,
        listen: false,
      );
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final playerProvider = Provider.of<PlayerProvider>(
        context,
        listen: false,
      );

      // Save configuration in provider
      todProvider.configureGame(
        rounds: _rounds[_roundsIndex],
        time: _timeLimits[_timeLimitIndex],
        reward: _rewardPoints[_rewardPointsIndex],
        penalty: _penaltyPoints[_penaltyPointsIndex],
        categories: widget.categories,
        difficulty: _difficultyValues[_difficultyIndex],
      );

      // Initialize or update group
      if (groupProvider.currentGroup == null) {
        await groupProvider.createGroup(teamName);
        playerProvider.clearPlayers();
      } else if (groupProvider.currentGroup!.name != teamName) {
        await groupProvider.updateGroupName(
          groupProvider.currentGroup!.id!,
          teamName,
        );
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroupSetupScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(context, 'Lỗi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTime = _timeLimits[_timeLimitIndex];
    final activeReward = _rewardPoints[_rewardPointsIndex];
    final activePenalty = _penaltyPoints[_penaltyPointsIndex];
    final activeRounds = _rounds[_roundsIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tùy chỉnh trò chơi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const Text(
                    'Cài đặt chung',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Team name setting
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE8EBF3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C5CFF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.group_rounded,
                            color: Color(0xFF7C5CFF),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _teamNameController,
                            decoration: const InputDecoration(
                              hintText: 'Nhập tên đội chơi...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCustomRow(
                    icon: Icons.access_time_filled_rounded,
                    iconColor: const Color(0xFFFF5B7F),
                    title: 'Thời gian trả lời',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_timeLimitIndex > 0) {
                              setState(() {
                                _timeLimitIndex--;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Thời gian tối thiểu là ${_timeLimits.first} giây!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$activeTime giây',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_timeLimitIndex < _timeLimits.length - 1) {
                              setState(() {
                                _timeLimitIndex++;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Thời gian tối đa là ${_timeLimits.last} giây!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Reward points setting
                  _buildCustomRow(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFFAF36),
                    title: 'Điểm khi trả lời đúng',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_rewardPointsIndex > 0) {
                              setState(() {
                                _rewardPointsIndex--;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Điểm cộng tối thiểu là +${_rewardPoints.first}!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '+$activeReward điểm',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_rewardPointsIndex < _rewardPoints.length - 1) {
                              setState(() {
                                _rewardPointsIndex++;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Điểm cộng tối đa là +${_rewardPoints.last}!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Penalty points setting
                  _buildCustomRow(
                    icon: Icons.cancel_rounded,
                    iconColor: const Color(0xFFFF4B72),
                    title: 'Điểm khi bỏ qua',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_penaltyPointsIndex > 0) {
                              setState(() {
                                _penaltyPointsIndex--;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Điểm phạt tối đa là ${_penaltyPoints.first}!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$activePenalty điểm',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_penaltyPointsIndex <
                                _penaltyPoints.length - 1) {
                              setState(() {
                                _penaltyPointsIndex++;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Điểm phạt tối thiểu là ${_penaltyPoints.last}!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Round count setting
                  _buildCustomRow(
                    icon: Icons.loop_rounded,
                    iconColor: const Color(0xFF3DD99F),
                    title: 'Số vòng chơi',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_roundsIndex > 0) {
                              setState(() {
                                _roundsIndex--;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Số vòng chơi tối thiểu là ${_rounds.first}!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$activeRounds vòng',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_roundsIndex < _rounds.length - 1) {
                              setState(() {
                                _roundsIndex++;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Số vòng chơi tối đa là ${_rounds.last}!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Difficulty setting
                  _buildCustomRow(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF9B3D),
                    title: 'Mức độ',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_difficultyIndex > 0) {
                              setState(() {
                                _difficultyIndex--;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Mức độ thấp nhất là ${_difficultyLabels.first}!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _difficultyLabels[_difficultyIndex],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_difficultyIndex <
                                _difficultyLabels.length - 1) {
                              setState(() {
                                _difficultyIndex++;
                              });
                            } else {
                              AppNotification.warning(
                                context,
                                'Mức độ cao nhất là ${_difficultyLabels.last}!',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Rules summary card
                  const Text(
                    'Luật chơi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4FD),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFDDD9FA),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          color: Color(0xFF7C5CFF),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mỗi người chơi lần lượt trả lời câu hỏi.\nTrả lời đúng: +$activeReward điểm.\nBỏ qua: $activePenalty điểm.',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7C5CFF),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Start Button
            ElevatedButton(
              onPressed: _onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: const Color(0xFF7C5CFF).withOpacity(0.3),
              ),
              child: const Text(
                'Bắt đầu trò chơi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) {
    return Container(
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
          trailing,
        ],
      ),
    );
  }
}
