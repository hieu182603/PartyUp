import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import 'game_customization_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedTab = 0; // 0: Tất cả, 1: Phổ biến, 2: Yêu thích
  int _bottomTabIndex = 0; // 0: Chủ đề, 1: Bộ câu hỏi, 2: Yêu thích
  String _selectedCategory = 'Tổng hợp';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Tổng hợp',
      'subtitle': 'Ngẫu nhiên',
      'icon': Icons.casino_rounded,
      'color': const Color(0xFF7C5CFF),
      'isLight': false,
    },
    {
      'name': 'Tình yêu',
      'subtitle': '120 câu hỏi',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF5B7F),
      'isLight': false,
    },
    {
      'name': 'Lifestyle',
      'subtitle': '120 câu hỏi',
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFFFFAF36),
      'isLight': false,
    },
    {
      'name': 'Tình bạn',
      'subtitle': '100 câu hỏi',
      'icon': Icons.people_rounded,
      'color': const Color(0xFF368DFF),
      'isLight': false,
    },
    {
      'name': 'Hài hước',
      'subtitle': '80 câu hỏi',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'color': const Color(0xFFFFD54F),
      'isLight': true,
    },
    {
      'name': 'Du lịch',
      'subtitle': '90 câu hỏi',
      'icon': Icons.public_rounded,
      'color': const Color(0xFF3DD99F),
      'isLight': false,
    },
    {
      'name': 'Phim ảnh',
      'subtitle': '70 câu hỏi',
      'icon': Icons.movie_rounded,
      'color': const Color(0xFF707E94),
      'isLight': false,
    },
    {
      'name': 'Ẩm thực',
      'subtitle': '80 câu hỏi',
      'icon': Icons.local_pizza_rounded,
      'color': const Color(0xFFFF7657),
      'isLight': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Chủ đề',
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
            // Pill tabs selection
            Row(
              children: [
                _buildTabButton('Tất cả', 0),
                const SizedBox(width: 8),
                _buildTabButton('Phổ biến', 1),
                const SizedBox(width: 8),
                _buildTabButton('Yêu thích', 2),
              ],
            ),
            const SizedBox(height: 24),
            // Categories Grid
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final name = cat['name'] as String;
                  final subtitle = cat['subtitle'] as String;
                  final icon = cat['icon'] as IconData;
                  final color = cat['color'] as Color;
                  final isSelected = _selectedCategory == name;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = name;
                      });
                      // Auto navigate to customization after selecting category
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameCustomizationScreen(categoryName: name),
                          ),
                        );
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFE8EBF3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                                ? color.withOpacity(0.25)
                                : Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (isSelected)
                            const Positioned(
                              top: 16,
                              right: 16,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Icon container
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.2)
                                        : color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: isSelected 
                                        ? Colors.white 
                                        : color,
                                    size: 28,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected 
                                        ? Colors.white 
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.8)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomTabIndex,
          selectedItemColor: const Color(0xFF7C5CFF),
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _bottomTabIndex = index;
            });
            if (index > 0) {
              AppNotification.info(context, 'Chức năng đang phát triển, sớm ra mắt! 🚀');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Chủ đề'),
            BottomNavigationBarItem(icon: Icon(Icons.library_books_rounded), label: 'Bộ câu hỏi'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Yêu thích'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int tabIndex) {
    final isSelected = _selectedTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tabIndex;
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
}
