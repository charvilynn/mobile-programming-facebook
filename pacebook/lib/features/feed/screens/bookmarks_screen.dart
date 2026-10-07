import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/bookmarks_provider.dart';
import '../widgets/post_card.dart';

// BookmarksScreen
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedPosts = ref.watch(bookmarksProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simpanan',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (bookmarkedPosts.isNotEmpty)
              Text(
                '${bookmarkedPosts.length} postingan tersimpan',
                style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
              ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (bookmarkedPosts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_rounded, color: AppColors.cyan, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${bookmarkedPosts.length}',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: bookmarkedPosts.isEmpty
          ? const _BookmarksEmpty()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: bookmarkedPosts.length,
              itemBuilder: (context, index) {
                final post = bookmarkedPosts[index];
                return PostCard(
                  key: ValueKey('bookmark_${post.id}'),
                  post: post,
                  isCompact: false,
                  onTap: () => context.push('/post/${post.id}'),
                  onCommentTap: () => context.push('/post/${post.id}'),
                );
              },
            ),
    );
  }
}

class _BookmarksEmpty extends StatelessWidget {
  const _BookmarksEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.bookmark_border_rounded,
                  size: 40, color: AppColors.cyan),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Belum ada simpanan',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                'Tekan ikon simpan pada postingan apa pun untuk menyimpannya di sini agar mudah dibaca nanti.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
 // Privacy notice
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      color: AppColors.cyan, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Simpanan bersifat privat — hanya akun Anda yang dapat melihat postingan yang disimpan.',
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.textSecondary),
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
