import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/secret_rule_provider.dart';
import 'violator_selection_screen.dart';
import 'secret_rule_result_screen.dart';

class SecretRulePlayingScreen extends StatefulWidget {
  const SecretRulePlayingScreen({super.key});

  @override
  State<SecretRulePlayingScreen> createState() => _SecretRulePlayingScreenState();
}

class _SecretRulePlayingScreenState extends State<SecretRulePlayingScreen> {
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    // Timer is already started in startRound, but just in case:
    if (!provider.isTimerRunning) {
      provider.startTimer();
    }
  }

  void _showViolatorSelection() {
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    // Pause timer while catching violator
    provider.pauseTimer();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ViolatorSelectionScreen(),
    ).then((_) {
      // Resume timer when closed
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

  // No _skipRound needed anymore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Consumer<SecretRuleProvider>(
          builder: (context, provider, _) {
            // Handle auto transition to next round or result
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
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                if (provider.players.isNotEmpty) ...[
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
                        const SizedBox(height: 8),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.w700, 
                              color: AppColors.textPrimary, 
                              fontFamily: 'Inter',
                            ),
                            children: [
                              TextSpan(
                                text: currentPlayer, 
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 28)
                              ),
                              const TextSpan(
                                text: '  hỏi  ', 
                                style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary)
                              ),
                              TextSpan(
                                text: targetPlayer, 
                                style: const TextStyle(color: Color(0xFFFF5B7F), fontWeight: FontWeight.w900, fontSize: 28)
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ] else ...[
                  const Text(
                    'Hãy lần lượt đặt câu hỏi gài bẫy người bên cạnh!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 30),
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
                
                // Active Rules
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
                                    color: isLast ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.6),
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
                
                const SizedBox(height: 20),
                const Text(
                  'Lưu ý: Nếu vi phạm, hãy bấm "Bắt vi phạm"\nđể chọn người vi phạm.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
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
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    if (provider.allowChangeRule)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.changeRuleChances > 0 ? _changeRule : null,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('Đổi luật (${provider.changeRuleChances})'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(
                              color: provider.changeRuleChances > 0 
                                  ? AppColors.primary 
                                  : AppColors.textSecondary.withOpacity(0.3),
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
        },
      ),
    );
  }
}
