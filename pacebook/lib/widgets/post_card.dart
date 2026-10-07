import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import 'reaction_bar.dart';

import '../providers/bookmarks_provider.dart';

// Model
class PostAuthor {
  final int id;
  final String name;
  final String? avatarUrl;
  const PostAuthor({required this.id, required this.name, this.avatarUrl});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_url': avatarUrl,
      };

  factory PostAuthor.fromJson(Map<String, dynamic> json) => PostAuthor(
        id: json['id'] as int? ?? 0,
        name: (json['name'] ?? json['full_name'] ?? 'Pengguna').toString(),
        avatarUrl: json['avatar_url'] as String?,
      );
}

class PostData {
  final int id;
  final PostAuthor author;
  final String content;
  final List<String> mediaUrls;
  final List<String> taggedUserNames;
  final String visibility;
  final int reactionCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final String? feeling;
  final bool isEdited;
  final bool isBookmarked;

  const PostData({
    required this.id,
    required this.author,
    required this.content,
    required this.mediaUrls,
    this.taggedUserNames = const [],
    required this.visibility,
    required this.reactionCount,
    required this.commentCount,
    required this.shareCount,
    required this.createdAt,
    this.feeling,
    this.isEdited = false,
    this.isBookmarked = false,
  });

  PostData copyWith({
    int? id,
    PostAuthor? author,
    String? content,
    List<String>? mediaUrls,
    List<String>? taggedUserNames,
    String? visibility,
    int? reactionCount,
    int? commentCount,
    int? shareCount,
    DateTime? createdAt,
    String? feeling,
    bool? isEdited,
    bool? isBookmarked,
  }) {
    return PostData(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      taggedUserNames: taggedUserNames ?? this.taggedUserNames,
      visibility: visibility ?? this.visibility,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      feeling: feeling ?? this.feeling,
      isEdited: isEdited ?? this.isEdited,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.toJson(),
        'content': content,
        'media_urls': mediaUrls,
        'tagged_user_names': taggedUserNames,
        'visibility': visibility,
        'reaction_count': reactionCount,
        'comment_count': commentCount,
        'share_count': shareCount,
        'created_at': createdAt.toIso8601String(),
        'feeling': feeling,
        'is_edited': isEdited,
        'is_bookmarked': isBookmarked,
      };

  factory PostData.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final dateRaw = json['created_at'] ?? json['createdAt'];
      parsedDate = dateRaw != null ? DateTime.parse(dateRaw.toString()) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

 // Safely parse media_urls whether it's List or JSON String or String
    final rawMedia = json['media_urls'] ?? json['mediaUrls'] ?? [];
    List<String> mediaList = [];
    if (rawMedia is List) {
      mediaList = rawMedia.map((e) => e.toString()).toList();
    } else if (rawMedia is String) {
      try {
        final decoded = jsonDecode(rawMedia);
        if (decoded is List) {
          mediaList = decoded.map((e) => e.toString()).toList();
        } else if (rawMedia.trim().isNotEmpty) {
          mediaList = [rawMedia.trim()];
        }
      } catch (_) {
        if (rawMedia.trim().isNotEmpty) {
          mediaList = [rawMedia.trim()];
        }
      }
    }

 // Safely parse tagged_users
    final rawTagged = json['tagged_users'] ?? json['taggedUsers'] ?? [];
    List<String> taggedNames = [];
    if (rawTagged is List) {
      for (final item in rawTagged) {
        if (item is Map) {
          final n = (item['full_name'] ?? item['name'] ?? item['username'] ?? '').toString();
          if (n.isNotEmpty) taggedNames.add(n);
        } else if (item != null) {
          final s = item.toString().trim();
          if (s.isNotEmpty) taggedNames.add(s);
        }
      }
    } else if (rawTagged is String && rawTagged.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTagged);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              final n = (item['full_name'] ?? item['name'] ?? item['username'] ?? '').toString();
              if (n.isNotEmpty) taggedNames.add(n);
            }
          }
        }
      } catch (_) {}
    }

    String rawContent = (json['content'] ?? json['contentText'] ?? '').toString();
 // Guard against raw base64 image data appearing in content text:
 // If content looks like base64 image data, transfer it to mediaList and clear rawContent
    final isBase64Img = rawContent.length > 80 &&
        !rawContent.contains(' ') &&
        (rawContent.startsWith('data:image') ||
         rawContent.startsWith('/9j/') ||
         rawContent.startsWith('iVBOR') ||
         rawContent.startsWith('AAt4') ||
         rawContent.startsWith('AAAA'));
    if (isBase64Img) {
      final imgUrl = rawContent.startsWith('data:image')
          ? rawContent
          : 'data:image/jpeg;base64,$rawContent';
      if (!mediaList.contains(imgUrl)) {
        mediaList.insert(0, imgUrl);
      }
      rawContent = '';
    }

    return PostData(
      id: json['id'] as int? ?? 0,
      author: json['author'] != null && json['author'] is Map
          ? PostAuthor.fromJson(Map<String, dynamic>.from(json['author'] as Map))
          : const PostAuthor(id: 0, name: 'Pengguna'),
      content: rawContent,
      mediaUrls: mediaList,
      taggedUserNames: taggedNames,
      visibility: (json['visibility'] ?? json['privacy'] ?? 'public').toString(),
      reactionCount: json['reaction_count'] as int? ?? json['reactionCount'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? json['commentCount'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? json['shareCount'] as int? ?? 0,
      createdAt: parsedDate,
      feeling: json['feeling'] as String?,
      isEdited: json['is_edited'] as bool? ?? json['isEdited'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }
}

// PostCard
/// Full post card with author header, content, media grid,
/// and action bar. Purpose: the primary unit of the feed.
class PostCard extends ConsumerWidget {
  final PostData post;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;
  final void Function(String reactionType)? onReact;
  final bool isCompact;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLongPress,
    this.onCommentTap,
    this.onShareTap,
    this.onReact,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
 // Author Header
            _PostAuthorHeader(post: post),
 // Content
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Text(
                  post.content,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.55,
                  ),
                  maxLines: isCompact ? 4 : null,
                  overflow: isCompact ? TextOverflow.ellipsis : null,
                ),
              ),
 // Media Grid
            if (post.mediaUrls.isNotEmpty)
              PostMediaGrid(mediaUrls: post.mediaUrls),
 // Stats Row
            if (post.reactionCount > 0 || post.commentCount > 0)
              _PostStatsRow(post: post),
 // Divider
            Divider(color: AppColors.borderSubtle, height: 1),
 // Reaction Bar
            ReactionBar(
              post: post,
              onLongPressReact: onLongPress,
              onReact: onReact,
              onComment: onCommentTap,
              onShare: onShareTap,
            ),
          ],
        ),
      ),
    );
  }
}

