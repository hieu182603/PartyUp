import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/player_provider.dart';
import '../../core/theme/app_colors.dart';
import 'result_screen.dart';

class ContentPlayingScreen extends StatefulWidget {
  const ContentPlayingScreen({super.key});

  @override
  State<ContentPlayingScreen> createState() => _ContentPlayingScreenState();
}

class _ContentPlayingScreenState extends State<ContentPlayingScreen> {
  int _timeLeft = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
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
        // Hết giờ
        _handleResult(false, isTimeout: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleResult(bool success, {bool isTimeout = false}) async {
    _timer?.cancel();
    
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final player = todProvider.currentPlayer;
    final content = todProvider.currentContent;

    if (player != null && content != null) {
      if (success) {
        // Thưởng điểm
        int points = content.type == 'dare' ? 10 : 5;
        await playerProvider.updatePlayerScore(player.id!, points);
      } else {
        // Phạt
        await playerProvider.updatePlayerPenalty(player.id!, 1);
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);
    final content = todProvider.currentContent;

    if (content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isTruth = content.type == 'truth';
    final bgColor = isTruth ? AppColors.truthColor.withOpacity(0.1) : AppColors.dareColor.withOpacity(0.1);
    final primaryColor = isTruth ? AppColors.truthColor : AppColors.dareColor;
    final tagText = isTruth ? 'THẬT' : 'THÁCH';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tagText,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const Spacer(),
            Text(
              content.content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.secondary, size: 30),
                const SizedBox(width: 8),
                Text(
                  '00:${_timeLeft.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                onPressed: () => _handleResult(true),
                child: const Text('Hoàn thành'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.textSecondary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  // Đổi nội dung (không tính điểm, quay về chọn Thật/Thách)
                  Navigator.pop(context);
                },
                child: const Text('Đổi nội dung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: () => _handleResult(false),
                child: const Text('Bỏ cuộc'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
