import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../providers/secret_rule_provider.dart';
import '../../models/secret_rule.dart';
import 'violator_selection_screen.dart';
import 'secret_rule_result_screen.dart';

class SecretRulePlayingScreen extends StatefulWidget {
  const SecretRulePlayingScreen({super.key});

  @override
  State<SecretRulePlayingScreen> createState() => _SecretRulePlayingScreenState();
}

class _SecretRulePlayingScreenState extends State<SecretRulePlayingScreen> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  List<SecretRule> _cardRules = [];
  int? _selectedCardIndex;
  int _lastRound = 0;
  bool _showCardSelection = true;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showCardSelection = false;
            });
          }
        });
      }
    });

    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    _lastRound = provider.currentRound;
    provider.addListener(_onProviderChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCardRules();
    });
  }

  void _onProviderChanged() {
    if (!mounted) return;
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    if (_lastRound != provider.currentRound) {
      _lastRound = provider.currentRound;
      _loadCardRules();
    }
  }

  void _loadCardRules() {
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    if (provider.allRules.isEmpty) {
      provider.loadRules().then((_) {
        if (mounted) {
          _setCardRules(provider);
        }
      });
    } else {
      _setCardRules(provider);
    }
  }

  void _setCardRules(SecretRuleProvider provider) {
    setState(() {
      _cardRules = provider.peekRandomRules(3);
      _selectedCardIndex = null;
      _showCardSelection = true;
    });
    _flipController.reset();
  }

  @override
  void dispose() {
    Provider.of<SecretRuleProvider>(context, listen: false).removeListener(_onProviderChanged);
    _flipController.dispose();
    super.dispose();
  }

  void _onCardTapped(int index) {
    if (_selectedCardIndex != null) return;

    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    provider.setActiveRule(_cardRules[index]);

    setState(() {
      _selectedCardIndex = index;
    });
    _flipController.forward();
  }

  void _showViolatorSelection() {
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    provider.pauseTimer();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ViolatorSelectionScreen(),
    ).then((_) {
      if (mounted) {
        final prov = Provider.of<SecretRuleProvider>(context, listen: false);
        if (prov.timeLeft > 0) {
          prov.resumeTimer();
        }
      }
    });
  }

  void _changeRule() {
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    if (provider.changeRuleChances > 0) {
      provider.changeCurrentRule();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Consumer<SecretRuleProvider>(
          builder: (context, provider, _) {
            if (provider.timeLeft == 0 && provider.isTimerRunning == false) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (provider.isGameOver) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SecretRuleResultScreen()),
                  );
                } else {
                  provider.nextTurn();
                }
              });
            }

            final minutes = (provider.timeLeft / 60).floor();
            final seconds = provider.timeLeft % 60;
            final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () {
                    provider.stopTimer();
                    Navigator.pop(context);
                  },
                ),
                Text(
                  'Vòng ${provider.currentRound}/${provider.totalRounds}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF7C5CFF)),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C5CFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<SecretRuleProvider>(
        builder: (context, provider, _) {
          if (_showCardSelection) {
            return _buildCardSelectionUI(provider);
          }
          return _buildPlayingUI(provider);
        },
      ),
    );
  }

  // ─── Phase 1: Card Selection UI ──────────────────────────────────
  Widget _buildCardSelectionUI(SecretRuleProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          if (provider.players.isNotEmpty)
            Builder(builder: (context) {
              final currentPlayer = provider.players[provider.currentPlayerIndex].name;
              final targetPlayerIndex = (provider.currentPlayerIndex + 1) % provider.players.length;
              final targetPlayer = provider.players[targetPlayerIndex].name;

              return Column(
                children: [
                  const Text(
                    'LƯỢT HIỆN TẠI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: currentPlayer,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 26),
                        ),
                        const TextSpan(
                          text: '  hỏi  ',
                          style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                        TextSpan(
                          text: targetPlayer,
                          style: const TextStyle(color: Color(0xFFFF5B7F), fontWeight: FontWeight.w900, fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          const SizedBox(height: 32),
          const Text(
            'CHỌN THẺ BÍ MẬT',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Mỗi thẻ chứa một luật khác nhau.\nChọn một thẻ để khám phá!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 220,
            child: Row(
              children: List.generate(3, (index) {
                if (index >= _cardRules.length) {
                  return const Expanded(child: SizedBox());
                }
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 8,
                      right: index == 2 ? 0 : 8,
                    ),
                    child: _buildCard(index),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ─── Phase 2: Playing UI (original old UI) ───────────────────────
  Widget _buildPlayingUI(SecretRuleProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          if (provider.players.isNotEmpty)
            Builder(builder: (context) {
              final currentPlayer = provider.players[provider.currentPlayerIndex].name;
              final targetPlayerIndex = (provider.currentPlayerIndex + 1) % provider.players.length;
              final targetPlayer = provider.players[targetPlayerIndex].name;

              return Column(
                children: [
                  const Text(
                    'LƯỢT HIỆN TẠI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: currentPlayer,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 26),
                        ),
                        const TextSpan(
                          text: '  hỏi  ',
                          style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                        TextSpan(
                          text: targetPlayer,
                          style: const TextStyle(color: Color(0xFFFF5B7F), fontWeight: FontWeight.w900, fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          const SizedBox(height: 24),
          const Text(
            'LUẬT HIỆN TẠI',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.activeRules.isNotEmpty)
                      ...provider.activeRules.asMap().entries.map((entry) {
                        final isLast = entry.key == provider.activeRules.length - 1;
                        final rule = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            rule.content,
                            style: TextStyle(
                              fontSize: isLast ? 32 : 20,
                              fontWeight: isLast ? FontWeight.w900 : FontWeight.w600,
                              color: isLast ? AppColors.textPrimary : AppColors.textSecondary.withValues(alpha: 0.6),
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                    const Text(
                      '🤫',
                      style: TextStyle(fontSize: 60),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lưu ý: Nếu vi phạm, hãy bấm "Bắt vi phạm"\nđể chọn người vi phạm.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showViolatorSelection,
            icon: const Icon(Icons.campaign_rounded, color: Colors.white),
            label: const Text(
              'Bắt vi phạm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B72),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (provider.allowChangeRule)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.changeRuleChances > 0 ? _changeRule : null,
                    icon: Icon(Icons.refresh_rounded, color: provider.changeRuleChances > 0 ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3)),
                    label: Text(
                      'Đổi luật (${provider.changeRuleChances})',
                      style: TextStyle(color: provider.changeRuleChances > 0 ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3)),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(
                        color: provider.changeRuleChances > 0
                            ? AppColors.primary
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              if (provider.allowChangeRule) const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: provider.nextTurn,
                  icon: const Icon(Icons.fast_forward_rounded, color: AppColors.textPrimary),
                  label: const Text(
                    'Qua lượt',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Card Widgets ────────────────────────────────────────────────
  Widget _buildCard(int index) {
    if (_selectedCardIndex == index) {
      return AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return SecretFlipCard(
            angle: _flipAnimation.value,
            front: _buildCardFront(index),
            back: _buildCardBack(index),
          );
        },
      );
    }

    return GestureDetector(
      onTap: _selectedCardIndex == null ? () => _onCardTapped(index) : null,
      child: SecretFlipCard(
        angle: 0.0,
        front: _buildCardFront(index),
        back: _buildCardBack(index),
      ),
    );
  }

  Widget _buildCardFront(int index) {
    final gradientPairs = [
      [const Color(0xFF7C5CFF), const Color(0xFF5B21B6)],
      [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      [const Color(0xFF6D28D9), const Color(0xFF4C1D95)],
    ];
    final colors = gradientPairs[index % gradientPairs.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors[0], colors[1]],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.4),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.85),
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(2, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(int index) {
    if (index >= _cardRules.length) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E202C), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1E202C),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
      );
    }

    final rule = _cardRules[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E202C), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1E202C),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF7C5CFF).withValues(alpha: 0.2), width: 1),
              ),
              child: const Text(
                'LUẬT BÍ MẬT',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7C5CFF),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const Spacer(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  rule.content,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E202C),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rule.level,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7D8398),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SecretFlipCard extends StatelessWidget {
  final Widget front;
  final Widget back;
  final double angle;

  const SecretFlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    final isBack = angle >= math.pi / 2;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(angle),
      alignment: Alignment.center,
      child: isBack
          ? Transform(
              transform: Matrix4.identity()..rotateY(math.pi),
              alignment: Alignment.center,
              child: back,
            )
          : front,
    );
  }
}
