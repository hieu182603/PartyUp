import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:random_avatar/random_avatar.dart';
import '../../providers/player_provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../core/theme/app_colors.dart';
import 'truth_or_dare_choice_screen.dart';
import 'result_screen.dart';

class RandomPlayerScreen extends StatefulWidget {
  const RandomPlayerScreen({super.key});

  @override
  State<RandomPlayerScreen> createState() => _RandomPlayerScreenState();
}

class _RandomPlayerScreenState extends State<RandomPlayerScreen>
    with TickerProviderStateMixin {
  int _activeCountdown = 3;
  late AnimationController _confettiController;
  late AnimationController _avatarScaleController;
  bool _noPlayerAvailable = false;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _avatarScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Select a player who hasn't played this round
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);

    final selected = todProvider.selectRandomPlayer(playerProvider.players);
    if (!selected) {
      // Round already complete — go to ResultScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ResultScreen()),
          );
        }
      });
      return;
    }

    _noPlayerAvailable = false;
    _avatarScaleController.forward();
    _startCountdownSequence();
  }

  void _startCountdownSequence() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _activeCountdown = 2);

    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _activeCountdown = 1);

    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _activeCountdown = 0);

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TruthOrDareChoiceScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _avatarScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_noPlayerAvailable) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final todProvider = Provider.of<TruthOrDareProvider>(context);
    final currentPlayer = todProvider.currentPlayer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded,
                size: 24, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 3),
            // Round indicator
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Vòng ${todProvider.currentRound}/${todProvider.totalRounds}  •  Lượt ${todProvider.playedThisRound + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C5CFF),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Countdown pills
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [3, 2, 1].map((n) {
                final active = _activeCountdown == n;
                final past = _activeCountdown < n;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: active ? 64 : 48,
                  height: active ? 64 : 48,
                  decoration: BoxDecoration(
                    color: past
                        ? const Color(0xFF7C5CFF)
                        : active
                            ? const Color(0xFFFF5B7F)
                            : const Color(0xFFF0F4FD),
                    shape: BoxShape.circle,
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color:
                                  const Color(0xFFFF5B7F).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      '$n',
                      style: TextStyle(
                        fontSize: active ? 26 : 20,
                        fontWeight: FontWeight.w900,
                        color: past || active
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            // Avatar
            Center(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _avatarScaleController,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C5CFF).withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C5CFF), Color(0xFF9B7DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child: RandomAvatar(
                      currentPlayer?.name ?? 'Player',
                      trBackground: false,
                      height: 130,
                      width: 130,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Player name
            Text(
              currentPlayer?.name ?? '',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Đến lượt bạn! 🎉',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}


