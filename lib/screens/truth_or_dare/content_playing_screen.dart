import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/truth_or_dare_provider.dart';
import '../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    _timeLeft = todProvider.timeLimit;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _onSkip(); // Time out is treated as skip
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onAnswer() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SuccessScreen()),
    );
  }

  void _onSkip() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SkipScreen()),
    );
  }

  String _getCategory(String type, String level) {
    if (type == 'truth') {
      return level == 'hardcore' ? 'Secret' : 'Lifestyle';
    } else if (type == 'dare') {
      return level == 'hardcore' ? 'Extreme' : 'Funny';
    }
    return 'General';
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
            colors: [Color(0xFFFFF0F2), Color(0xFFFFFFFF), Color(0xFFFFF5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFEBF3FF), Color(0xFFFFFFFF), Color(0xFFF0F5FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                          icon: const Icon(Icons.volume_up_rounded, size: 28, color: AppColors.textPrimary),
                          onPressed: () {},
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
                                  child: Image.network(
                                    'https://api.dicebear.com/7.x/lorelei/png?seed=${todProvider.currentPlayer?.name ?? ""}',
                                    fit: BoxFit.cover,
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
                    // Timer Pill
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isTruth ? const Color(0xFFFFCCD3) : const Color(0xFFC0D9FF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
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
                              color: isTruth ? const Color(0xFFFF4B72) : const Color(0xFF368DFF),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '00:${_timeLeft.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isTruth ? const Color(0xFFFF4B72) : const Color(0xFF368DFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Question display card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: isTruth ? const Color(0xFFFFECEF) : const Color(0xFFEBF3FF),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.06),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Card Header Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isTruth ? Icons.help_outline_rounded : Icons.bolt_rounded,
                              color: primaryColor,
                              size: 32,
                            ),
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
                                  'Chủ đề: ${_getCategory(content.type, content.level)}',
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
                    Row(
                      children: [
                        // Option 1: Answer (+Reward points)
                        Expanded(
                          child: GestureDetector(
                            onTap: _onAnswer,
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
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Trả lời',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
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
                                    'Bỏ qua',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