// Author Header sub-widget
class _PostAuthorHeader extends ConsumerWidget {
  final PostData post;
  const _PostAuthorHeader({required this.post});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
    if (diff.inDays < 1) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarksProvider).any((p) => p.id == post.id);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
 // Avatar
          _UserAvatar(
            name: post.author.name,
            avatarUrl: post.author.avatarUrl,
            radius: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
 // Name + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(post.author.name,
                        style: AppTypography.labelMd.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    if (post.taggedUserNames.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        'bersama ${post.taggedUserNames.join(", ")}',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (post.feeling != null) ...[
                      const SizedBox(width: 4),
                      Text('merasa ${post.feeling}',
                          style: AppTypography.labelSm
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(_timeAgo(post.createdAt),
                        style: AppTypography.labelSm
                            .copyWith(color: AppColors.textMuted)),
                    if (post.isEdited) ...[
                      const SizedBox(width: 4),
                      Text('· diedit',
                          style: AppTypography.labelSm
                              .copyWith(color: AppColors.textMuted)),
                    ],
                    const SizedBox(width: 4),
                    Icon(_visibilityIcon(post.visibility),
                        size: 12, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
 // Bookmark + Options
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                key: ValueKey<bool>(isBookmarked),
                color: isBookmarked
                    ? AppColors.cyan
                    : AppColors.textMuted,
                size: 22,
              ),
            ),
            onPressed: () {
              final added = ref.read(bookmarksProvider.notifier).toggleBookmark(post);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        added ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
                        color: added ? AppColors.cyan : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        added
                            ? 'Postingan disimpan ke Simpanan'
                            : 'Dihapus dari Simpanan',
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.bgCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.borderSubtle),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            tooltip: isBookmarked ? 'Hapus dari simpanan' : 'Simpan postingan',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.more_horiz, color: AppColors.textMuted),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  IconData _visibilityIcon(String v) {
    switch (v) {
      case 'connections': return Icons.people_outline;
      case 'private': return Icons.lock_outline;
      default: return Icons.public;
    }
  }
}

// Stats Row sub-widget
class _PostStatsRow extends StatelessWidget {
  final PostData post;
  const _PostStatsRow({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (post.reactionCount > 0)
            Text('${post.reactionCount} ekspresi',
                style: AppTypography.labelSm
                    .copyWith(color: AppColors.textMuted)),
          const Spacer(),
          if (post.commentCount > 0)
            Text('${post.commentCount} komentar',
                style: AppTypography.labelSm
                    .copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// Smart Image Helpers (Handles Network + Base64 Memory Images)
Widget _buildSmartImage(String url, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return _errorContainer(width: width, height: height);

  if (trimmed.startsWith('data:image') || trimmed.startsWith('data:')) {
    try {
      final base64Str = trimmed.contains(',') ? trimmed.split(',').last : trimmed;
      return Image.memory(
        base64Decode(base64Str),
        fit: fit,
        width: width ?? double.infinity,
        height: height,
        errorBuilder: (_, __, ___) => _errorContainer(width: width, height: height),
      );
    } catch (_) {}
 } else if (!trimmed.startsWith('http://') &&
 !trimmed.startsWith('https://') &&
      !trimmed.startsWith('blob:') &&
      trimmed.length > 100) {
    try {
      return Image.memory(
        base64Decode(trimmed),
        fit: fit,
        width: width ?? double.infinity,
        height: height,
        errorBuilder: (_, __, ___) => _errorContainer(width: width, height: height),
      );
    } catch (_) {}
  }

  return Image.network(
    trimmed,
    fit: fit,
    width: width ?? double.infinity,
    height: height,
    errorBuilder: (_, __, ___) => _errorContainer(width: width, height: height),
  );
}

Widget _errorContainer({double? width, double? height}) => Container(
  width: width,
  height: height,
  color: AppColors.bgSurface,
  child: Center(
    child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
  ),
);

// UserAvatar (reusable)
/// Reusable avatar widget: supports network images, base64 data URIs, or initials.
class _UserAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double radius;

  const _UserAvatar({required this.name, this.avatarUrl, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      final trimmed = avatarUrl!.trim();
      if (trimmed.startsWith('data:image') || trimmed.startsWith('data:')) {
        try {
          final base64Str = trimmed.contains(',') ? trimmed.split(',').last : trimmed;
          imageProvider = MemoryImage(base64Decode(base64Str));
        } catch (_) {}
 } else if (!trimmed.startsWith('http://') &&
 !trimmed.startsWith('https://') &&
          !trimmed.startsWith('blob:') &&
          trimmed.length > 100) {
        try {
          imageProvider = MemoryImage(base64Decode(trimmed));
        } catch (_) {}
      } else {
        imageProvider = NetworkImage(trimmed);
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}

// PostMediaGrid
/// Adaptive media grid with smart memory + network support.
class PostMediaGrid extends StatelessWidget {
  final List<String> mediaUrls;
  const PostMediaGrid({super.key, required this.mediaUrls});

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) return const SizedBox.shrink();
    final count = mediaUrls.length;

    if (count == 1) {
      return _MediaItem(url: mediaUrls[0], height: 240);
    }
    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _MediaItem(url: mediaUrls[0], height: 200)),
          const SizedBox(width: 2),
          Expanded(child: _MediaItem(url: mediaUrls[1], height: 200)),
        ],
      );
    }
    if (count == 3) {
      return Row(
        children: [
          Expanded(flex: 2, child: _MediaItem(url: mediaUrls[0], height: 200)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                _MediaItem(url: mediaUrls[1], height: 99),
                const SizedBox(height: 2),
                _MediaItem(url: mediaUrls[2], height: 99),
              ],
            ),
          ),
        ],
      );
    }
 // 4+
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _MediaItem(url: mediaUrls[0], height: 120),
              const SizedBox(width: 2),
              _MediaItem(url: mediaUrls[2], height: 120),
            ],
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            children: [
              _MediaItem(url: mediaUrls[1], height: 120),
              const SizedBox(height: 2),
              _MediaItemWithOverlay(
                url: mediaUrls[3],
                height: 120,
                extraCount: count > 4 ? count - 4 : 0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MediaItem extends StatelessWidget {
  final String url;
  final double height;
  const _MediaItem({required this.url, required this.height});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: _buildSmartImage(url),
      );
}

class _MediaItemWithOverlay extends StatelessWidget {
  final String url;
  final double height;
  final int extraCount;
  const _MediaItemWithOverlay(
      {required this.url, required this.height, required this.extraCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildSmartImage(url),
          if (extraCount > 0)
            Container(
              color: Colors.black54,
              child: Center(
                child: Text('+$extraCount',
                    style: AppTypography.h2.copyWith(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
