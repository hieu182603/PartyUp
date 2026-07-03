import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/group_provider.dart';
import '../providers/player_provider.dart';
import 'game_mode_screen.dart';

class GroupSetupScreen extends StatefulWidget {
  const GroupSetupScreen({super.key});

  @override
  State<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends State<GroupSetupScreen> {
  final _groupNameController = TextEditingController();
  final _playerNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    _playerNameController.dispose();
    super.dispose();
  }

  void _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhóm!')),
      );
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.createGroup(_groupNameController.text.trim());
    
    if (mounted) {
      final currentGroup = groupProvider.currentGroup;
      if (currentGroup != null) {
        Provider.of<PlayerProvider>(context, listen: false).loadPlayersForGroup(currentGroup.id!);
      }
    }
  }

  void _addPlayer() {
    if (_playerNameController.text.trim().isEmpty) return;

    final currentGroup = Provider.of<GroupProvider>(context, listen: false).currentGroup;
    if (currentGroup == null) return;

    Provider.of<PlayerProvider>(context, listen: false)
        .addPlayer(currentGroup.id!, _playerNameController.text.trim());
    
    _playerNameController.clear();
  }

  void _startGame() {
    final players = Provider.of<PlayerProvider>(context, listen: false).players;
    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần ít nhất 2 người chơi để bắt đầu!')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameModeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết lập nhóm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (groupProvider.currentGroup == null) ...[
              const Text(
                'Tạo nhóm mới',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên nhóm...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createGroup,
                child: const Text('Tạo Nhóm'),
              ),
            ] else ...[
              Text(
                'Nhóm: ${groupProvider.currentGroup!.name}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _playerNameController,
                      decoration: InputDecoration(
                        hintText: 'Tên người chơi...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => _addPlayer(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: _addPlayer,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: playerProvider.players.length,
                  itemBuilder: (context, index) {
                    final player = playerProvider.players[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.warning,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => playerProvider.removePlayer(player.id!),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('Bắt đầu chơi', style: TextStyle(fontSize: 20)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
