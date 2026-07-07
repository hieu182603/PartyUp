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

  // Multi-select state
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};
  List<Map<String, dynamic>> _loaded = const [];

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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa lịch sử chơi thành công'),
          backgroundColor: Color(0xFF3DD99F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa tất cả lịch sử chơi thành công'),
            backgroundColor: Color(0xFF3DD99F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _enterSelectionMode(int sessionId) {
    setState(() {
      _selectionMode = true;
      _selectedIds
        ..clear()
        ..add(sessionId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelected(int sessionId) {
    setState(() {
      if (!_selectedIds.remove(sessionId)) {
        _selectedIds.add(sessionId);
      }
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  void _selectAll(List<Map<String, dynamic>> historyData) {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(historyData.map((e) => e['id'] as int));
    });
  }

  Future<void> _deleteSelected(BuildContext context) async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Xóa $count lịch sử đã chọn?',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: const Text(
          'Hành động này không thể khôi phục. Các lịch sử đã chọn sẽ bị xóa vĩnh viễn.',
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteSessions(_selectedIds.toList());
      _exitSelectionMode();
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa $count lịch sử đã chọn thành công'),
            backgroundColor: const Color(0xFF3DD99F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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

  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
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
        if (_loaded.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.checklist_rounded,
                color: AppColors.textPrimary),
            tooltip: 'Chọn nhiều',
            onPressed: () => setState(() => _selectionMode = true),
          ),
        IconButton(
          icon:
              const Icon(Icons.delete_sweep_rounded, color: Color(0xFFFF4B72)),
          tooltip: 'Xóa tất cả lịch sử',
          onPressed: () => _clearAll(context),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    final bool allSelected =
        _loaded.isNotEmpty && _selectedIds.length == _loaded.length;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        tooltip: 'Hủy',
        onPressed: _exitSelectionMode,
      ),
      title: Text(
        'Đã chọn ${_selectedIds.length}',
        style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.textPrimary),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            allSelected
                ? Icons.deselect_rounded
                : Icons.select_all_rounded,
            color: AppColors.textPrimary,
          ),
          tooltip: allSelected ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
          onPressed: () => allSelected
              ? setState(_selectedIds.clear)
              : _selectAll(_loaded),
        ),
        IconButton(
          icon: const Icon(Icons.delete_rounded, color: Color(0xFFFF4B72)),
          tooltip: 'Xóa mục đã chọn',
          onPressed:
              _selectedIds.isEmpty ? null : () => _deleteSelected(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _selectionMode ? _buildSelectionAppBar() : _buildDefaultAppBar(),
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
          _loaded = historyData;

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
                final bool selected = _selectedIds.contains(sessionId);

                // ── Card ─────────────────────────────────────────────────────
                return Dismissible(
                  key: Key('session_$sessionId'),
                  direction: _selectionMode
                      ? DismissDirection.none
                      : DismissDirection.endToStart,
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
                      if (_selectionMode) {
                        _toggleSelected(sessionId);
                        return;
                      }
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
                    onLongPress: _selectionMode
                        ? null
                        : () => _enterSelectionMode(sessionId),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFF0EDFF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: selected
                                ? const Color(0xFF7C5CFF)
                                : const Color(0xFFE8EBF3),
                            width: selected ? 2 : 1.5),
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
                          // Selection checkbox
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: selected,
                              activeColor: const Color(0xFF7C5CFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (_) => _toggleSelected(sessionId),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Trophy icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.emoji_events_rounded,
                                color: color, size: 20),
                          ),
                          const SizedBox(width: 10),

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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.access_time_rounded,
                                            size: 13,
                                            color: AppColors.textSecondary),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            datetime,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Points badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
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

                          // Delete button (hidden in selection mode)
                          if (!_selectionMode) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () =>
                                  _confirmDeleteSession(context, sessionId),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFECEF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_rounded,
                                    color: Color(0xFFFF4B72), size: 16),
                              ),
                            ),
                          ],
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
