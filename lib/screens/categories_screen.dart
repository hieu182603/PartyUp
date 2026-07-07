import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_content_provider.dart';
import '../models/game_content.dart';
import '../core/theme/app_colors.dart';
import '../core/app_notification.dart';
import 'game_customization_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameContentProvider>().loadContents();
    });
  }

  int _selectedTab = 0; // 0: Tất cả, 1: Phổ biến, 2: Yêu thích
  int _bottomTabIndex = 0; // 0: Chủ đề, 1: Bộ câu hỏi, 2: Yêu thích
  List<String> _selectedCategories = [];
  String _filterCategory = 'Tất cả';

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
      'color': const Color(0xFFFF9F43), // Cam
      'isLight': false,
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
      'subtitle': '60 câu hỏi',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFF76C6C),
      'isLight': false,
    },
    {
      'name': 'Học đường',
      'subtitle': 'Hồi ức tuổi thơ',
      'icon': Icons.school_rounded,
      'color': const Color(0xFF4DB6AC),
      'isLight': false,
    },
    {
      'name': 'Công việc',
      'subtitle': 'Đồng nghiệp',
      'icon': Icons.work_rounded,
      'color': const Color(0xFF795548),
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
      body: _buildBody(),
      floatingActionButton: _bottomTabIndex == 0 && _selectedCategories.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameCustomizationScreen(categories: _selectedCategories),
                  ),
                );
              },
              backgroundColor: const Color(0xFF7C5CFF),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: Text(
                'Chơi ngay (${_selectedCategories.length} chủ đề)',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_bottomTabIndex) {
      case 1:
        return _buildQuestionSetsTab();
      case 2:
        return _buildFavoritesTab();
      case 0:
      default:
        return _buildThemesTab();
    }
  }

  Widget _buildThemesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Pill tabs selection
          Row(
            children: [
              _buildTabButton('Tất cả', 0),
              const SizedBox(height: 8, width: 8),
              _buildTabButton('Phổ biến', 1),
              const SizedBox(width: 8),
              _buildTabButton('Mới', 2),
            ],
          ),
          const SizedBox(height: 24),
          // Categories Grid
          Expanded(
            child: Builder(
              builder: (context) {
                List<Map<String, dynamic>> displayCategories = _categories;
                if (_selectedTab == 1) {
                  // Phổ biến
                  displayCategories = _categories.where((c) => ['Tình yêu', 'Tình bạn', 'Hài hước', 'Tổng hợp'].contains(c['name'])).toList();
                } else if (_selectedTab == 2) {
                  // Mới
                  displayCategories = _categories.where((c) => ['Công việc', 'Học đường', 'Ẩm thực'].contains(c['name'])).toList();
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: displayCategories.length,
                  itemBuilder: (context, index) {
                    final cat = displayCategories[index];
                final name = cat['name'] as String;
                final provider = Provider.of<GameContentProvider>(context);
                final int count = provider.getCategoryCount(name);
                final subtitle = name == 'Tổng hợp' ? 'Ngẫu nhiên' : '$count câu hỏi';
                final icon = cat['icon'] as IconData;
                final color = cat['color'] as Color;
                final isSelected = _selectedCategories.contains(name);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategories.remove(name);
                      } else {
                        _selectedCategories.add(name);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFE8EBF3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                              ? color.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
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
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: isSelected 
                                      ? LinearGradient(
                                          colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    icon,
                                    color: isSelected ? Colors.white : color,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSetsTab() {
    return Consumer<GameContentProvider>(
      builder: (context, provider, child) {
        var allContents = [...provider.truths, ...provider.dares, ...provider.rules];
        if (_filterCategory != 'Tất cả') {
          allContents = allContents.where((c) => c.category == _filterCategory).toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  const Text('Lọc theo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8EBF3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                          items: ['Tất cả', 'Tổng hợp', 'Tình yêu', 'Lifestyle', 'Tình bạn', 'Hài hước', 'Du lịch', 'Phim ảnh', 'Ẩm thực', 'Học đường', 'Công việc']
                              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _filterCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: allContents.isEmpty
                  ? const Center(child: Text("Chưa có câu hỏi nào trong chủ đề này.", style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: allContents.length,
                      itemBuilder: (context, index) {
                        return _buildContentListItem(allContents[index], provider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<GameContentProvider>(
      builder: (context, provider, child) {
        if (provider.favorites.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có câu hỏi yêu thích nào.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            )
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          itemCount: provider.favorites.length,
          itemBuilder: (context, index) {
            final content = provider.favorites[index];
            return _buildContentListItem(content, provider);
          },
        );
      },
    );
  }

  Widget _buildContentListItem(GameContent content, GameContentProvider provider) {
    final isTruth = content.type == 'truth';
    final primaryColor = isTruth ? const Color(0xFFFF5B7F) : const Color(0xFF368DFF);
    final isFav = provider.favorites.any((c) => c.id == content.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EBF3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTruth ? Icons.help_outline_rounded : Icons.bolt_rounded,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.content,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${content.type == 'truth' ? 'Thật' : 'Thách'} • ${content.points} điểm',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? const Color(0xFFFF5B7F) : AppColors.textSecondary,
            ),
            onPressed: () {
              provider.toggleFavorite(GameContent(
                id: content.id,
                content: content.content,
                type: content.type,
                level: content.level,
                isCustom: content.isCustom,
                isActive: content.isActive,
                isFavorite: isFav,
                penaltyText: content.penaltyText,
                points: content.points,
              ));
            },
          ),
        ],
      ),
    );
  }
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: BottomNavigationBar(
            currentIndex: _bottomTabIndex,
            selectedItemColor: const Color(0xFF7C5CFF),
            unselectedItemColor: AppColors.textSecondary,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12.0,
            unselectedFontSize: 12.0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _bottomTabIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Chủ đề'),
              BottomNavigationBarItem(icon: Icon(Icons.library_books_rounded), label: 'Bộ câu hỏi'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Yêu thích'),
            ],
          ),
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
