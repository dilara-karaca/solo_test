import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:solo_test/core/constants/app_colors.dart';
import 'package:solo_test/core/constants/app_text_styles.dart';
import 'stats_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background glow orbs
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) => Stack(
              children: [
                Positioned(
                  top: -90,
                  right: -70,
                  child: Opacity(
                    opacity: _pulseAnim.value * 0.45,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.primaryColor, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: -80,
                  child: Opacity(
                    opacity: (1.0 - _pulseAnim.value) * 0.35,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.accentColor, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const StatsBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 44),
                          _HeroIcon(
                            pulseAnim: _pulseAnim,
                            orbitController: _orbitController,
                          ),
                          const SizedBox(height: 36),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.primaryLight, AppColors.accentColor],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds),
                            child: Text(
                              'SOLO TEST',
                              style: AppTextStyles.heading1.copyWith(
                                color: Colors.white,
                                letterSpacing: 10,
                                fontSize: 34,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tüm piyonları kaldırıp son piyonu\northaya bırakmaya çalışın.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 52),
                          _PlayButton(
                            onPressed: () => Navigator.of(context).pushNamed('/game'),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _GlassButton(
                                  icon: Icons.info_outline_rounded,
                                  label: 'KURALLAR',
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _GlassButton(
                                  icon: Icons.tune_rounded,
                                  label: 'AYARLAR',
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
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

class _HeroIcon extends StatelessWidget {
  final Animation<double> pulseAnim;
  final AnimationController orbitController;

  const _HeroIcon({required this.pulseAnim, required this.orbitController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pulseAnim, orbitController]),
      builder: (context, _) {
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(pulseAnim.value * 0.45),
                      blurRadius: 50,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
              // Orbit ring dots
              Transform.rotate(
                angle: orbitController.value * 2 * math.pi,
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    children: List.generate(8, (i) {
                      final angle = (i / 8) * 2 * math.pi;
                      final left = 90 + 82 * math.cos(angle) - 4;
                      final top = 90 + 82 * math.sin(angle) - 4;
                      return Positioned(
                        left: left,
                        top: top,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLight.withOpacity(
                              i.isEven ? 0.7 : 0.3,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // Inner glass circle
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.12),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.4 + pulseAnim.value * 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: _MiniBoard(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 3x3 mini peg board (center empty)
    const cells = [true, true, true, true, false, true, true, true, true];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemCount: 9,
      itemBuilder: (context, i) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cells[i]
              ? AppColors.primaryColor
              : AppColors.boardHole,
          boxShadow: cells[i]
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _PlayButton({required this.onPressed});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
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
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.primaryColor, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'OYNA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.glassColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primaryLight, size: 17),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
