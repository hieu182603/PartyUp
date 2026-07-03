import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../core/theme/app_colors.dart';
import 'truth_or_dare_choice_screen.dart';

class RandomPlayerScreen extends StatefulWidget {
  const RandomPlayerScreen({super.key});

  @override
  State<RandomPlayerScreen> createState() => _RandomPlayerScreenState();
}

class _RandomPlayerScreenState extends State<RandomPlayerScreen> with TickerProviderStateMixin {
  int _countdown = 3;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _startCountdown();
  }

  void _startCountdown() async {
    while (_countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
      }
    }

    if (mounted) {
      final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
      final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
      
      todProvider.selectRandomPlayer(playerProvider.players);
      
      // Navigate to choice screen
      Future.delayed(const Duration(seconds: 2), () {
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);
    final currentPlayer = todProvider.currentPlayer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ai sẽ là người tiếp theo?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Should go back to Game Mode
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_countdown > 0) ...[
              ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.2).animate(_pulseController),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 10),
                  ),
                  child: Center(
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              )
            ] else if (currentPlayer != null) ...[
              const CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.warning,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                currentPlayer.name,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Đến lượt bạn!',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              const CircularProgressIndicator(),
            ]
          ],
        ),
      ),
    );
  }
}
