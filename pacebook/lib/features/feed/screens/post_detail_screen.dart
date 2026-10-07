import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_tile.dart';
import '../providers/feed_provider.dart';

// PostDetailScreen
class PostDetailScreen extends ConsumerStatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  int? _replyingToId;
  String? _replyingToName;
  bool _isLoadingComments = true;
  List<CommentModel> _comments = [];
  PostData? _post;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
 // Find post from feed state first (optimistic)
    final feed = ref.read(feedProvider).valueOrNull ?? [];
    final found = feed.where((p) => p.id == widget.postId);
    if (found.isNotEmpty) setState(() => _post = found.first);

 // Load comments (mock for now)
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isLoadingComments = false;
        _comments = _mockComments();
      });
    }
  }

  List<CommentModel> _mockComments() {
    final now = DateTime.now();
    return [
      CommentModel(
        id: 1,
        authorName: 'Livi',
        content: 'Keren banget! UI-nya makin ciamik.',
        createdAt: now.subtract(const Duration(minutes: 30)),
        reactionCount: 5,
        replies: [
          CommentModel(
            id: 2,
            authorName: 'Davvin',
            content: 'Makasih! Ini hasil kolaborasi tim semua.',
            createdAt: now.subtract(const Duration(minutes: 20)),
          ),
        ],
      ),
      CommentModel(
        id: 3,
        authorName: 'Chandra',
        content: 'Modul chat juga sudah siap, tinggal integrasi!',
        createdAt: now.subtract(const Duration(hours: 1)),
        reactionCount: 3,
      ),
    ];
  }

  void _addComment(String text) {
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch,
      authorName: 'Saya',
      content: text,
      createdAt: DateTime.now(),
    );
    setState(() {
      if (_replyingToId != null) {
        _comments = _comments.map((c) {
          if (c.id == _replyingToId) {
            return CommentModel(
              id: c.id,
              authorName: c.authorName,
              content: c.content,
              createdAt: c.createdAt,
              reactionCount: c.reactionCount,
              replies: [...c.replies, newComment],
            );
          }
          return c;
        }).toList();
      } else {
        _comments = [..._comments, newComment];
      }
      _replyingToId = null;
      _replyingToName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20,
              color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Postingan',
            style: AppTypography.labelLg.copyWith(color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _post == null
                ? Center(
                    child: CircularProgressIndicator(
                        color: AppColors.cyan, strokeWidth: 2))
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
 // Post card (full, non-compact)
                      PostCard(
                        post: _post!,
                        isCompact: false,
                        onReact: (_) {},
                        onShareTap: () {},
                      ),
 // Comment count header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md, AppSpacing.md, AppSpacing.md,
                            AppSpacing.sm),
                        child: Text(
                          '${_comments.length} Komentar',
                          style: AppTypography.labelMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
 // Comments list (R-27: loading + empty + data states)
                      if (_isLoadingComments)
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.cyan, strokeWidth: 2),
                          ),
                        )
                      else if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  color: AppColors.textMuted, size: 40),
                              const SizedBox(height: AppSpacing.sm),
                              Text('Belum ada komentar. Jadilah yang pertama!',
                                  style: AppTypography.bodySm
                                      .copyWith(color: AppColors.textMuted),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      else
                        ...List.generate(
                          _comments.length,
                          (i) => CommentTile(
                            comment: _comments[i],
                            depth: 0,
                            onReply: (id) => setState(() {
                              _replyingToId = id;
                              _replyingToName = _comments
                                  .firstWhere((c) => c.id == id)
                                  .authorName;
                            }),
                            onReact: (_) {},
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
          ),
 // Sticky comment input
          CommentInputBar(
            replyingTo: _replyingToName,
            onCancelReply: () => setState(() {
              _replyingToId = null;
              _replyingToName = null;
            }),
            onSend: _addComment,
          ),
        ],
      ),
    );
  }
}
