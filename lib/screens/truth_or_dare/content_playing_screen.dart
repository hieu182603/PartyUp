import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:random_avatar/random_avatar.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/game_content_provider.dart';
import '../../models/game_content.dart';
import '../../services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import '../../core/app_notification.dart';
import 'success_screen.dart';
import 'skip_screen.dart';
import 'truth_or_dare_choice_screen.dart';

class ContentPlayingScreen extends StatefulWidget {
  const ContentPlayingScreen({super.key});

  @override
  State<ContentPlayingScreen> createState() => _ContentPlayingScreenState();
}

class _ContentPlayingScreenState extends State<ContentPlayingScreen> {
  int _timeLeft = 30;
  Timer? _timer;

  bool _isLocked = false;
  bool _isTimerStarted = false;

  @override
  void initState() {
    super.initState();
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    _timeLeft = todProvider.timeLimit;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        if (_timeLeft <= 5 && _timeLeft > 0) {
          HapticFeedback.lightImpact(); // Giảm nhẹ độ rung để tránh loa bị rè
          AudioService.instance.playSFX('tick.mp3');
        }
      } else {
        _timer?.cancel();
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    if (_isLocked) return;
    setState(() => _isLocked = true);
    AudioService.instance.playSFX('siren.mp3');
    
    // Đợi 2s để nghe tiếng còi hú rồi tự chuyển lượt
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _onSkip();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onAnswer() {
    if (_isLocked) return;
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SuccessScreen()),
    );
  }

  void _onSkip() {
    // Chặn nếu đang bị khóa do timeout đang xử lý (chưa hết 2s delay)
    if (_isLocked && _timeLeft > 0) return;
    if (_isLocked && _timeLeft == 0) { /* timeout path: cho phép */ }
    setState(() => _isLocked = true);
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SkipScreen()),
    );
  }

  void _onReroll() async {
    if (_isLocked) return;
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final contentProvider = Provider.of<GameContentProvider>(context, listen: false);
    final player = todProvider.currentPlayer;
    if (player == null || !todProvider.canReroll(player.id!)) return;

    final type = todProvider.currentContent?.type ?? 'truth';
    final content = await contentProvider.getRandomContent(
      type,
      categories: todProvider.currentCategories,
      difficulty: todProvider.currentDifficulty,
      favoritesOnly: todProvider.favoritesOnly,
    );

    if (!mounted) return;

    if (content != null) {
      todProvider.useReroll(player.id!);
      todProvider.chooseType(content);
      // Fix: Hủy timer cũ và khởi động lại timer mới
      _timer?.cancel();
      setState(() {
        _timeLeft = todProvider.timeLimit;
        _isTimerStarted = false;
      });
      AudioService.instance.playSFX('tap.mp3');
    } else {
      AppNotification.error(context, 'Kho câu hỏi đã cạn, không thể đổi câu khác!');
    }
  }

  // Hiển thị category thực tế từ database
  String _getCategoryDisplay(GameContent content) {
    if (content.category.isNotEmpty && content.category != 'Tổng hợp') {
      return content.category;
    }
    // Fallback dựa theo loại
    if (content.type == 'truth') return 'Sự thật';
    if (content.type == 'dare') return 'Thử thách';
    return 'Tổng hợp';
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);
    final content = todProvider.currentContent;

    if (content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isTruth = content.type == 'truth';
    final primaryColor = isTruth ? const Color(0xFF7C5CFF) : const Color(0xFF368DFF);
    final tagText = isTruth ? 'Truth' : 'Dare';
    final tagIcon = isTruth ? Icons.help_outline_rounded : Icons.bolt_rounded;

    final bgGradient = isTruth
        ? const LinearGradient(
            colors: [Color(0xFFFFF0F4), Color(0xFFFCE4EC), Color(0xFFFFF0F4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFF0F5FF), Color(0xFFE1F0FF), Color(0xFFF0F5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          children: [
            // Background ambient glow circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.12),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isTruth ? const Color(0xFFFF5B7F) : const Color(0xFF368DFF)).withOpacity(0.08),
                      blurRadius: 100,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Custom App Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 28, color: AppColors.textPrimary),
                          onPressed: () {
                            _timer?.cancel();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const TruthOrDareChoiceScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            AudioService.instance.isSoundEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            size: 28,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {
                            AudioService.instance.setSoundEnabled(
                              !AudioService.instance.isSoundEnabled,
                            );
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Header Content Type (Truth/Dare)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tagIcon, color: primaryColor, size: 32),
                        const SizedBox(width: 10),
                        Text(
                          tagText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Active Player Header Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primaryColor.withOpacity(0.15), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: RandomAvatar(
                                    todProvider.currentPlayer?.name ?? "",
                                    trBackground: false,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Lượt của ${todProvider.currentPlayer?.name ?? ""}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Timer Pill / Progress Bar
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isTimerStarted 
                              ? Colors.white 
                              : (_timeLeft <= 5 ? const Color(0xFFFF4B72) : Colors.white),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: !_isTimerStarted 
                                ? AppColors.textSecondary.withOpacity(0.2)
                                : (_timeLeft <= 5 ? Colors.transparent : (isTruth ? const Color(0xFFFFCCD3) : const Color(0xFFC0D9FF))),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: !_isTimerStarted 
                                  ? Colors.black.withOpacity(0.02)
                                  : (_timeLeft <= 5 ? const Color(0xFFFF4B72).withOpacity(0.4) : Colors.black.withOpacity(0.02)),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              color: !_isTimerStarted
                                  ? AppColors.textSecondary.withOpacity(0.6)
                                  : (_timeLeft <= 5 ? Colors.white : (isTruth ? const Color(0xFFFF4B72) : const Color(0xFF368DFF))),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_timeLeft giây',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: !_isTimerStarted
                                    ? AppColors.textSecondary.withOpacity(0.6)
                                    : (_timeLeft <= 5 ? Colors.white : AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ProgressBar 
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _timeLeft / todProvider.timeLimit,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          !_isTimerStarted 
                              ? Colors.white 
                              : (_timeLeft <= 5 ? const Color(0xFFFF4B72) : primaryColor),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Question display card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: isTruth ? const Color(0xFFFFECEF) : const Color(0xFFEBF3FF),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Card Header Icon & Favorite Button
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isTruth ? Icons.help_outline_rounded : Icons.bolt_rounded,
                                    color: primaryColor,
                                    size: 44,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Consumer<GameContentProvider>(
                                  builder: (context, contentProvider, _) {
                                    final isFav = contentProvider.favorites.any((c) => c.id == content.id);
                                    return IconButton(
                                      icon: Icon(
                                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: isFav ? const Color(0xFFFF5B7F) : AppColors.textSecondary.withOpacity(0.5),
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        AudioService.instance.playSFX('tap.mp3');
                                        contentProvider.toggleFavorite(GameContent(
                                          id: content.id,
                                          content: content.content,
                                          type: content.type,
                                          level: content.level,
                                          isCustom: content.isCustom,
                                          isActive: content.isActive,
                                          isFavorite: isFav, // Pass current state
                                          penaltyText: content.penaltyText,
                                          points: content.points,
                                        ));
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Question content text
                          Text(
                            content.content,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_offer_rounded,
                                  color: primaryColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Chủ đề: ${_getCategoryDisplay(content)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                    // Bottom Action buttons row
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          key: ValueKey<bool>(_isTimerStarted),
                          children: [
                            // Left Action Button: Start Timer or Complete
                            Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_isTimerStarted) {
                                  setState(() {
                                    _isTimerStarted = true;
                                  });
                                  _startTimer();
                                  AudioService.instance.playSFX('tap.mp3');
                                } else {
                                  _onAnswer();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isTruth
                                        ? [const Color(0xFFFF4B72), const Color(0xFFFF7292)]
                                        : [const Color(0xFF368DFF), const Color(0xFF68A9FF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isTruth ? const Color(0xFFFF4B72) : const Color(0xFF368DFF)).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: !_isTimerStarted ? [
                                        const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 24),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Bắt đầu tính giờ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ] : [
                                        const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${todProvider.rewardPoints}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_isTimerStarted) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Hoàn thành',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: _isLocked ? Colors.white.withOpacity(0.5) : Colors.white,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Option 2: Skip (Penalty points)
                          Expanded(
                            child: GestureDetector(
                              onTap: _onSkip,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.4),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.star_rounded, color: primaryColor, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${todProvider.penaltyPoints}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bỏ cuộc',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: _isLocked ? primaryColor.withOpacity(0.5) : primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                    // Re-roll button
                    if (todProvider.currentPlayer != null && todProvider.canReroll(todProvider.currentPlayer!.id!))
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: _onReroll,
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                            label: const Text(
                              'Đổi câu khác (còn 1 lần)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                              ),
                            ),
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
      ),
    );
  }
}
