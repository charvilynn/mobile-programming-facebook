import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Widget 1 (Aaron): Animated logo for splash screen
/// Animates: scale + glow + fade in
class SplashLogoWidget extends StatefulWidget {
  const SplashLogoWidget({super.key});

  @override
  State<SplashLogoWidget> createState() => _SplashLogoWidgetState();
}

class _SplashLogoWidgetState extends State<SplashLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fadeAnim.value,
        child: Transform.scale(
          scale: _scaleAnim.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo icon with glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgCard,
                  border: Border.all(color: AppColors.cyan, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: 0.3 * _glowAnim.value),
                      blurRadius: 24 * _glowAnim.value,
                      spreadRadius: 4 * _glowAnim.value,
                    ),
                  ],
                ),
                child: Icon(Icons.rocket_launch_rounded,
                    color: AppColors.cyan, size: 36),
              ),
              const SizedBox(height: 20),
              // App name
              Text('PaceBook',
                  style: AppTypography.display1.copyWith(
                    color: AppColors.textPrimary,
                    shadows: [
                      Shadow(
                        color: AppColors.cyan.withValues(alpha: 0.4 * _glowAnim.value),
                        blurRadius: 12,
                      ),
                    ],
                  )),
              const SizedBox(height: 6),
              Text('Your social universe',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.5,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}