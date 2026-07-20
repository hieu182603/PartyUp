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
  final int coverStyle;
  bool isFlipped;
  GameContent? content;

  GameCardState({
    required this.index,
    required this.type,
    required this.coverStyle,
    this.isFlipped = false,
    this.content,
  });
}

class TruthOrDareChoiceScreen extends StatefulWidget {
  const TruthOrDareChoiceScreen({super.key});

  @override
  State<TruthOrDareChoiceScreen> createState() =>
      _TruthOrDareChoiceScreenState();
}

class _TruthOrDareChoiceScreenState extends State<TruthOrDareChoiceScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _shuffleController;

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

    // 1. Generate the deck. Each row receives all three cover colors.
    _generateCards();

    // 2. Setup the shuffle timeline. Card offsets and rotations are derived
    // from this single value so every card stays perfectly in sync.
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    );

    // 3. Setup 3D flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // 4. Start after the first frame so the stacked deck is visible before it
    // fans out, shuffles, and deals.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runShuffleAndDeal());
  }

  void _generateCards() {
    final List<String> types = [
      'truth',
      'truth',
      'truth',
      'dare',
      'dare',
      'dare',
    ];
    types.shuffle();

    final coverStyles = <int>[];
    for (var row = 0; row < 2; row++) {
      final rowStyles = <int>[0, 1, 2]..shuffle();
      coverStyles.addAll(rowStyles);
    }

    _cards.clear();
    for (int i = 0; i < 6; i++) {
      _cards.add(
        GameCardState(index: i, type: types[i], coverStyle: coverStyles[i]),
      );
    }
  }

  ({Offset offset, double rotation, double scale}) _shuffleMotion(
    int index,
    double progress,
  ) {
    final side = index.isEven ? -1.0 : 1.0;
    final depth = (index ~/ 2).toDouble();
    final splitDistance = 28.0 + depth * 4;

    if (progress < 0.28) {
      final t = Curves.easeInOutCubic.transform(progress / 0.28);
      return (
        offset: Offset(
          side * splitDistance * t,
          (depth - 1) * 4 * t - math.sin(t * math.pi) * 8,
        ),
        rotation: side * 0.12 * t,
        scale: 1 + math.sin(t * math.pi) * 0.03,
      );
    }

    if (progress < 0.72) {
      final t = (progress - 0.28) / 0.44;
      final wave = math.cos(t * math.pi * 3);
      final amplitude = 1 - 0.35 * t;
      return (
        offset: Offset(
          side * splitDistance * wave * amplitude,
          (depth - 1) * 3 +
              math.sin(t * math.pi * 4 + index * 0.55) * 5 -
              math.sin(t * math.pi * 3).abs() * 7,
        ),
        rotation: side * 0.11 * wave,
        scale: 1 + math.sin(t * math.pi * 3).abs() * 0.025,
      );
    }

    final t = Curves.easeInOutCubic.transform((progress - 0.72) / 0.28);
    return (
      offset: Offset(
        -side * splitDistance * 0.65 * (1 - t) +
            side * math.sin(t * math.pi) * 4,
        (depth - 1) * 3 * (1 - t) - math.sin(t * math.pi) * 10,
      ),
      rotation: -side * 0.08 * (1 - t),
      scale: 1 + math.sin(t * math.pi) * 0.04,
    );
  }

  Future<void> _runShuffleAndDeal() async {
    if (!mounted) return;
    setState(() {
      _isShuffling = true;
      for (var i = 0; i < _dealtCards.length; i++) {
        _dealtCards[i] = false;
      }
    });

    _playShuffleSFX();
    await _shuffleController.forward(from: 0);
    if (!mounted) return;

    setState(() => _isShuffling = false);
    await _dealCardsStaggered();
  }

  void _playShuffleSFX() async {
    for (int i = 0; i < 7; i++) {
      await Future.delayed(Duration(milliseconds: i.isEven ? 150 : 195));
      if (mounted && _isShuffling) {
        AudioService.instance.playSFX('tap.mp3');
      }
    }
  }

  Future<void> _dealCardsStaggered() async {
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 105));
      if (mounted) {
        setState(() {
          _dealtCards[i] = true;
        });
        HapticFeedback.selectionClick();
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
    final todProvider = Provider.of<TruthOrDareProvider>(
      context,
      listen: false,
    );
    final contentProvider = Provider.of<GameContentProvider>(
      context,
      listen: false,
    );
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
      AppNotification.error(
        context,
        'Kho câu hỏi đã cạn, không thể đổi câu khác!',
      );
    }
  }

  // ─── Card Selection Tap Handler ──────────────────────────────────────────
  void _onCardTapped(int index) async {
    if (_isShuffling ||
        !_dealtCards.every((d) => d) ||
        _selectedCardIndex != null ||
        _isLocked) {
      return;
    }

    setState(() => _isLocked = true);

    final contentProvider = Provider.of<GameContentProvider>(
      context,
      listen: false,
    );
    final todProvider = Provider.of<TruthOrDareProvider>(
      context,
      listen: false,
    );
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
      AppNotification.success(
        context,
        'Các bạn chơi quá đỉnh, kho bài đã cạn! Hệ thống đang xáo lại bộ bài để cuộc vui tiếp tục nhé!',
      );

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
      AppNotification.error(
        context,
        'Không tìm thấy câu hỏi/thử thách phù hợp! Hãy thử đổi cài đặt mức độ hoặc thể loại.',
      );
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
                    _generateCards();
                  });
                  _runShuffleAndDeal();
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
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: RandomAvatar(
                    player.name,
                    trBackground: false,
                    height: 72,
                    width: 72,
                  ),
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

                      // A 3 x 2 grid preserves the generated playing-card
                      // artwork's 2:3 ratio instead of stretching it into tiles.
                      const double spacingX = 10.0;
                      const double spacingY = 14.0;

                      final double cellWidth = (W - spacingX * 2) / 3;
                      final double cellHeight = math
                          .min((H - spacingY) / 2, cellWidth * 1.48)
                          .toDouble();
                      final double gridHeight = cellHeight * 2 + spacingY;
                      final double gridTopInset = (H - gridHeight) / 2;

                      final double deckWidth = math
                          .min(cellWidth * 1.18, W * 0.40)
                          .toDouble();
                      final double deckHeight = deckWidth * 1.48;
                      final double deckLeft = (W - deckWidth) / 2;
                      final double deckTop = (H - deckHeight) / 2;
                      final double shuffleProgress = _shuffleController.value;

                      return Stack(
                        children: List.generate(6, (index) {
                          final card = _cards[index];
                          final int row = index ~/ 3;
                          final int col = index % 3;

                          final double gridLeft = col * (cellWidth + spacingX);
                          final double gridTop =
                              gridTopInset + row * (cellHeight + spacingY);

                          double left;
                          double top;
                          double width;
                          double height;
                          double opacity = 1.0;
                          double rotation = 0;
                          double scale = 1;

                          if (_selectedCardIndex == null) {
                            if (_isShuffling) {
                              final motion = _shuffleMotion(
                                index,
                                shuffleProgress,
                              );
                              left = deckLeft + motion.offset.dx;
                              top = deckTop + motion.offset.dy;
                              width = deckWidth;
                              height = deckHeight;
                              rotation = motion.rotation;
                              scale = motion.scale;
                            } else if (_dealtCards[index]) {
                              left = gridLeft;
                              top = gridTop;
                              width = cellWidth;
                              height = cellHeight;
                            } else {
                              left = deckLeft + (index - 2.5) * 0.9;
                              top = deckTop - (index - 2.5) * 0.55;
                              width = deckWidth;
                              height = deckHeight;
                              rotation = (index - 2.5) * 0.006;
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

                          final cardWidget = AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: Transform.rotate(
                                angle: rotation,
                                child: IgnorePointer(
                                  ignoring:
                                      (_selectedCardIndex != null &&
                                          _selectedCardIndex != index) ||
                                      _isShuffling ||
                                      !_dealtCards[index],
                                  child: GestureDetector(
                                    onTap: () => _onCardTapped(index),
                                    child: _buildFlipCard(card, index),
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (_isShuffling) {
                            return Positioned(
                              left: left,
                              top: top,
                              width: width,
                              height: height,
                              child: cardWidget,
                            );
                          }

                          return AnimatedPositioned(
                            duration: Duration(
                              milliseconds: _selectedCardIndex == null
                                  ? 430
                                  : 520,
                            ),
                            curve: _selectedCardIndex == null
                                ? Curves.easeOutBack
                                : Curves.easeInOutCubic,
                            left: left,
                            top: top,
                            width: width,
                            height: height,
                            child: cardWidget,
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
                      MaterialPageRoute(
                        builder: (_) => const RandomPlayerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
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
    final front = _buildCardFront(card);
    if (_selectedCardIndex == index) {
      return AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return FlipCardWidget(
            angle: _flipAnimation.value,
            front: front,
            back: _buildCardBack(card),
          );
        },
      );
    } else {
      return FlipCardWidget(
        angle: 0.0,
        front: front,
        back: _buildCardBack(card),
      );
    }
  }

  // ─── Card Front Side UI ──────────────────────────────────────────────────
  Widget _buildCardFront(GameCardState card) {
    return PartyCardFront(coverStyle: card.coverStyle);
  }

  // ─── Card Back Side UI ───────────────────────────────────────────────────
  Widget _buildCardBack(GameCardState card) {
    final content = card.content;
    if (content == null) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF079E9D), width: 2),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isTruth = card.type == 'truth';
    final accentColor = isTruth
        ? const Color(0xFF079E9D)
        : const Color(0xFF6A35C8);
    final badgeColor = isTruth
        ? const Color(0xFF079E9D)
        : const Color(0xFFFFC318);
    final decorationColor = isTruth
        ? const Color(0xFFFF5D50)
        : const Color(0xFF6A35C8);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E202C).withValues(alpha: 0.08),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 22,
              top: 88,
              child: Icon(Icons.star_rounded, size: 16, color: decorationColor),
            ),
            Positioned(
              right: 22,
              top: 150,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 28,
              bottom: 92,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC318),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isTruth ? 'SỰ THẬT' : 'THỬ THÁCH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isTruth
                                  ? Colors.white
                                  : const Color(0xFF1E202C),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: _buildFavoriteButton(content),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          content.content,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E202C),
                            height: 1.42,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF3),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: accentColor, width: 1.5),
                      ),
                      child: Text(
                        'Chủ đề: ${_getCategoryDisplay(content)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF343746),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 28,
                  child: CustomPaint(
                    painter: CardZigzagPainter(color: accentColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(GameContent content) {
    return Consumer<GameContentProvider>(
      builder: (context, contentProvider, _) {
        final isFav = contentProvider.favorites.any((c) => c.id == content.id);
        return GestureDetector(
          onTap: () {
            AudioService.instance.playSFX('tap.mp3');
            contentProvider.toggleFavorite(
              GameContent(
                id: content.id,
                content: content.content,
                type: content.type,
                level: content.level,
                category: content.category,
                isCustom: content.isCustom,
                isActive: content.isActive,
                isFavorite: isFav,
                penaltyText: content.penaltyText,
                points: content.points,
              ),
            );
          },
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFav
                ? const Color(0xFFFF5D50)
                : const Color(0xFF7D8398).withValues(alpha: 0.65),
            size: 28,
          ),
        );
      },
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
    final primaryColor = isTruth
        ? const Color(0xFF079E9D)
        : const Color(0xFF6A35C8);
    const dangerColor = Color(0xFFFF5D50);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _timeLeft / todProvider.timeLimit,
            backgroundColor: Colors.black.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(
              !_isTimerStarted
                  ? Colors.grey.shade300
                  : (_timeLeft <= 5 ? dangerColor : primaryColor),
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
                    : (_timeLeft <= 5 ? dangerColor : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: !_isTimerStarted
                      ? AppColors.textSecondary.withValues(alpha: 0.2)
                      : (_timeLeft <= 5
                            ? Colors.transparent
                            : primaryColor.withValues(alpha: 0.3)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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
                        ? AppColors.textSecondary.withValues(alpha: 0.6)
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
                          ? AppColors.textSecondary.withValues(alpha: 0.6)
                          : (_timeLeft <= 5
                                ? Colors.white
                                : AppColors.textPrimary),
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
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: !_isTimerStarted
                          ? [
                              const Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Tính giờ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ]
                          : [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
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
                    border: Border.all(color: dangerColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'Bỏ cuộc',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: dangerColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (todProvider.currentPlayer != null &&
            todProvider.canReroll(todProvider.currentPlayer!.id!))
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Center(
              child: TextButton.icon(
                onPressed: _onReroll,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
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

class PartyCardFront extends StatelessWidget {
  final int coverStyle;

  const PartyCardFront({super.key, required this.coverStyle});

  @override
  Widget build(BuildContext context) {
    const assets = [
      'assets/images/truth_card.png',
      'assets/images/dare_card.png',
      'assets/images/star_card.png',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10162D).withValues(alpha: 0.28),
            offset: const Offset(0, 9),
            blurRadius: 18,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          assets[coverStyle % assets.length],
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class CardZigzagPainter extends CustomPainter {
  final Color color;

  const CardZigzagPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const toothWidth = 22.0;
    final top = size.height * 0.42;
    final path = Path()..moveTo(0, top);

    for (double x = 0; x < size.width; x += toothWidth) {
      path
        ..lineTo(x + toothWidth / 2, 0)
        ..lineTo(x + toothWidth, top);
    }

    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CardZigzagPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
