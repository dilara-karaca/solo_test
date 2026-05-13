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
  late AnimationController _bgController;
  late ScrollController _scrollController;
  int _selectedIndex = 0;

  final List<GameTheme> _themes = GameTheme.values;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectTheme(int index) {
    setState(() => _selectedIndex = index);
    // Scroll to center the selected card
    _scrollController.animateTo(
      index * 280.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _confirm() {
    context.read<ThemeProvider>().setTheme(_themes[_selectedIndex]);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final selectedTheme = allThemes[_themes[_selectedIndex]]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: selectedTheme.backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Animated background glows
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

            // Particles
            Positioned.fill(
              child: IgnorePointer(
                child: ParticleOverlay(themeData: selectedTheme, count: 10),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // Title
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [
                            selectedTheme.primaryLight,
                            selectedTheme.accentColor,
                          ],
                        ).createShader(bounds),
                    child: const Text(
                      'SOLO TEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tema Seç',
                    style: TextStyle(
                      color: selectedTheme.textSecondary,
                      fontSize: 14,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Horizontal scrollable theme cards
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: _themes.length,
                            itemBuilder: (context, i) {
                              final t = allThemes[_themes[i]]!;
                              final isSelected = i == _selectedIndex;
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: i == 0 ? 24 : 12,
                                  right: i == _themes.length - 1 ? 24 : 0,
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: _ThemeHorizontalCard(
                                  themeData: t,
                                  isSelected: isSelected,
                                  onTap: () => _selectTheme(i),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Start button
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

class _ThemeHorizontalCard extends StatelessWidget {
  final GameThemeData themeData;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeHorizontalCard({
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
        width: 240,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large board preview
                  _LargeBoardPreview(themeData: themeData),
                  const SizedBox(height: 14),
                  // Theme name
                  Text(
                    themeData.name,
                    style: TextStyle(
                      color:
                          isSelected
                              ? themeData.primaryLight
                              : themeData.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // Theme description
                  Text(
                    themeData.description,
                    style: TextStyle(
                      color: themeData.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.3,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Selection indicator
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
    // Simplified cross-shape of the solitaire board (7x7 version for better preview)
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
          // Center is empty hole
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
  late AnimationController _ctrl;

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
