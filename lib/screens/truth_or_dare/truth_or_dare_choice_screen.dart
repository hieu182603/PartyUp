import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../../providers/truth_or_dare_provider.dart';
import '../../providers/game_content_provider.dart';
import '../../models/game_content.dart';
import '../../core/theme/app_colors.dart';
import '../../core/app_notification.dart';
import '../../services/audio_service.dart';
import 'package:random_avatar/random_avatar.dart';
import 'random_player_screen.dart';
import 'success_screen.dart';
import 'skip_screen.dart';

class GameCardState {
  final int index;
  final String type; // 'truth' or 'dare'
  bool isFlipped;
  GameContent? content;

  GameCardState({
    required this.index,
    required this.type,
    this.isFlipped = false,
    this.content,
  });
}

class TruthOrDareChoiceScreen extends StatefulWidget {
  const TruthOrDareChoiceScreen({super.key});

  @override
  State<TruthOrDareChoiceScreen> createState() => _TruthOrDareChoiceScreenState();
}

class _TruthOrDareChoiceScreenState extends State<TruthOrDareChoiceScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _shuffleController;
  late Animation<double> _shuffleOffsetAnimation;
  
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // State lists
  final List<GameCardState> _cards = [];
  bool _isShuffling = true;
  final List<bool> _dealtCards = List.filled(6, false);
  int? _selectedCardIndex;

  // Timer & Gameplay States (mirrored from ContentPlayingScreen)
  int _timeLeft = 30;
  Timer? _timer;
  bool _isLocked = false;
  bool _isTimerStarted = false;

  @override
  void initState() {
    super.initState();
    
    // 1. Generate 3 Truth and 3 Dare cards
    final List<String> types = ['truth', 'truth', 'truth', 'dare', 'dare', 'dare'];
    types.shuffle();
    for (int i = 0; i < 6; i++) {
      _cards.add(GameCardState(index: i, type: types[i]));
    }

    // 2. Setup shuffle animations
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _shuffleOffsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 15.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: -15.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
    ]).animate(_shuffleController);

    // 3. Setup 3D flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // 4. Start shuffle sound effects
    _playShuffleSFX();

    // 5. Run shuffle & deal staggered
    _shuffleController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isShuffling = false;
        });
        _dealCardsStaggered();
      }
    });
  }

  void _playShuffleSFX() async {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(milliseconds: 180 + i * 20));
      if (mounted && _isShuffling) {
        AudioService.instance.playSFX('tap.mp3');
      }
    }
  }

  void _dealCardsStaggered() async {
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) {
        setState(() {
          _dealtCards[i] = true;
        });
        AudioService.instance.playSFX('tap.mp3');
      }
    }
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    _flipController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ─── Timer Logic (ContentPlayingScreen matching) ─────────────────────────
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        if (_timeLeft <= 5 && _timeLeft > 0) {
          HapticFeedback.lightImpact();
          AudioService.instance.playSFX('tick.mp3');
        }
      } else {
        _timer?.cancel();
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    if (_isLocked) return;
    setState(() => _isLocked = true);
    AudioService.instance.playSFX('siren.mp3');
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _onSkip();
      }
    });
  }

  void _onAnswer() {
    if (_isLocked) return;
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SuccessScreen()),
    );
  }

  void _onSkip() {
    if (_isLocked && _timeLeft > 0) return;
    if (_isLocked && _timeLeft == 0) {}
    setState(() => _isLocked = true);
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SkipScreen()),
    );
  }

  void _onReroll() async {
    if (_isLocked) return;
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final contentProvider = Provider.of<GameContentProvider>(context, listen: false);
    final player = todProvider.currentPlayer;
    if (player == null || !todProvider.canReroll(player.id!)) return;

    final type = todProvider.currentContent?.type ?? 'truth';
    setState(() => _isLocked = true);

    final content = await contentProvider.getRandomContent(
      type,
      categories: todProvider.currentCategories,
      difficulty: todProvider.currentDifficulty,
      favoritesOnly: todProvider.favoritesOnly,
    );

    if (!mounted) return;

    if (content != null) {
      todProvider.useReroll(player.id!);
      todProvider.chooseType(content);
      _timer?.cancel();
      setState(() {
        _cards[_selectedCardIndex!].content = content;
        _timeLeft = todProvider.timeLimit;
        _isTimerStarted = false;
        _isLocked = false;
      });
      AudioService.instance.playSFX('tap.mp3');
    } else {
      setState(() => _isLocked = false);
      AppNotification.error(context, 'Kho câu hỏi đã cạn, không thể đổi câu khác!');
    }
  }

  // ─── Card Selection Tap Handler ──────────────────────────────────────────
  void _onCardTapped(int index) async {
    if (_isShuffling || !_dealtCards.every((d) => d) || _selectedCardIndex != null || _isLocked) return;

    setState(() => _isLocked = true);

    final contentProvider = Provider.of<GameContentProvider>(context, listen: false);
    final todProvider = Provider.of<TruthOrDareProvider>(context, listen: false);
    final card = _cards[index];

    var content = await contentProvider.getRandomContent(
      card.type,
      categories: todProvider.currentCategories,
      difficulty: todProvider.currentDifficulty,
      favoritesOnly: todProvider.favoritesOnly,
    );

    if (!mounted) return;

    if (content == null) {
      contentProvider.resetUsedContents();
      AppNotification.success(context, 'Các bạn chơi quá đỉnh, kho bài đã cạn! Hệ thống đang xáo lại bộ bài để cuộc vui tiếp tục nhé!');
      
      content = await contentProvider.getRandomContent(
        card.type,
        categories: todProvider.currentCategories,
        difficulty: todProvider.currentDifficulty,
        favoritesOnly: todProvider.favoritesOnly,
      );
      if (!mounted) return;
    }

    if (content != null) {
      setState(() {
        card.content = content;
        card.isFlipped = true;
        _selectedCardIndex = index;
        _timeLeft = todProvider.timeLimit;
        _isLocked = false;
      });

      todProvider.chooseType(content);
      AudioService.instance.playSFX('tap.mp3');
      _flipController.forward();
    } else {
      setState(() => _isLocked = false);
      AppNotification.error(context, 'Không tìm thấy câu hỏi/thử thách phù hợp! Hãy thử đổi cài đặt mức độ hoặc thể loại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final todProvider = Provider.of<TruthOrDareProvider>(context);
    final player = todProvider.currentPlayer;

    if (player == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: _selectedCardIndex == null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 24),
                onPressed: () {
                  // If playing, allow resetting turn back to choice
                  _timer?.cancel();
                  setState(() {
                    _selectedCardIndex = null;
                    _isTimerStarted = false;
                    _isLocked = false;
                    _flipController.reset();
                    // Generate new set of cards
                    final List<String> types = ['truth', 'truth', 'truth', 'dare', 'dare', 'dare'];
                    types.shuffle();
                    _cards.clear();
                    for (int i = 0; i < 6; i++) {
                      _cards.add(GameCardState(index: i, type: types[i]));
                      _dealtCards[i] = false;
                    }
                    _isShuffling = true;
                  });
                  _playShuffleSFX();
                  _shuffleController.forward(from: 0.0).then((_) {
                    if (mounted) {
                      setState(() {
                        _isShuffling = false;
                      });
                      _dealCardsStaggered();
                    }
                  });
                },
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              AudioService.instance.isSoundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              size: 24,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                AudioService.instance.setSoundEnabled(
                  !AudioService.instance.isSoundEnabled,
                );
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header text with Avatar
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: RandomAvatar(player.name, trBackground: false, height: 72, width: 72),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedCardIndex == null
                        ? 'Chọn đi nào! Sự thật hay Thử thách?'
                        : 'Lật lá bài để xem câu hỏi hoặc thử thách!',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Cards zone
            Expanded(
              child: AnimatedBuilder(
                animation: _shuffleController,
                builder: (context, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final double W = constraints.maxWidth;
                      final double H = constraints.maxHeight;

                      const double spacingX = 14.0;
                      const double spacingY = 14.0;

                      final double cellWidth = (W - spacingX) / 2;
                      final double cellHeight = (H - spacingY * 2) / 3;

                      final double centerLeft = (W - cellWidth) / 2;
                      final double centerTop = (H - cellHeight) / 2;

                      return Stack(
                        children: List.generate(6, (index) {
                          final card = _cards[index];
                          final int row = index ~/ 2;
                          final int col = index % 2;

                          final double gridLeft = col * (cellWidth + spacingX);
                          final double gridTop = row * (cellHeight + spacingY);

                          double left;
                          double top;
                          double width;
                          double height;
                          double opacity = 1.0;

                          if (_selectedCardIndex == null) {
                            if (_isShuffling) {
                              left = centerLeft + (index - 2.5) * _shuffleOffsetAnimation.value;
                              top = centerTop;
                              width = cellWidth;
                              height = cellHeight;
                            } else if (_dealtCards[index]) {
                              left = gridLeft;
                              top = gridTop;
                              width = cellWidth;
                              height = cellHeight;
                            } else {
                              left = centerLeft;
                              top = centerTop;
                              width = cellWidth;
                              height = cellHeight;
                            }
                          } else {
                            if (_selectedCardIndex == index) {
                              left = 0;
                              top = 0;
                              width = W;
                              height = H;
                            } else {
                              left = gridLeft;
                              top = gridTop;
                              width = cellWidth;
                              height = cellHeight;
                              opacity = 0.0;
                            }
                          }

                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                            left: left,
                            top: top,
                            width: width,
                            height: height,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: opacity,
                              child: IgnorePointer(
                                ignoring: _selectedCardIndex != null && _selectedCardIndex != index,
                                child: GestureDetector(
                                  onTap: () => _onCardTapped(index),
                                  child: _buildFlipCard(card, index),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            // Bottom zone
            if (_selectedCardIndex == null) ...[
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RandomPlayerScreen()),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
                  label: const Text(
                    'Đổi lượt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              _buildGameplayControls(todProvider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFlipCard(GameCardState card, int index) {
    if (_selectedCardIndex == index) {
      return AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return FlipCardWidget(
            angle: _flipAnimation.value,
            front: _buildCardFront(card),
            back: _buildCardBack(card),
          );
        },
      );
    } else {
      return FlipCardWidget(
        angle: 0.0,
        front: _buildCardFront(card),
        back: _buildCardBack(card),
      );
    }
  }

  // ─── Card Front Side UI ──────────────────────────────────────────────────
  Widget _buildCardFront(GameCardState card) {
    return CartoonCardFront(isTruth: card.type == 'truth', cardId: card.index.toString());
  }

  // ─── Card Back Side UI ───────────────────────────────────────────────────
  Widget _buildCardBack(GameCardState card) {
    final content = card.content;
    if (content == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E202C), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1E202C),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isTruth = card.type == 'truth';
    final primaryColor = isTruth ? const Color(0xFFFF4B72) : const Color(0xFF368DFF);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E202C), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1E202C),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
                ),
                child: Text(
                  isTruth ? 'SỰ THẬT' : 'THỬ THÁCH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ),
              Consumer<GameContentProvider>(
                builder: (context, contentProvider, _) {
                  final isFav = contentProvider.favorites.any((c) => c.id == content.id);
                  return GestureDetector(
                    onTap: () {
                      AudioService.instance.playSFX('tap.mp3');
                      contentProvider.toggleFavorite(GameContent(
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
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? const Color(0xFFFF4B72) : const Color(0xFF7D8398).withOpacity(0.5),
                      size: 24,
                    ),
                  );
                },
              ),
            ],
          ),
          const Spacer(flex: 2),
          Expanded(
            flex: 12,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  content.content,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E202C),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Chủ đề: ${_getCategoryDisplay(content)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7D8398),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplay(GameContent content) {
    if (content.category.isNotEmpty && content.category != 'Tổng hợp') {
      return content.category;
    }
    if (content.type == 'truth') return 'Sự thật';
    if (content.type == 'dare') return 'Thử thách';
    return 'Tổng hợp';
  }

  // ─── Inline Game Controls Side UI ────────────────────────────────────────
  Widget _buildGameplayControls(TruthOrDareProvider todProvider) {
    final isTruth = todProvider.currentContent?.type == 'truth';
    final primaryColor = isTruth ? const Color(0xFFFF4B72) : const Color(0xFF368DFF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _timeLeft / todProvider.timeLimit,
            backgroundColor: Colors.black.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(
              !_isTimerStarted 
                  ? Colors.grey.shade300 
                  : (_timeLeft <= 5 ? const Color(0xFFFF4B72) : primaryColor),
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: !_isTimerStarted 
                    ? Colors.white 
                    : (_timeLeft <= 5 ? const Color(0xFFFF4B72) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: !_isTimerStarted 
                      ? AppColors.textSecondary.withOpacity(0.2)
                      : (_timeLeft <= 5 ? Colors.transparent : primaryColor.withOpacity(0.3)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: !_isTimerStarted
                        ? AppColors.textSecondary.withOpacity(0.6)
                        : (_timeLeft <= 5 ? Colors.white : primaryColor),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_timeLeft\u200es',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: !_isTimerStarted
                          ? AppColors.textSecondary.withOpacity(0.6)
                          : (_timeLeft <= 5 ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  if (!_isTimerStarted) {
                    setState(() {
                      _isTimerStarted = true;
                    });
                    _startTimer();
                    AudioService.instance.playSFX('tap.mp3');
                  } else {
                    _onAnswer();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isTruth
                          ? [const Color(0xFFFF4B72), const Color(0xFFFF7292)]
                          : [const Color(0xFF368DFF), const Color(0xFF68A9FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: !_isTimerStarted ? [
                        const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        const Text(
                          'Tính giờ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ] : [
                        const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+${todProvider.rewardPoints} Hoàn thành',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: _onSkip,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Bỏ cuộc',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (todProvider.currentPlayer != null && todProvider.canReroll(todProvider.currentPlayer!.id!))
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Center(
              child: TextButton.icon(
                onPressed: _onReroll,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 18),
                label: const Text(
                  'Đổi câu khác (còn 1 lần)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ─── 3D Card Flip Animation Helper Widget ──────────────────────────────────
class FlipCardWidget extends StatelessWidget {
  final Widget front;
  final Widget back;
  final double angle;

  const FlipCardWidget({
    super.key,
    required this.front,
    required this.back,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    final isBack = angle >= math.pi / 2;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002) // perspective
        ..rotateY(angle),
      alignment: Alignment.center,
      child: isBack
          ? Transform(
              transform: Matrix4.identity()..rotateY(math.pi),
              alignment: Alignment.center,
              child: back,
            )
          : front,
    );
  }
}

class CartoonCardFront extends StatelessWidget {
  final bool isTruth;
  final String cardId;
  
  const CartoonCardFront({super.key, required this.isTruth, required this.cardId});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFF9C73D), // Yellow
      const Color(0xFF4C9FAD), // Teal
      const Color(0xFFA764FA), // Purple
      const Color(0xFFF07B3F), // Orange
      const Color(0xFF9CCC58), // Green
      const Color(0xFFD43A67), // Pink/Red
    ];
    
    // Pick color based on card ID
    final colorIndex = cardId.hashCode.abs() % colors.length;
    final bgColor = colors[colorIndex];
    final ink = const Color(0xFF1E1E24);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Monster Face perfectly centered
          Center(
            child: SizedBox(
              width: 140,
              height: 120,
              child: CustomPaint(
                painter: MonsterFacePainter(),
              ),
            ),
          ),
          
          // Top Tag
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 6, right: 14, top: 6, bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, offset: Offset(0, 3), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22, 
                        height: 22,
                        decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            isTruth ? 'T' : 'D',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTruth ? 'TRUTH' : 'DARE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: ink,
                          letterSpacing: 0.5,
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
    );
  }
}

class MonsterFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()..color = const Color(0xFF1E1E24)..style = PaintingStyle.fill;
    final blush = Paint()..color = Colors.black.withValues(alpha: 0.15)..style = PaintingStyle.fill;
    final chin = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Horns
    // Left horn
    Path leftHorn = Path();
    leftHorn.moveTo(w * 0.35, h * 0.4); 
    leftHorn.quadraticBezierTo(w * 0.15, h * 0.15, w * 0.25, h * 0.05); 
    leftHorn.quadraticBezierTo(w * 0.35, h * 0.2, w * 0.45, h * 0.4);
    canvas.drawPath(leftHorn, ink);

    // Right horn
    Path rightHorn = Path();
    rightHorn.moveTo(w * 0.65, h * 0.4); 
    rightHorn.quadraticBezierTo(w * 0.85, h * 0.15, w * 0.75, h * 0.05); 
    rightHorn.quadraticBezierTo(w * 0.65, h * 0.2, w * 0.55, h * 0.4);
    canvas.drawPath(rightHorn, ink);

    // Eyes
    canvas.drawCircle(Offset(w * 0.35, h * 0.55), w * 0.07, ink);
    canvas.drawCircle(Offset(w * 0.65, h * 0.55), w * 0.07, ink);

    // Blush
    canvas.drawCircle(Offset(w * 0.20, h * 0.62), w * 0.05, blush);
    canvas.drawCircle(Offset(w * 0.80, h * 0.62), w * 0.05, blush);

    // Mouth
    Path mouth = Path();
    mouth.moveTo(w * 0.3, h * 0.7);
    // Left fang
    mouth.lineTo(w * 0.35, h * 0.8);
    mouth.lineTo(w * 0.4, h * 0.72);
    // Middle curve
    mouth.quadraticBezierTo(w * 0.5, h * 0.68, w * 0.6, h * 0.72);
    // Right fang
    mouth.lineTo(w * 0.65, h * 0.8);
    mouth.lineTo(w * 0.7, h * 0.7);
    
    // Bottom curve
    mouth.quadraticBezierTo(w * 0.5, h * 1.05, w * 0.3, h * 0.7);
    canvas.drawPath(mouth, ink);
    
    // Tongue inside mouth (We can clip it)
    canvas.save();
    canvas.clipPath(mouth);
    final tonguePaint = Paint()..color = const Color(0xFFFF4B72)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.95), w * 0.15, tonguePaint);
    canvas.restore();
    
    // Chin shadow
    Path chinPath = Path();
    chinPath.moveTo(w * 0.42, h * 0.98);
    chinPath.quadraticBezierTo(w * 0.5, h * 1.05, w * 0.58, h * 0.98);
    canvas.drawPath(chinPath, chin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
