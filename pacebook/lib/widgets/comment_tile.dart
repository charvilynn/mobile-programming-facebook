import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

// CommentModel
class CommentModel {
  final int id;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final List<CommentModel> replies;
  final int reactionCount;

  const CommentModel({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.replies = const [],
    this.reactionCount = 0,
  });
}

// CommentTile
/// Comment tile with support for nested replies.
/// Replies are indented with a left border accent.
/// Purpose: display threaded conversation below a post.
class CommentTile extends StatefulWidget {
  final CommentModel comment;
 final int depth; // 0 = top-level, 1 = reply
  final void Function(int commentId)? onReply;
  final void Function(int commentId)? onReact;

  const CommentTile({
    super.key,
    required this.comment,
    this.depth = 0,
    this.onReply,
    this.onReact,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _showReplies = false;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'baru';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}j';
    return '${diff.inDays}h';
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final isReply = widget.depth > 0;

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? AppSpacing.xl : AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
 // Left accent bar for replies
            if (isReply)
              Container(
                width: 2,
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                color: AppColors.cyan.withValues(alpha: 0.35),
              ),
 // Avatar
            CircleAvatar(
              radius: isReply ? 14 : 18,
              backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
              backgroundImage: comment.authorAvatar != null
                  ? NetworkImage(comment.authorAvatar!)
                  : null,
              child: comment.authorAvatar == null
                  ? Text(
                      comment.authorName.isNotEmpty
                          ? comment.authorName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: AppColors.cyan,
                          fontSize: isReply ? 10 : 13,
                          fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
 // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
 // Bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment.authorName,
                            style: AppTypography.labelSm.copyWith(
                                color: AppColors.cyan,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(comment.content,
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
 // Action row
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppSpacing.xs, top: AppSpacing.xs),
                    child: Row(
                      children: [
                        Text(_timeAgo(comment.createdAt),
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.textMuted)),
                        const SizedBox(width: AppSpacing.sm),
                        _CommentAction(
                          label: comment.reactionCount > 0
                              ? 'Suka (${comment.reactionCount})'
                              : 'Suka',
                          onTap: () => widget.onReact?.call(comment.id),
                        ),
                        if (widget.depth == 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _CommentAction(
                            label: 'Balas',
                            onTap: () => widget.onReply?.call(comment.id),
                          ),
                        ],
                      ],
                    ),
                  ),
 // Replies toggle
                  if (comment.replies.isNotEmpty && widget.depth == 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showReplies = !_showReplies),
                      child: Row(
                        children: [
                          Icon(
                            _showReplies
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.cyan,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _showReplies
                                ? 'Sembunyikan balasan'
                                : '${comment.replies.length} balasan',
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.cyan),
                          ),
                        ],
                      ),
                    ),
                    if (_showReplies)
                      ...comment.replies.map((r) => CommentTile(
                            comment: r,
                            depth: 1,
                            onReact: widget.onReact,
                          )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CommentAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Text(label,
            style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600)),
      );
}

// CommentInputBar
/// Sticky input bar at bottom of post detail screen.
/// Purpose: compose and send a comment or reply.
class CommentInputBar extends StatefulWidget {
  final String? replyingTo;
  final VoidCallback? onCancelReply;
  final void Function(String text) onSend;

  const CommentInputBar({
    super.key,
    this.replyingTo,
    this.onCancelReply,
    required this.onSend,
  });

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _ctrl.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
 // Replying-to banner
          if (widget.replyingTo != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 4),
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Membalas ${widget.replyingTo}',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.cyan),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onCancelReply,
                    child: Icon(Icons.close,
                        size: 14, color: AppColors.cyan),
                  ),
                ],
              ),
            ),
 // Input row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) =>
                      setState(() => _hasText = v.trim().isNotEmpty),
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.textPrimary),
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: widget.replyingTo != null
                        ? 'Tulis balasan...'
                        : 'Tulis komentar...',
                    hintStyle: AppTypography.bodySm
                        .copyWith(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.bgSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedOpacity(
                opacity: _hasText ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _hasText ? _send : null,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _hasText ? AppColors.cyan : AppColors.bgSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: _hasText
                          ? AppColors.bgDeep
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
