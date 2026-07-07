import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/player_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/audio_service.dart';
import 'package:confetti/confetti.dart';
import 'result_screen.dart';
import 'random_player_screen.dart';

/// Called after the player succeeds at a Truth or Dare challenge.
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late ConfettiController _confettiController;
  bool _isLoading = true;
  String? _savedContentType; // Lưu lại type trước khi recordAnswer xóa content

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    AudioService.instance.playSFX('success.mp3');
    
    // Lưu type trước khi record
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    _savedContentType = todProvider.currentContent?.type;

    // Record the answer immediately so the round-tracking Set is updated
    // before we decide where to navigate.
    _recordAndDecide();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _recordAndDecide() async {
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final player = todProvider.currentPlayer;

    try {
      if (player != null) {
        final points = todProvider.rewardPoints;
        await playerProvider.updatePlayerScore(player.id!, points);
        todProvider.recordAnswer(points);
      }
    } catch (e) {
      debugPrint('Lỗi khi ghi nhận điểm: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onContinue(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    final roundComplete = todProvider.isRoundComplete(playerProvider.players.length);
    todProvider.completeTurn(roundComplete);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => roundComplete ? const ResultScreen() : const RandomPlayerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),

                // Big success emoji / icon
                const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 90)),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Xuất sắc!',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  '+${todProvider.rewardPoints} điểm',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3DD99F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _savedContentType == 'truth'
                      ? 'Đã trả lời thật lòng!'
                      : 'Hoàn thành thử thách!',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 4),

                ElevatedButton(
                  onPressed: _isLoading ? null : () => _onContinue(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3DD99F),
                    disabledBackgroundColor: const Color(0xFF3DD99F).withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0xFF3DD99F).withValues(alpha: 0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Tiếp tục',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14159 / 2, // down
              maxBlastForce: 5, // set a lower max blast force
              minBlastForce: 2, // set a lower min blast force
              emissionFrequency: 0.05,
              numberOfParticles: 50, // a lot of particles at once
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
