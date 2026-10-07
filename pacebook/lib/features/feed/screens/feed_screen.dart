import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_create_widgets.dart';
import '../widgets/story_bar.dart';

// FeedScreen
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
 // Load initial posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).loadFeed();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: RefreshIndicator(
        color: AppColors.cyan,
        backgroundColor: AppColors.bgCard,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
 // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.bgDeep,
              surfaceTintColor: Colors.transparent,
              title: Row(
                children: [
 // Logo mark
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.cyan, AppColors.magenta],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('P',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('PaceBook',
                      style: AppTypography.h3.copyWith(
                          color: AppColors.textPrimary)),
                ],
              ),
              actions: [
 // (+) Create Dropdown Menu (Post, Story, Note)
                PopupMenuButton<String>(
                  tooltip: 'Buat Baru',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Icon(Icons.add,
                        size: 20, color: AppColors.textPrimary),
                  ),
                  color: AppColors.bgCard,
                  surfaceTintColor: Colors.transparent,
                  elevation: 12,
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.borderSubtle, width: 1),
                  ),
                  onSelected: (value) {
                    if (value == 'post') {
                      context.push('/feed/create');
                    } else if (value == 'story') {
                      showCreateStorySheet(context);
                    } else if (value == 'note') {
                      context.push('/notes/create');
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem<String>(
                      value: 'post',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.edit_note_rounded,
                                color: AppColors.cyan, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Post',
                                  style: AppTypography.labelMd.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              Text('Bagikan cerita ke beranda',
                                  style: AppTypography.labelSm
                                      .copyWith(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem<String>(
                      value: 'story',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.magenta.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_circle_outline_rounded,
                                color: AppColors.magenta, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Story',
                                  style: AppTypography.labelMd.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              Text('Foto atau teks 24 jam',
                                  style: AppTypography.labelSm
                                      .copyWith(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem<String>(
                      value: 'note',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.chat_bubble_outline_rounded,
                                color: AppColors.cyan, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Note',
                                  style: AppTypography.labelMd.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              Text('Status pemikiran singkat',
                                  style: AppTypography.labelSm
                                      .copyWith(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.search,
                      color: AppColors.textSecondary),
                  onPressed: () => context.push('/search'),
                  tooltip: 'Cari',
                ),
                IconButton(
                  icon: Icon(Icons.notifications_outlined,
                      color: AppColors.textSecondary),
                  onPressed: () => context.push('/notifications'),
                  tooltip: 'Notifikasi',
                ),
              ],
            ),

 // Create Post Button
            SliverToBoxAdapter(child: _CreatePostCard()),

 // Story Bar
            const SliverToBoxAdapter(child: StoryBar()),

 // Feed Content
            feedState.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: _FeedLoading()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: _FeedError(
                    error: err.toString(),
                    onRetry: () =>
                        ref.read(feedProvider.notifier).loadFeed()),
              ),
              data: (posts) {
                if (posts.isEmpty) {
                  return const SliverFillRemaining(child: _FeedEmpty());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i < posts.length) {
                        return PostCard(
                          post: posts[i],
                          isCompact: true,
                          onTap: () =>
                              context.push('/post/${posts[i].id}'),
                          onCommentTap: () =>
                              context.push('/post/${posts[i].id}'),
                          onShareTap: () => _onShare(ctx, posts[i]),
                        );
                      }
 // Load-more indicator
                      return Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(
                          child: SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: posts.length + 1,
                  ),
                );
              },
            ),
          ],
        ),
      ),

 // FAB: Create Post
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-post'),
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.bgDeep,
        icon: const Icon(Icons.add, size: 20),
        label: Text('Buat Post',
            style: AppTypography.labelMd.copyWith(
                color: AppColors.bgDeep, fontWeight: FontWeight.w600)),
        elevation: 4,
      ),
    );
  }

  void _onShare(BuildContext context, PostData post) {
    ShareBottomSheet.show(
      context,
      onShareToFeed: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Postingan dibagikan ke beranda.',
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.textPrimary)),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      ),
      onCopyLink: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tautan disalin.',
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.textPrimary)),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
  }
}

// Create Post Card
class _CreatePostCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/create-post'),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
              child: Icon(Icons.person_outline,
                  color: AppColors.cyan, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text('Apa yang sedang kamu pikirkan?',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.textMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// State Widgets (R-27: all states covered)
class _FeedLoading extends StatelessWidget {
  const _FeedLoading();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: AppColors.cyan),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Memuat beranda...',
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.textMuted)),
        ],
      );
}

class _FeedEmpty extends StatelessWidget {
  const _FeedEmpty();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.12),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.auto_awesome_outlined,
                  size: 38, color: AppColors.cyan),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Belum ada postingan',
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
                'Jadilah yang pertama membuat postingan untuk memulai percakapan di PaceBook!',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => context.push('/feed/create'),
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text('Buat Postingan Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: AppColors.bgDeep,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}

class _FeedError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _FeedError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 56, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('Gagal memuat beranda',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(error,
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
                maxLines: 2),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: AppColors.bgDeep,
              ),
            ),
          ],
        ),
      );
}
