import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../services/database_helper.dart';

class HistoryDetailScreen extends StatelessWidget {
  final int sessionId;
  final Map<String, dynamic> sessionData;

  const HistoryDetailScreen({
    super.key,
    required this.sessionId,
    required this.sessionData,
  });

  @override
  Widget build(BuildContext context) {
    final startedAt = DateTime.parse(sessionData['started_at']);
    final endedAt = sessionData['ended_at'] != null ? DateTime.parse(sessionData['ended_at']) : null;
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
        future: Future.wait([
          DatabaseHelper.instance.getSessionScores(sessionId),
          DatabaseHelper.instance.getSessionTurns(sessionId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final scores = (snapshot.data?[0] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final turns = (snapshot.data?[1] as List?)?.cast<Map<String, dynamic>>() ?? [];
          if (scores.isEmpty) {
            return const Center(
              child: Text(
                'Không có dữ liệu xếp hạng cho ván này.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
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
                    const Text('Thông tin chung', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nhóm chơi', sessionData['group_name'] ?? 'Không rõ'),
                    _buildInfoRow('Thời gian bắt đầu', DateFormat('dd/MM/yyyy • HH:mm').format(startedAt)),
                    if (endedAt != null)
                      _buildInfoRow('Thời gian kết thúc', DateFormat('dd/MM/yyyy • HH:mm').format(endedAt)),
                    if (endedAt != null)
                      _buildInfoRow('Tổng thời gian', '${duration.inMinutes} phút'),
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
                  return _buildLeaderboardItem(player, index + 1);
                }),
                
              const SizedBox(height: 32),
              const Text('Lịch sử theo lượt', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              if (turns.isEmpty)
                const Text('Chưa có dữ liệu lượt chơi', style: TextStyle(color: AppColors.textSecondary))
              else
                ...List.generate(turns.length, (index) {
                  return _buildTurnItem(turns[index]);
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> player, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rank == 1 ? const Color(0xFFFFB300) : const Color(0xFFE8EBF3), width: rank == 1 ? 2 : 1),
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: rank == 1 ? const Color(0xFFFFB300) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          RandomAvatar(player['player_name'], height: 40, width: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player['player_name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${player['score']} điểm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: rank == 1 ? const Color(0xFFFFB300) : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnItem(Map<String, dynamic> turn) {
    final int pointsChange = turn['points_change'] ?? 0;
    final bool isPositive = pointsChange >= 0;
    final String contentStr = turn['content'] ?? '';
    // Optional: Truncate content if too long
    final String shortContent = contentStr.length > 50 ? '${contentStr.substring(0, 50)}...' : contentStr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Vòng ${turn['round_number']}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                        fontSize: 14,
                        color: isPositive ? const Color(0xFF7C5CFF) : const Color(0xFFFF4B72),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  shortContent,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
