import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/onboarding_slide_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = const [
    OnboardingSlide(
      emoji: '🌌',
      title: 'Selamat Datang\ndi PaceBook',
      subtitle: 'Ruang sosial yang terasa seperti menjelajahi galaksi. Terhubung dengan cara yang berbeda.',
    ),
    OnboardingSlide(
      emoji: '⚡',
      title: 'Bagikan\nMomenmu',
      subtitle: 'Post foto, ekspresi "Vibes", dan ceritakan harimu. Semua tersimpan di Flashback nanti.',
    ),
    OnboardingSlide(
      emoji: '🚀',
      title: 'PaceChat\nRealtime',
      subtitle: 'Chat 1-1 atau grup, typing indicator, dan notifikasi instan. Komunikasi tanpa lag.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => OnboardingSlideWidget(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppColors.cyan : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
            const SizedBox(height: AppSpacing.lg),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: isLastPage
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.go('/register'),
                          child: const Text('Mulai Sekarang'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Sudah punya akun? Masuk'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            'Lewati',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 48),
                          ),
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                          child: const Text('Lanjut'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}