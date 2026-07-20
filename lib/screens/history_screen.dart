import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import '../services/database_helper.dart';
import '../providers/group_provider.dart';
import '../providers/player_provider.dart';
import '../providers/truth_or_dare_provider.dart';
import 'categories_screen.dart';
import 'history_detail_screen.dart';
import 'group_setup_screen.dart';
import 'secret_rule/secret_rule_setup_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  late TabController _tabController;
  String? _currentGameMode;

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _currentGameMode = null;
              break;
            case 1:
              _currentGameMode = 'truth_or_dare';
              break;
            case 2:
              _currentGameMode = 'secret_rule';
              break;
          }
        });
        _reload();
      }
    });
    _reload();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reload() {
    final future = DatabaseHelper.instance.getGameHistory(gameMode: _currentGameMode);
    setState(() {
      _historyFuture = future;
    });
    future.then((data) {
      if (mounted) {
        setState(() {
          _loaded = data;
        });
      }
    });
  }

  Future<void> _deleteSession(int sessionId) async {
    await DatabaseHelper.instance.deleteSession(sessionId);
    _reload();
    if (mounted) {
      AppNotification.success(context, 'Đã xóa lịch sử chơi thành công');
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
        AppNotification.success(context, 'Đã xóa tất cả lịch sử chơi thành công');
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
        AppNotification.success(context, 'Đã xóa $count lịch sử đã chọn thành công');
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
        'Lịch sử tham gia',
        style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: AppColors.textPrimary),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      bottom: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF7C5CFF),
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: const Color(0xFF7C5CFF),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(text: 'Tất cả'),
          Tab(text: 'Truth or Dare'),
          Tab(text: 'Secret Rule'),
        ],
      ),
      actions: [
        if (_loaded.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.checklist_rounded,
                color: AppColors.textPrimary),
            tooltip: 'Chọn nhiều',
            onPressed: () => setState(() => _selectionMode = true),
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
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C5CFF).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sports_esports_rounded,
                        size: 72, color: Color(0xFF7C5CFF)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chưa có lịch sử',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vào chơi game mới nhé!',
                    style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CFF),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
                      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                      playerProvider.resetScores();
                      groupProvider.clearCurrentGroup();

                      if (_currentGameMode == 'secret_rule') {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const GroupSetupScreen(
                            gameMode: 'secret_rule',
                            nextRoute: SecretRuleSetupScreen(),
                          ),
                        ));
                      } else {
                        final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
                        todProvider.reset();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                      }
                    },
                    child: const Text(
                      'Chơi ngay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _historyFuture;
            },
            color: const Color(0xFF7C5CFF),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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

                  final Color color = hasPoints 
                      ? (points >= 100 ? const Color(0xFF7C5CFF) : (points > 0 ? const Color(0xFF368DFF) : const Color(0xFF707E94)))
                      : const Color(0xFF707E94);
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
                      margin: const EdgeInsets.only(bottom: 16),
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
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Selection checkbox
                                if (_selectionMode) ...[
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
                                ],

                                // Trophy icon (Avatar Group)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                                  ),
                                  child: Icon(Icons.emoji_events_rounded,
                                      color: color, size: 26),
                                ),
                                const SizedBox(width: 14),

                                // Text details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Group name + game mode badge
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            groupName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: item['game_mode'] == 'secret_rule'
                                                  ? const Color(0xFFFFF0F0)
                                                  : const Color(0xFFF0EDFF),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item['game_mode'] == 'secret_rule' ? 'Secret Rule' : 'Truth or Dare',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: item['game_mode'] == 'secret_rule'
                                                    ? const Color(0xFFFF4B72)
                                                    : const Color(0xFF7C5CFF),
                                              ),
                                            ),
                                          ),
                                          if (!isCompleted)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF7E6),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Đang diễn ra',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFC69100),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // People count + time
                                      Row(
                                        children: [
                                          Icon(Icons.people_alt_rounded,
                                              size: 14,
                                              color: AppColors.textSecondary.withValues(alpha: 0.6)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$playerCount người',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.access_time_filled_rounded,
                                              size: 14,
                                              color: AppColors.textSecondary.withValues(alpha: 0.4)),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              datetime,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Points badge (Gamified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: (hasPoints && points >= 100) 
                                        ? const LinearGradient(
                                            colors: [Color(0xFF7C5CFF), Color(0xFFFF5B7F)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: (hasPoints && points >= 100)
                                        ? null
                                        : (hasPoints && points > 0 ? const Color(0xFFEBF3FF) : const Color(0xFFF4F6F9)),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: (hasPoints && points >= 100) ? [
                                      BoxShadow(
                                        color: const Color(0xFF7C5CFF).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ] : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: (hasPoints && points >= 100)
                                            ? Colors.white
                                            : (hasPoints ? const Color(0xFF368DFF) : AppColors.textSecondary.withValues(alpha: 0.5)),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$pointsLabel pt',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: (hasPoints && points >= 100)
                                              ? Colors.white
                                              : (hasPoints
                                                  ? const Color(0xFF368DFF)
                                                  : AppColors.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
