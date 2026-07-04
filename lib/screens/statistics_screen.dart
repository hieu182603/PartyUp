import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _activeTab = 0; // 0: Tổng quan, 1: Theo chủ đề, 2: Theo thời gian

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Thống kê',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            // Header tabs
            Row(
              children: [
                _buildHeaderTab('Tổng quan', 0),
                const SizedBox(width: 8),
                _buildHeaderTab('Theo chủ đề', 1),
                const SizedBox(width: 8),
                _buildHeaderTab('Theo thời gian', 2),
              ],
            ),
            const SizedBox(height: 24),
            // Statistics details scrollable area
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (_activeTab == 0) ...[
                    // Row of two key stat cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.emoji_events_rounded,
                            iconColor: const Color(0xFFFFAF36),
                            title: 'Tổng số ván chơi',
                            valueText: '24',
                            unitText: ' ván',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFF7C5CFF),
                            title: 'Điểm cao nhất',
                            valueText: '520',
                            unitText: ' điểm',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Chart container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Điểm trung bình mỗi ván',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '320 điểm',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Custom Painted Graph
                          SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: LineChartPainter(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // X-Axis labels
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('08/05', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              Text('13/05', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              Text('20/05', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              Text('27/05', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              Text('03/06', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick stats list
                    const Text(
                      'Thống kê nhanh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickStatRow(
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF3DD99F),
                      title: 'Câu trả lời đúng',
                      value: '156',
                      percentText: ' (78%)',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickStatRow(
                      icon: Icons.cancel_rounded,
                      iconColor: const Color(0xFFFF5B7F),
                      title: 'Bỏ qua',
                      value: '44',
                      percentText: ' (22%)',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickStatRow(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFFFAF36),
                      title: 'Tổng điểm',
                      value: '7.680',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickStatRow(
                      icon: Icons.access_time_filled_rounded,
                      iconColor: const Color(0xFF368DFF),
                      title: 'Thời gian chơi',
                      value: '5h 30m',
                    ),
                  ] else if (_activeTab == 1) ...[
                    // Theme statistics
                    const Text(
                      'Hoàn thành theo chủ đề',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildThemeProgressCard('Tình yêu', 42, 120, const Color(0xFFFF5B7F)),
                    const SizedBox(height: 12),
                    _buildThemeProgressCard('Tình bạn', 35, 100, const Color(0xFF368DFF)),
                    const SizedBox(height: 12),
                    _buildThemeProgressCard('Lifestyle', 28, 120, const Color(0xFFFFAF36)),
                    const SizedBox(height: 12),
                    _buildThemeProgressCard('Hài hước', 20, 80, const Color(0xFFFFD54F)),
                    const SizedBox(height: 12),
                    _buildThemeProgressCard('Du lịch', 15, 90, const Color(0xFF3DD99F)),
                  ] else ...[
                    // Time statistics
                    const Text(
                      'Thống kê thời gian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickStatRow(
                      icon: Icons.hourglass_empty_rounded,
                      iconColor: const Color(0xFF7C5CFF),
                      title: 'Tổng thời gian chơi',
                      value: '5h 30m',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickStatRow(
                      icon: Icons.calendar_today_rounded,
                      iconColor: const Color(0xFFFF5B7F),
                      title: 'Số ngày chơi liên tiếp',
                      value: '3 ngày',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickStatRow(
                      icon: Icons.timer_rounded,
                      iconColor: const Color(0xFF3DD99F),
                      title: 'Thời gian trung bình mỗi ván',
                      value: '12 phút',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickStatRow(
                      icon: Icons.query_builder_rounded,
                      iconColor: const Color(0xFF368DFF),
                      title: 'Trận đấu dài nhất',
                      value: '45 phút (6 người)',
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Export button
                  OutlinedButton(
                    onPressed: () {
                      AppNotification.info(context, 'Chức năng xuất báo cáo sớm ra mắt! 📊');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7C5CFF), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded, color: Color(0xFF7C5CFF), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Xuất báo cáo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7C5CFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTab(String title, int tabIndex) {
    final isSelected = _activeTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = tabIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7C5CFF) : const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String valueText,
    required String unitText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                unitText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeProgressCard(String title, int completed, int total, Color color) {
    final percent = completed / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$completed/$total câu',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? percentText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              if (percentText != null)
                Text(
                  percentText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a high-fidelity line chart
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Points on graph
    final List<Offset> points = [
      Offset(0, h * 0.7),
      Offset(w * 0.25, h * 0.8),
      Offset(w * 0.5, h * 0.4),
      Offset(w * 0.75, h * 0.65),
      Offset(w, h * 0.2),
    ];

    // Create spline/smooth path
    final Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    // Paint for the line
    final Paint linePaint = Paint()
      ..color = const Color(0xFF7C5CFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Paint for fill gradient under the line
    final Path fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7C5CFF).withOpacity(0.3),
          const Color(0xFF7C5CFF).withOpacity(0.00),
        ],
      ).createShader(Rect.fromLTRB(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Draw elements
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw active point dots on the graph
    final Paint dotInnerPaint = Paint()
      ..color = const Color(0xFF7C5CFF)
      ..style = PaintingStyle.fill;

    final Paint dotOuterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint dotShadowPaint = Paint()
      ..color = const Color(0xFF7C5CFF).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (final pt in points) {
      canvas.drawCircle(pt, 8, dotShadowPaint);
      canvas.drawCircle(pt, 6, dotOuterPaint);
      canvas.drawCircle(pt, 3.5, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
