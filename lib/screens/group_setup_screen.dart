import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import '../providers/group_provider.dart';
import '../providers/player_provider.dart';
import '../models/game_session.dart';
import '../services/database_helper.dart';
import 'truth_or_dare/random_player_screen.dart';
import '../providers/truth_or_dare_provider.dart';

class GroupSetupScreen extends StatefulWidget {
  const GroupSetupScreen({super.key});

  @override
  State<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends State<GroupSetupScreen> {
  final _playerNameController = TextEditingController();
  final _groupNameController = TextEditingController();
  
  final List<String> _funnyNames = [
    "Biệt đội quậy phá",
    "Hội ế",
    "Binh đoàn tấu hài",
    "Những kẻ sống ảo",
    "Hội sợ vợ",
    "Ăn tàn phá hại",
    "Đội siêu lầy"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndInitGroup();
    });
  }

  Future<void> _checkAndInitGroup() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    if (groupProvider.currentGroup == null) {
      final randomName = _funnyNames[Random().nextInt(_funnyNames.length)];
      await groupProvider.createGroup(randomName);
      if (mounted && groupProvider.currentGroup != null) {
        _groupNameController.text = groupProvider.currentGroup!.name;
        Provider.of<PlayerProvider>(context, listen: false)
            .loadPlayersForGroup(groupProvider.currentGroup!.id!);
      }
    } else {
      if (mounted) {
        _groupNameController.text = groupProvider.currentGroup!.name;
        Provider.of<PlayerProvider>(context, listen: false)
            .loadPlayersForGroup(groupProvider.currentGroup!.id!);
      }
    }
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  void _showAddPlayerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EBF3),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Thêm người chơi mới',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _playerNameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên người chơi...',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onSubmitted: (_) => _addPlayerAndClose(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addPlayerAndClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Thêm vào nhóm'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSelectGroupBottomSheet() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.loadGroups();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<GroupProvider>(
          builder: (context, provider, _) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(28.0),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8EBF3),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chọn đội chơi cũ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: provider.groups.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có đội chơi nào',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: provider.groups.length,
                            itemBuilder: (context, index) {
                              final group = provider.groups[index];
                              final isCurrent = group.id == provider.currentGroup?.id;
                              
                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFE8F9F3),
                                  child: Icon(Icons.group_rounded, color: Color(0xFF3DD99F)),
                                ),
                                title: Text(
                                  group.name,
                                  style: TextStyle(
                                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                                    color: isCurrent ? const Color(0xFF7C5CFF) : AppColors.textPrimary,
                                  ),
                                ),
                                trailing: isCurrent 
                                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF7C5CFF))
                                    : null,
                                onTap: () {
                                  provider.setCurrentGroup(group);
                                  _groupNameController.text = group.name;
                                  Provider.of<PlayerProvider>(context, listen: false)
                                      .loadPlayersForGroup(group.id!);
                                  Navigator.pop(context);
                                  AppNotification.success(context, 'Đã chọn đội: ${group.name}');
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addPlayerAndClose() {
    final name = _playerNameController.text.trim();
    if (name.isEmpty) {
      Navigator.pop(context);
      AppNotification.warning(context, 'Vui lòng nhập tên người chơi!');
      return;
    }

    if (name.length > 20) {
      AppNotification.warning(context, 'Tên không được quá 20 ký tự!');
      return;
    }

    final currentGroup = Provider.of<GroupProvider>(context, listen: false).currentGroup;
    if (currentGroup == null) return;

    final players = Provider.of<PlayerProvider>(context, listen: false).players;
    final isDuplicate = players.any(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
    if (isDuplicate) {
      AppNotification.warning(context, 'Tên "$name" đã tồn tại trong nhóm!');
      return;
    }

    Provider.of<PlayerProvider>(context, listen: false)
        .addPlayer(currentGroup.id!, name);

    _playerNameController.clear();
    Navigator.pop(context);
    AppNotification.success(context, 'Đã thêm $name vào nhóm! 🎉');
  }

  void _startGame() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final players = playerProvider.players;
    if (players.length < 2) {
      AppNotification.warning(context, 'Cần ít nhất 2 người chơi để bắt đầu!');
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final tdProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    
    // Reset player scores to 0 before starting a new session
    // so endSession saves only per-session scores (not cumulative)
    await playerProvider.resetScores();

    if (groupProvider.currentGroup != null) {
      final session = GameSession(groupId: groupProvider.currentGroup!.id!, gameMode: 'truth_or_dare');
      final sessionId = await DatabaseHelper.instance.createGameSession(session);
      tdProvider.currentSessionId = sessionId;
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RandomPlayerScreen()),
      );
    }
  }

  // Get a colored border for avatar decoration
  Color _getAvatarBorderColor(int index) {
    const colors = [
      Color(0xFF3DD99F), // Green
      Color(0xFFFF5B7F), // Pink/Red
      Color(0xFF4FAAFF), // Blue
      Color(0xFFFFAF36), // Orange
      Color(0xFF9D5CFF), // Purple
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final players = playerProvider.players;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Thêm người chơi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Ít nhất 2 người',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 24, color: AppColors.textPrimary),
            onPressed: _showSelectGroupBottomSheet,
            tooltip: 'Chọn đội cũ',
          ),
        ],
        centerTitle: true,
      ),
      body: groupProvider.currentGroup == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Group Name Editor
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _groupNameController,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Tên nhóm...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                        icon: const Icon(Icons.edit_rounded, color: Color(0xFF7C5CFF), size: 20),
                      ),
                      onChanged: (val) {
                        if (val.trim().isNotEmpty && groupProvider.currentGroup != null) {
                          groupProvider.updateGroupName(groupProvider.currentGroup!.id!, val.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: players.length + 1,
                      itemBuilder: (context, index) {
                        if (index == players.length) {
                          // The special "+" Add Player card
                          return GestureDetector(
                            onTap: _showAddPlayerBottomSheet,
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFD0D5DD),
                                        width: 2,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.add_rounded,
                                        size: 32,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Thêm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final player = players[index];
                        final borderColor = _getAvatarBorderColor(index);

                        return Column(
                          children: [
                            Stack(
                              children: [
                                // Avatar circle container
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: borderColor, width: 2),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: RandomAvatar(
                                        player.name, 
                                        trBackground: false, 
                                        height: 48, 
                                        width: 48
                                      ),
                                    ),
                                  ),
                                ),
                                // Delete button "x"
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => playerProvider.removePlayer(player.id!),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.12),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(color: const Color(0xFFE8EBF3), width: 1),
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: Color(0xFF667085),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              player.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rounded Pink Play Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: AppColors.secondary.withOpacity(0.35),
                        elevation: 8,
                      ),
                      child: Text(
                        'Bắt đầu (${players.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
