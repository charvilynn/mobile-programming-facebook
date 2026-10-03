import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

class OnboardingSlide {
  final String emoji;
  final String title;
  final String subtitle;
  const OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

/// Widget 2 (Aaron): Reusable onboarding slide
/// Fixed: visibility guaranteed even when Google Fonts CDN is slow
class OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlide slide;
  const OnboardingSlideWidget({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji in glowing circle — solid border so it's always visible
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgCard,
              border: Border.all(color: AppColors.cyan, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.25),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 54),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            slide.title,
            style: AppTypography.display1.copyWith(height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            slide.subtitle,
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}