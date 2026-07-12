import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import '../services/database_helper.dart';
import '../providers/group_provider.dart';
import '../providers/player_provider.dart';
import '../providers/truth_or_dare_provider.dart';
import '../models/player_group.dart';
import '../models/player.dart';
import 'truth_or_dare/random_player_screen.dart';

class HistoryDetailScreen extends StatefulWidget {
  final int sessionId;
  final Map<String, dynamic> sessionData;

  const HistoryDetailScreen({
    super.key,
    required this.sessionId,
    required this.sessionData,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late Future<List<dynamic>> _dataFuture;
  String? _selectedPlayerName;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<dynamic>> _loadData() async {
    final turns = await DatabaseHelper.instance.getSessionTurns(widget.sessionId);
    List<Map<String, dynamic>> scores;
    
    if (widget.sessionData['ended_at'] != null) {
      scores = await DatabaseHelper.instance.getSessionScores(widget.sessionId);
    } else {
      final groupId = widget.sessionData['group_id'] as int;
      final players = await DatabaseHelper.instance.getPlayersByGroup(groupId);
      
      final Map<String, int> playerScores = {};
      for (var player in players) {
        playerScores[player.name] = 0;
      }
      for (var turn in turns) {
        final name = turn['player_name'] as String;
        final pts = turn['points_change'] as int;
        playerScores[name] = (playerScores[name] ?? 0) + pts;
      }

      scores = players.map((p) => {
        'player_name': p.name,
        'player_avatar': p.avatar ?? '',
        'score': playerScores[p.name] ?? 0,
      }).toList();

      scores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    }
    return [scores, turns];
  }

  Future<void> _continueGame() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final tdProvider = Provider.of<TruthOrDareProvider>(context, listen: false);

    final groupId = widget.sessionData['group_id'] as int;
    final String groupName = widget.sessionData['group_name'] ?? 'Nhóm';
    final String gameMode = widget.sessionData['game_mode'] ?? 'truth_or_dare';

    if (gameMode != 'truth_or_dare') {
      AppNotification.error(context, 'Chế độ này chưa hỗ trợ tiếp tục chơi');
      return;
    }

    final existingGroup = groupProvider.groups.cast<PlayerGroup?>().firstWhere(
      (g) => g?.id == groupId,
      orElse: () => null,
    );
    
    if (existingGroup != null) {
      groupProvider.setCurrentGroup(existingGroup);
    } else {
      groupProvider.setCurrentGroup(PlayerGroup(id: groupId, name: groupName));
    }

    await playerProvider.loadPlayersForGroup(groupId);

    final turns = (await _dataFuture)[1] as List<Map<String, dynamic>>;
    int currentRound = 1;
    Set<int> playedIds = {};

    // Calculate scores and penalties from turns to restore player states accurately
    final Map<String, int> sessionScores = {};
    final Map<String, int> sessionPenalties = {};

    for (var turn in turns) {
      final name = turn['player_name'] as String;
      final pts = turn['points_change'] as int;
      sessionScores[name] = (sessionScores[name] ?? 0) + pts;
      if (pts < 0) {
        sessionPenalties[name] = (sessionPenalties[name] ?? 0) + pts.abs();
      }
    }

    await playerProvider.restoreSessionScoresAndPenalties(sessionScores, sessionPenalties);

    if (turns.isNotEmpty) {
      for (var turn in turns) {
        final roundNum = turn['round_number'] as int;
        if (roundNum > currentRound) {
          currentRound = roundNum;
        }
      }

      final turnsInCurrentRound = turns.where((t) => t['round_number'] == currentRound).toList();
      
      for (var turn in turnsInCurrentRound) {
        final playerName = turn['player_name'] as String;
        final player = playerProvider.players.cast<dynamic?>().firstWhere(
          (p) => p?.name == playerName,
          orElse: () => null,
        );
        if (player != null && player.id != null) {
          playedIds.add(player.id!);
        }
      }

      if (playedIds.length >= playerProvider.players.length && playerProvider.players.isNotEmpty) {
        currentRound++;
        playedIds.clear();
      }
    }

    tdProvider.restoreSession(widget.sessionId, currentRound, playedIds);

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RandomPlayerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startedAt = DateTime.parse(widget.sessionData['started_at']);
    final endedAt = widget.sessionData['ended_at'] != null ? DateTime.parse(widget.sessionData['ended_at']) : null;
    final duration = endedAt != null ? endedAt.difference(startedAt) : Duration.zero;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Chi tiết ván chơi',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final scores = (snapshot.data?[0] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final turns = (snapshot.data?[1] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final filteredTurns = _selectedPlayerName == null 
              ? turns 
              : turns.where((t) => t['player_name'] == _selectedPlayerName).toList();
              
          // Calculate ranks
          List<int> ranks = [];
          int currentRank = 1;
          int? lastScore;
          for (int i = 0; i < scores.length; i++) {
            final score = scores[i]['score'];
            if (lastScore == null || score < lastScore) {
              currentRank = i + 1;
              lastScore = score;
            }
            ranks.add(currentRank);
          }

          if (scores.isEmpty) {
            return const Center(
              child: Text(
                'Không có dữ liệu xếp hạng cho ván này.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // General Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng quan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.groups_rounded, 'Nhóm chơi', widget.sessionData['group_name'] ?? 'Không rõ'),
                          _buildInfoRow(Icons.play_circle_outline_rounded, 'Thời gian bắt đầu', DateFormat('dd/MM/yyyy • HH:mm').format(startedAt)),
                          if (endedAt != null)
                            _buildInfoRow(Icons.check_circle_outline_rounded, 'Thời gian kết thúc', DateFormat('dd/MM/yyyy • HH:mm').format(endedAt)),
                          if (endedAt != null)
                            _buildInfoRow(Icons.timer_outlined, 'Tổng thời gian', '${duration.inMinutes} phút'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Bảng xếp hạng ván chơi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    if (scores.isEmpty)
                      const Text('Chưa có dữ liệu xếp hạng', style: TextStyle(color: AppColors.textSecondary))
                    else
                      ...List.generate(scores.length, (index) {
                        final player = scores[index];
                        final rank = ranks[index];
                        final isTie = ranks.where((r) => r == rank).length > 1;
                        return _buildLeaderboardItem(player, rank, isTie);
                      }),
                      
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lịch sử theo lượt', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
                        if (_selectedPlayerName != null)
                          ActionChip(
                            label: const Text('Tất cả', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF7C5CFF), fontSize: 12)),
                            avatar: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF7C5CFF)),
                            backgroundColor: const Color(0xFFF0EDFF),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(() => _selectedPlayerName = null),
                          ),
                      ],
                    ),
                  ]),
                ),
              ),
              
              if (filteredTurns.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      _selectedPlayerName == null ? 'Chưa có dữ liệu lượt chơi' : 'Người chơi này chưa có lượt nào', 
                      style: const TextStyle(color: AppColors.textSecondary)
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildTurnItem(filteredTurns[index], index == filteredTurns.length - 1);
                      },
                      childCount: filteredTurns.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: endedAt == null ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C5CFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              shadowColor: const Color(0xFF7C5CFF).withOpacity(0.5),
            ),
            onPressed: _continueGame,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Tiếp tục chơi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> player, int rank, bool isTie) {
    final String playerName = player['player_name'];
    final bool isSelected = _selectedPlayerName == playerName;
    final bool hasSelection = _selectedPlayerName != null;
    final double opacity = hasSelection && !isSelected ? 0.4 : 1.0;

    Color borderColor = const Color(0xFFE8EBF3);
    Color backgroundColor = Colors.white;
    Color rankColor = AppColors.textSecondary;
    double borderWidth = 1.0;
    Widget? trailingIcon;
    double avatarSize = 40.0;
    FontWeight textWeight = FontWeight.w800;

    if (rank == 1) {
      borderColor = const Color(0xFFFFB300);
      backgroundColor = const Color(0xFFFFFDF5);
      rankColor = const Color(0xFFFFB300);
      borderWidth = 2.0;
      trailingIcon = const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300), size: 24);
      avatarSize = 48.0;
      textWeight = FontWeight.w900;
    } else if (rank == 2) {
      borderColor = const Color(0xFFFF9800);
      backgroundColor = const Color(0xFFFFF8F0);
      rankColor = const Color(0xFFFF9800);
      borderWidth = 1.5;
    } else if (rank == 3) {
      borderColor = const Color(0xFF9C27B0);
      backgroundColor = const Color(0xFFFDF5FF);
      rankColor = const Color(0xFF9C27B0);
      borderWidth = 1.5;
    }

    if (isSelected) {
      backgroundColor = const Color(0xFFF0EDFF);
      borderColor = const Color(0xFF7C5CFF);
      borderWidth = 2.0;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlayerName = isSelected ? null : playerName;
        });
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: rank == 1 ? 16 : 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: rank == 1 ? [
              BoxShadow(color: const Color(0xFFFFB300).withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Row(
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: rank == 1 ? 20 : 16,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? const Color(0xFF7C5CFF) : rankColor,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: rank <= 3 ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: rankColor.withOpacity(0.3), blurRadius: 8)
                  ]
                ) : null,
                child: RandomAvatar(playerName, height: avatarSize, width: avatarSize)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  playerName,
                  style: TextStyle(
                    fontSize: rank == 1 ? 18 : 16,
                    fontWeight: textWeight,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isTie && rank <= 3) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: rankColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('Hòa', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: rankColor)),
                ),
                const SizedBox(width: 8),
              ],
              if (trailingIcon != null) ...[
                trailingIcon,
                const SizedBox(width: 8),
              ],
              Text(
                '${player['score']} điểm',
                style: TextStyle(
                  fontSize: rank == 1 ? 18 : 16,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? const Color(0xFF7C5CFF) : rankColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurnItem(Map<String, dynamic> turn, bool isLast) {
    final int pointsChange = turn['points_change'] ?? 0;
    final bool isPositive = pointsChange >= 0;
    final String contentStr = turn['content'] ?? '';
    final String shortContent = contentStr.length > 50 ? '${contentStr.substring(0, 50)}...' : contentStr;

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 15,
            top: 36,
            bottom: 0,
            child: Container(width: 2, color: const Color(0xFFE8EBF3)),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 16, top: 4),
              decoration: BoxDecoration(
                color: isPositive ? const Color(0xFFE8F9F3) : const Color(0xFFFFECEF),
                shape: BoxShape.circle,
              ),
              child: Icon(isPositive ? Icons.check_rounded : Icons.close_rounded, size: 18, color: isPositive ? const Color(0xFF3DD99F) : const Color(0xFFFF4B72)),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Vòng ${turn['round_number']}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            turn['player_name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          isPositive ? '+$pointsChange đ' : '$pointsChange đ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isPositive ? const Color(0xFF3DD99F) : const Color(0xFFFF4B72),
                          ),
                        ),
                      ],
                    ),
                    if (shortContent.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        shortContent,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
