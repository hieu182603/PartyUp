import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/secret_rule_provider.dart';
import '../../providers/player_provider.dart';
import 'secret_rule_playing_screen.dart';

class SecretRuleSetupScreen extends StatefulWidget {
  const SecretRuleSetupScreen({super.key});

  @override
  State<SecretRuleSetupScreen> createState() => _SecretRuleSetupScreenState();
}

class _SecretRuleSetupScreenState extends State<SecretRuleSetupScreen> {
  int _selectedRounds = 5;
  int _selectedTime = 3; // minutes
  String _selectedLevel = 'Nhẹ';
  bool _allowChangeRule = true;
  bool _allowCancelViolation = true;
  bool _soundEnabled = true;
  bool _stackingRules = true;

  @override
  void initState() {
    super.initState();
    // Pre-load rules
    Provider.of<SecretRuleProvider>(context, listen: false).loadRules();
  }

  void _startGame() {
    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    provider.configureGame(
      rounds: _selectedRounds,
      time: _selectedTime * 60,
      level: _selectedLevel,
      allowChange: _allowChangeRule,
      allowCancel: _allowCancelViolation,
      sound: _soundEnabled,
      stacking: _stackingRules,
    );
    provider.setPlayers(playerProvider.players);
    provider.reset();
    provider.startRound();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SecretRulePlayingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thiết lập luật bí mật'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tạo luật và bắt đầu trò chơi',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Rounds
            _buildSectionTitle('Số vòng chơi'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildOptionButton('1 vòng', _selectedRounds == 1, () => setState(() => _selectedRounds = 1)),
                const SizedBox(width: 8),
                _buildOptionButton('3 vòng', _selectedRounds == 3, () => setState(() => _selectedRounds = 3)),
                const SizedBox(width: 8),
                _buildOptionButton('5 vòng', _selectedRounds == 5, () => setState(() => _selectedRounds = 5)),
                const SizedBox(width: 8),
                _buildOptionButton('10 vòng', _selectedRounds == 10, () => setState(() => _selectedRounds = 10)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Time
            _buildSectionTitle('Thời gian mỗi người'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildOptionButton('1 phút', _selectedTime == 1, () => setState(() => _selectedTime = 1)),
                const SizedBox(width: 12),
                _buildOptionButton('2 phút', _selectedTime == 2, () => setState(() => _selectedTime = 2)),
                const SizedBox(width: 12),
                _buildOptionButton('3 phút', _selectedTime == 3, () => setState(() => _selectedTime = 3)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Level
            _buildSectionTitle('Mức độ'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildOptionButton('Nhẹ', _selectedLevel == 'Nhẹ', () => setState(() => _selectedLevel = 'Nhẹ'), color: const Color(0xFF3DD99F)),
                const SizedBox(width: 12),
                _buildOptionButton('Vui', _selectedLevel == 'Vui', () => setState(() => _selectedLevel = 'Vui'), color: const Color(0xFF4FAAFF)),
                const SizedBox(width: 12),
                _buildOptionButton('Lầy', _selectedLevel == 'Lầy', () => setState(() => _selectedLevel = 'Lầy'), color: const Color(0xFFFF5B7F)),
              ],
            ),
            const SizedBox(height: 32),
            
            // Options
            _buildSectionTitle('Tùy chọn khác'),
            const SizedBox(height: 12),
            _buildSwitchTile('Cho phép đổi luật', _allowChangeRule, (v) => setState(() => _allowChangeRule = v)),
            _buildSwitchTile('Cho phép hủy bắt lỗi', _allowCancelViolation, (v) => setState(() => _allowCancelViolation = v)),
            _buildSwitchTile('Âm thanh thông báo', _soundEnabled, (v) => setState(() => _soundEnabled = v)),
            _buildSwitchTile('Cộng dồn luật (Stacking)', _stackingRules, (v) => setState(() => _stackingRules = v)),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'Bắt đầu trò chơi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap, {Color? color}) {
    final activeColor = color ?? const Color(0xFF7C5CFF);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? activeColor : const Color(0xFFCBD5E1), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C5CFF),
            inactiveThumbColor: const Color(0xFF94A3B8),
            inactiveTrackColor: const Color(0xFFE2E8F0),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
