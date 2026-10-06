class StoryBar extends ConsumerWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);

    return SizedBox(
      height: 195,
      child: storiesAsync.when(
        loading: () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 4),
          children: const [
            _AddStoryTile(),
            SizedBox(width: AppSpacing.sm),
            _StoryShimmer(),
          ],
        ),
        error: (_, __) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 4),
          children: const [
            _AddStoryTile(),
            SizedBox(width: AppSpacing.sm),
            _EmptyStoriesHint(),
          ],
        ),
        data: (groups) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 4),
            itemCount: 1 + groups.length + (groups.isEmpty ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (ctx, index) {
              if (index == 0) {
                return const _AddStoryTile();
              }
              if (groups.isEmpty && index == 1) {
                return const _EmptyStoriesHint();
              }
              final group = groups[index - 1];
              return _StoryGroupTile(
                group: group,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StoryViewerScreen(storyGroup: group),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Add Story Tile ───────────────────────────────────────────────────────────
class _AddStoryTile extends ConsumerWidget {
  const _AddStoryTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider(null)).valueOrNull;

    return GestureDetector(
      onTap: () => showCreateStorySheet(context, ref),
      child: Container(
        width: 115,
        height: 185,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 56,
              child: profile?.avatarUrl != null &&
                      profile!.avatarUrl!.isNotEmpty
                  ? buildSmartImage(
                      profile.avatarUrl,
                      fit: BoxFit.cover,
                      errorWidget: _buildDefaultAddBg(profile.name),
                    )
                  : _buildDefaultAddBg(profile?.name),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 56,
              child: Container(
                color: AppColors.bgSurface,
                padding: const EdgeInsets.only(top: 18, left: 6, right: 6),
                alignment: Alignment.center,
                child: Text(
                  'Buat Cerita',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              bottom: 38,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgSurface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, color: AppColors.bgDeep, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAddBg(String? name) {
    return Container(
      color: AppColors.cyan.withValues(alpha: 0.15),
      child: Center(
        child: Icon(Icons.person,
            size: 48, color: AppColors.cyan.withValues(alpha: 0.6)),
      ),
    );
  }
}

// ─── Story Group Tile ─────────────────────────────────────────────────────────
class _StoryGroupTile extends StatelessWidget {
  final StoryGroup group;
  final VoidCallback onTap;

  const _StoryGroupTile({
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarProvider = getSmartImageProvider(group.avatarUrl);
    final firstItem = group.items.isNotEmpty ? group.items.first : null;
    final hasImage =
        firstItem?.mediaUrl != null && firstItem!.mediaUrl!.isNotEmpty;
    final hasText =
        firstItem?.textContent != null && firstItem!.textContent!.isNotEmpty;
    final bgColor = _parseColor(firstItem?.bgColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 115,
        height: 185,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: group.isOwn
                ? AppColors.cyan
                : (group.hasUnseen ? AppColors.cyan : AppColors.borderSubtle),
            width: group.hasUnseen ? 2 : 1,
          ),
          boxShadow: [
            if (group.hasUnseen)
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.25),
                blurRadius: 8,
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              buildSmartImage(
                firstItem!.mediaUrl,
                fit: BoxFit.cover,
                errorWidget: Container(color: AppColors.bgCard),
              )
            else if (hasText)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0.7),
                      const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 36),
                alignment: Alignment.center,
                child: Text(
                  firstItem!.textContent ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColors.cyan,
                      AppColors.magenta,
                      AppColors.cyan,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.bgSurface,
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? Text(
                          group.authorName.isNotEmpty
                              ? group.authorName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                group.isOwn ? 'Cerita Anda' : group.authorName,
                style: TextStyle(
                  color: group.isOwn ? AppColors.cyan : Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}