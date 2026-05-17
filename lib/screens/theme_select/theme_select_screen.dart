import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/models/game_theme_model.dart';
import 'package:solo_test/providers/theme_provider.dart';
import 'package:solo_test/widgets/particle_overlay.dart';

class ThemeSelectScreen extends StatefulWidget {
  const ThemeSelectScreen({super.key});

  @override
  State<ThemeSelectScreen> createState() => _ThemeSelectScreenState();
}

class _ThemeSelectScreenState extends State<ThemeSelectScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final PageController _pageController;
  double _pageOffset = 0;

  final List<GameTheme> _themes = GameTheme.values;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _pageController = PageController(
      viewportFraction: 0.68,
      initialPage: _themes.length * 1000,
    );
    _pageController.addListener(() {
      setState(() => _pageOffset = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _confirm() {
    final selectedIndex = _loopIndex(_pageOffset.round());
    context.read<ThemeProvider>().setTheme(_themes[selectedIndex]);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  int _loopIndex(int index) {
    final length = _themes.length;
    return ((index % length) + length) % length;
  }

  void _handleCarouselDragUpdate(DragUpdateDetails details) {
    if (!_pageController.hasClients) return;
    final nextPixels = _pageController.offset - details.delta.dx;
    _pageController.jumpTo(nextPixels);
  }

  void _handleCarouselDragEnd(DragEndDetails details) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      _pageOffset.round(),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  List<Widget> _buildArcCards(int selectedIndex) {
    const double cardSpacing = 180;
    const double arcDepth = 22;
    final themeCount = _themes.length;
    final pageShift = _pageOffset - _pageOffset.roundToDouble();
    final center = themeCount ~/ 2;

    return List.generate(_themes.length, (index) {
      final slot = index - center;
      final themeIndex = _loopIndex(selectedIndex + slot);
      final distance = slot - pageShift;
      final offsetX = distance * cardSpacing;
      final offsetY = math.pow(distance.abs(), 1.35).toDouble() * arcDepth;
      final scale = (1 - (distance.abs() * 0.1)).clamp(0.66, 1.0);
      final opacity = (1 - (distance.abs() * 0.26)).clamp(0.14, 1.0);

      final themeData = allThemes[_themes[themeIndex]]!;
      final isSelected = slot == 0;
      final targetPage = _pageOffset.round() + slot;

      return Transform.translate(
        offset: Offset(offsetX, offsetY),
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: _ThemeCircularCard(
              themeData: themeData,
              isSelected: isSelected,
              onTap: () {
                _pageController.animateToPage(
                  targetPage,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _loopIndex(_pageOffset.round());
    final selectedTheme = allThemes[_themes[selectedIndex]]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: selectedTheme.backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _bgController,
              builder:
                  (_, __) => Stack(
                    children: [
                      Positioned(
                        top: -100,
                        right: -80,
                        child: Opacity(
                          opacity: 0.35 + _bgController.value * 0.25,
                          child: Container(
                            width: 340,
                            height: 340,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  selectedTheme.backgroundGlow1,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        left: -100,
                        child: Opacity(
                          opacity: 0.25 + (1 - _bgController.value) * 0.2,
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  selectedTheme.backgroundGlow2,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ParticleOverlay(themeData: selectedTheme, count: 10),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 58),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [
                            selectedTheme.primaryLight,
                            selectedTheme.accentColor,
                          ],
                        ).createShader(bounds),
                    child: Text(
                      'SOLO TEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                        shadows: [
                          Shadow(
                            color: selectedTheme.backgroundColor.withOpacity(
                              0.35,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                selectedTheme.primaryLight.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Tema Seç',
                        style: TextStyle(
                          color: selectedTheme.textPrimary.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.5,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                selectedTheme.primaryLight.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 420,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragUpdate: _handleCarouselDragUpdate,
                          onHorizontalDragEnd: _handleCarouselDragEnd,
                          child: ClipRect(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  itemBuilder: (context, index) {
                                    return const SizedBox.expand();
                                  },
                                ),
                                ..._buildArcCards(selectedIndex),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    child: _StartButton(
                      themeData: selectedTheme,
                      onPressed: _confirm,
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
}

class _ThemeCircularCard extends StatelessWidget {
  final GameThemeData themeData;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCircularCard({
    required this.themeData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        width: 220,
        height: 300,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? themeData.primaryColor.withOpacity(0.18)
                  : themeData.glassColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? themeData.primaryColor : themeData.glassBorder,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: themeData.primaryColor.withOpacity(0.4),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                    ),
                  ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LargeBoardPreview(themeData: themeData),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: themeData.surfaceColor.withOpacity(
                        isSelected ? 0.9 : 0.78,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: themeData.primaryLight.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      themeData.name,
                      style: TextStyle(
                        color: themeData.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    themeData.description,
                    style: TextStyle(
                      color: themeData.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected
                              ? themeData.primaryColor
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected
                                ? themeData.primaryColor
                                : themeData.glassBorder,
                        width: 2,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LargeBoardPreview extends StatelessWidget {
  final GameThemeData themeData;

  const _LargeBoardPreview({required this.themeData});

  @override
  Widget build(BuildContext context) {
    const valid = [
      false,
      false,
      true,
      true,
      true,
      false,
      false,
      false,
      false,
      true,
      true,
      true,
      false,
      false,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      false,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      false,
      false,
      true,
      true,
      true,
      false,
      false,
      false,
      false,
      true,
      true,
      true,
      false,
      false,
    ];

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: themeData.boardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeData.boardBorder, width: 1.5),
      ),
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 2.5,
          crossAxisSpacing: 2.5,
        ),
        itemCount: 49,
        itemBuilder: (_, i) {
          if (!valid[i]) {
            return Container(
              decoration: BoxDecoration(
                color: themeData.boardEmpty,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }
          if (i == 24) {
            return Container(
              decoration: BoxDecoration(
                color: themeData.boardHole,
                shape: BoxShape.circle,
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                radius: 0.8,
                colors: [
                  themeData.pieceHighlight.withOpacity(0.9),
                  themeData.piecePrimary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: themeData.piecePrimary.withOpacity(0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StartButton extends StatefulWidget {
  final GameThemeData themeData;
  final VoidCallback onPressed;

  const _StartButton({required this.themeData, required this.onPressed});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                widget.themeData.primaryColor,
                widget.themeData.primaryDark,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.themeData.primaryColor.withOpacity(0.5),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'BAŞLA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
