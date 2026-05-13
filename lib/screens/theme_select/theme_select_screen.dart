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
  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _cardAnim;
  int _selectedIndex = 0;

  final List<GameTheme> _themes = GameTheme.values;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardAnim = CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack);
    _cardController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _selectTheme(int index) {
    setState(() => _selectedIndex = index);
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
              builder: (_, __) => Stack(
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
                          gradient: RadialGradient(colors: [
                            selectedTheme.backgroundGlow1,
                            Colors.transparent,
                          ]),
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
                          gradient: RadialGradient(colors: [
                            selectedTheme.backgroundGlow2,
                            Colors.transparent,
                          ]),
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
                    shaderCallback: (bounds) => LinearGradient(
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
                  const SizedBox(height: 48),

                  // Theme cards
                  Expanded(
                    child: ScaleTransition(
                      scale: _cardAnim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(_themes.length, (i) {
                            final t = allThemes[_themes[i]]!;
                            final isSelected = i == _selectedIndex;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ThemeCard(
                                themeData: t,
                                isSelected: isSelected,
                                onTap: () => _selectTheme(i),
                              ),
                            );
                          }),
                        ),
                      ),
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

class _ThemeCard extends StatelessWidget {
  final GameThemeData themeData;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.themeData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 90,
        decoration: BoxDecoration(
          color: isSelected
              ? themeData.primaryColor.withOpacity(0.18)
              : themeData.glassColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? themeData.primaryColor
                : themeData.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeData.primaryColor.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Mini board preview
                  _MiniPreview(themeData: themeData),
                  const SizedBox(width: 18),
                  // Text
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          themeData.name,
                          style: TextStyle(
                            color: isSelected
                                ? themeData.primaryLight
                                : themeData.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          themeData.description,
                          style: TextStyle(
                            color: themeData.textSecondary,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? themeData.primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? themeData.primaryColor
                            : themeData.glassBorder,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 13)
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

class _MiniPreview extends StatelessWidget {
  final GameThemeData themeData;

  const _MiniPreview({required this.themeData});

  @override
  Widget build(BuildContext context) {
    // Simplified cross-shape of the solitaire board (5x5 version)
    const valid = [
      false, false, true, false, false,
      false, false, true, false, false,
      true,  true,  true, true,  true,
      false, false, true, false, false,
      false, false, true, false, false,
    ];

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: themeData.boardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeData.boardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(5),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: 25,
        itemBuilder: (_, i) {
          if (!valid[i]) {
            return Container(
              decoration: BoxDecoration(
                color: themeData.boardEmpty,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }
          // Center is empty hole
          if (i == 12) {
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
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
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
