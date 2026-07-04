import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> historyData = [
      {
        'title': 'Chơi với 6 người',
        'datetime': '20/05/2024 • 21:30',
        'points': 120,
        'color': const Color(0xFF7C5CFF),
      },
      {
        'title': 'Chơi với 5 người',
        'datetime': '18/05/2024 • 20:15',
        'points': 90,
        'color': const Color(0xFFFF5B7F),
      },
      {
        'title': 'Chơi với 4 người',
        'datetime': '16/05/2024 • 19:45',
        'points': 70,
        'color': const Color(0xFF368DFF),
      },
      {
        'title': 'Chơi với 6 người',
        'datetime': '12/05/2024 • 21:10',
        'points': 110,
        'color': const Color(0xFF3DD99F),
      },
      {
        'title': 'Chơi với 5 người',
        'datetime': '10/05/2024 • 20:05',
        'points': 80,
        'color': const Color(0xFFFFAF36),
      },
      {
        'title': 'Chơi với 4 người',
        'datetime': '08/05/2024 • 19:30',
        'points': 60,
        'color': const Color(0xFF7C5CFF),
      },
      {
        'title': 'Chơi với 3 người',
        'datetime': '05/05/2024 • 18:50',
        'points': 50,
        'color': const Color(0xFFFF5B7F),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch sử chơi',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: historyData.length,
          itemBuilder: (context, index) {
            final item = historyData[index];
            final title = item['title'] as String;
            final datetime = item['datetime'] as String;
            final points = item['points'] as int;
            final color = item['color'] as Color;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Colored trophy icon container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Game metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          datetime,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Points received
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+$points',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
