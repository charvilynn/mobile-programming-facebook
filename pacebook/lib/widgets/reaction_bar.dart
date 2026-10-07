import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import 'post_card.dart';

// ReactionBar
/// Horizontal bar with Like, Comment, Share buttons.
/// Long-press on Like opens ReactionPickerPopup.
/// Purpose: primary action row below each post.
class ReactionBar extends StatefulWidget {
  final PostData post;
  final VoidCallback? onLongPressReact;
  final void Function(String reactionType)? onReact;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const ReactionBar({
    super.key,
    required this.post,
    this.onLongPressReact,
    this.onReact,
    this.onComment,
    this.onShare,
  });

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  String? _myReaction;

  void _handleTap() {
    setState(() {
      _myReaction = _myReaction == null ? 'like' : null;
    });
    widget.onReact?.call(_myReaction ?? 'unlike');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
 // Like / Vibes button
        Expanded(
          child: GestureDetector(
            onLongPress: () {
              _showReactionPicker(context);
            },
            child: _BarButton(
              icon: _myReaction != null
                  ? Icons.favorite
                  : Icons.favorite_border,
              label: _reactionLabel(_myReaction),
              color: _myReaction != null ? AppColors.magenta : AppColors.textMuted,
              onTap: _handleTap,
            ),
          ),
        ),
        _BarButton(
          icon: Icons.chat_bubble_outline,
          label: 'Komentar',
          onTap: widget.onComment ?? () {},
        ),
        _BarButton(
          icon: Icons.share_outlined,
          label: 'Bagikan',
          onTap: widget.onShare ?? () {},
        ),
      ],
    );
  }

  String _reactionLabel(String? r) {
    const map = {
      'like': 'Suka',
      'love': 'Cinta',
      'haha': 'Haha',
      'wow': 'Wow',
      'sad': 'Sedih',
      'angry': 'Marah',
    };
    return r != null ? (map[r] ?? 'Vibes') : 'Vibes';
  }

  void _showReactionPicker(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => ReactionPickerPopup(
        onSelect: (type) {
          setState(() => _myReaction = type);
          widget.onReact?.call(type);
        },
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _BarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm + 2, horizontal: AppSpacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: effectiveColor),
            const SizedBox(width: 4),
            Text(label,
                style: AppTypography.labelSm.copyWith(
                    color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ReactionPickerPopup
/// Floating popup with 6 reaction emojis.
/// Purpose: mimics Facebook reactions — long-press to choose feeling.
class ReactionPickerPopup extends StatelessWidget {
  final void Function(String type) onSelect;
  const ReactionPickerPopup({super.key, required this.onSelect});

  static const _reactions = [
    ('👍', 'like', 'Suka'),
    ('❤️', 'love', 'Cinta'),
    ('😄', 'haha', 'Haha'),
    ('😮', 'wow', 'Wow'),
    ('😢', 'sad', 'Sedih'),
    ('😠', 'angry', 'Marah'),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _reactions.map((r) {
                  final (emoji, type, label) = r;
                  return _ReactionItem(
                    emoji: emoji,
                    label: label,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelect(type);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionItem extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _ReactionItem({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ReactionItem> createState() => _ReactionItemState();
}

class _ReactionItemState extends State<_ReactionItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween(begin: 1.0, end: 1.35).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 2),
            Text(widget.label,
                style: AppTypography.labelSm
                    .copyWith(color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
