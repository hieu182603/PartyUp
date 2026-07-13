import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../models/player.dart';
import '../../providers/player_provider.dart';
import '../../providers/secret_rule_provider.dart';
import '../../services/database_helper.dart';

class ViolatorSelectionScreen extends StatefulWidget {
  const ViolatorSelectionScreen({super.key});

  @override
  State<ViolatorSelectionScreen> createState() => _ViolatorSelectionScreenState();
}

class _ViolatorSelectionScreenState extends State<ViolatorSelectionScreen> {
  final Set<int> _selectedPlayerIds = {};
  final TextEditingController _reasonController = TextEditingController();

  void _confirm() {
    if (_selectedPlayerIds.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = Provider.of<SecretRuleProvider>(context, listen: false);
    final players = Provider.of<PlayerProvider>(context, listen: false).players;
    final reason = _reasonController.text.trim();

    for (final id in _selectedPlayerIds) {
      provider.addViolation(id);
      final player = players.cast<Player?>().firstWhere(
        (p) => p?.id == id,
        orElse: () => null,
      );
      if (player != null && provider.currentSessionId != null) {
        DatabaseHelper.instance.insertSessionTurn(
          provider.currentSessionId!,
          provider.currentRound,
          player.name,
          reason.isNotEmpty ? reason : 'Nội quy: ${provider.activeRules.isNotEmpty ? provider.activeRules.last.content : ''}',
          -1,
        );
      }
    }
    
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final players = playerProvider.players;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EBF3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Ai vi phạm luật?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance for back button
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Chọn người đã vi phạm',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final isSelected = _selectedPlayerIds.contains(player.id);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                  leading: RandomAvatar(
                    player.name,
                    trBackground: false,
                    height: 40,
                    width: 40,
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF7C5CFF) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF7C5CFF) : const Color(0xFFD0D5DD),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedPlayerIds.remove(player.id);
                      } else {
                        _selectedPlayerIds.add(player.id!);
                      }
                    });
                  },
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: 'Lý do bắt lỗi (tùy chọn)',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedPlayerIds.isNotEmpty ? _confirm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C5CFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
