import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../services/database_helper.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  final List<Color> _cardColors = const [
    Color(0xFF7C5CFF),
    Color(0xFFFF5B7F),
    Color(0xFF368DFF),
    Color(0xFF3DD99F),
    Color(0xFFFFAF36),
  ];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getGameHistory();
    });
  }

  Future<void> _deleteSession(int sessionId) async {
    await DatabaseHelper.instance.deleteSession(sessionId);
    _reload();
  }

  Future<void> _clearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Xóa tất cả lịch sử?',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: const Text(
          'Hành động này không thể khôi phục. Tất cả lịch sử chơi sẽ bị xóa vĩnh viễn.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B72),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa tất cả',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.clearAllHistory();
      _reload();
    }
  }

  Future<void> _confirmDeleteSession(
      BuildContext context, int sessionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Xóa lịch sử này?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Lịch sử trận đấu này sẽ bị xóa vĩnh viễn.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B72),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await _deleteSession(sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch sử chơi',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded,
                color: Color(0xFFFF4B72)),
            tooltip: 'Xóa tất cả lịch sử',
            onPressed: () => _clearAll(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final historyData = snapshot.data ?? [];

          if (historyData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded,
                      size: 72,
                      color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có lịch sử chơi.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bắt đầu một trò chơi để lưu lịch sử!',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];

                // ── Data extraction ─────────────────────────────────────────
                final int sessionId = item['id'];
                final int playerCount = item['player_count'] ?? 0;
                final String groupName = item['group_name'] ?? 'Nhóm';
                final DateTime startedAt = DateTime.parse(item['started_at']);
                final String datetime =
                    DateFormat('dd/MM/yyyy • HH:mm').format(startedAt);

                // Points: show "-" when no meaningful score exists
                final int? rawPoints = item['total_points'] as int?;
                final int hasSessionScores = (item['has_session_scores'] as int?) ?? 0;
                final bool hasPoints = rawPoints != null && rawPoints != 0;
                final bool isVerified = hasSessionScores > 0; // came from session_scores
                final int points = rawPoints ?? 0;
                final String pointsLabel = hasPoints
                    ? (points > 0 ? '+$points' : '$points')
                    : '-';

                // Badge: "Bỏ dở" if ended_at is null
                final bool isCompleted = item['ended_at'] != null;

                final Color color = _cardColors[index % _cardColors.length];

                // ── Card ─────────────────────────────────────────────────────
                return Dismissible(
                  key: Key('session_$sessionId'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4B72),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                        SizedBox(height: 4),
                        Text('Xóa',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        title: const Text('Xóa lịch sử này?',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                        content: const Text(
                            'Lịch sử trận đấu này sẽ bị xóa vĩnh viễn.',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4B72),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Xóa',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => _deleteSession(sessionId),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryDetailScreen(
                            sessionId: sessionId,
                            sessionData: item,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: const Color(0xFFE8EBF3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Trophy icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.emoji_events_rounded,
                                color: color, size: 22),
                          ),
                          const SizedBox(width: 14),

                          // Text details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Group name + "Bỏ dở" badge
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        groupName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!isCompleted)
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF7E6),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: const Color(0xFFFFD54F),
                                              width: 1),
                                        ),
                                        child: const Text(
                                          'Bỏ dở',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFC69100),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 5),

                                // People count + time
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.people_rounded,
                                            size: 13,
                                            color: AppColors.textSecondary),
                                        const SizedBox(width: 3),
                                        Text(
                                          '$playerCount người',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.access_time_rounded,
                                            size: 13,
                                            color: AppColors.textSecondary),
                                        const SizedBox(width: 3),
                                        Text(
                                          datetime,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Points badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isVerified && hasPoints
                                  ? const Color(0xFFF0EDFF)
                                  : const Color(0xFFF4F6F9),
                              borderRadius: BorderRadius.circular(12),
                              border: isVerified && hasPoints
                                  ? Border.all(
                                      color: const Color(0xFF7C5CFF)
                                          .withValues(alpha: 0.3),
                                      width: 1)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: hasPoints
                                      ? AppColors.warning
                                      : AppColors.textSecondary
                                          .withValues(alpha: 0.5),
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$pointsLabel pt',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isVerified && hasPoints
                                        ? const Color(0xFF7C5CFF)
                                        : hasPoints
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Delete button
                          GestureDetector(
                            onTap: () =>
                                _confirmDeleteSession(context, sessionId),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFECEF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  color: Color(0xFFFF4B72), size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
