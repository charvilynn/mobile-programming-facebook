class NotificationTile extends StatelessWidget {
  final String type;
  final String actorName;
  final String? actorAvatar;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final String? actionStatus;
  final bool isActionLoading;

  const NotificationTile({
    super.key,
    required this.type,
    required this.actorName,
    this.actorAvatar,
    required this.text,
    required this.createdAt,
    this.isRead = false,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.actionStatus,
    this.isActionLoading = false,
  });

  IconData get _icon {
    switch (type) {
      case 'like':
      case 'post_reaction':
        return Icons.favorite;
      case 'comment':
      case 'post_comment':
      case 'comment_reply':
        return Icons.chat_bubble;
      case 'connection':
      case 'friend_request':
      case 'connection_request':
      case 'connection_accepted':
        return Icons.person_add;
      case 'message':
      case 'new_message':
        return Icons.message;
      case 'post_tag':
      case 'tag':
        return Icons.label_important_rounded;
      default:
        return Icons.notifications;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'like':
      case 'post_reaction':
        return AppColors.magenta;
      case 'comment':
      case 'post_comment':
      case 'comment_reply':
        return AppColors.cyan;
      case 'connection':
      case 'friend_request':
      case 'connection_request':
      case 'connection_accepted':
        return AppColors.electricBlue;
      case 'post_tag':
      case 'tag':
        return AppColors.cyan;
      default:
        return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'baru';
    if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
    if (diff.inDays < 1) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return '${dt.day}/${dt.month}';
  }

  String get _cleanedText {
    var t = text.trim();
    final trimmedActor = actorName.trim();
    if (trimmedActor.isNotEmpty &&
        t.toLowerCase().startsWith(trimmedActor.toLowerCase())) {
      t = t.substring(trimmedActor.length).trim();
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final isFriendRequest =
        type == 'friend_request' || type == 'connection_request';

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead
            ? Colors.transparent
            : AppColors.cyan.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                  backgroundImage: actorAvatar != null
                      ? NetworkImage(actorAvatar!)
                      : null,
                  child: actorAvatar == null
                      ? Text(
                          actorName.isNotEmpty
                              ? actorName[0].toUpperCase()
                              : '?',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.cyan,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon, size: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: actorName,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' $_cleanedText',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _timeAgo(createdAt),
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),

                  // Friend Request action buttons / feedback
                  if (isFriendRequest) ...[
                    if (actionStatus == 'accepted')
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.cyan,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Permintaan pertemanan diterima',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.cyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (actionStatus == 'rejected')
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          'Permintaan dihapus',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    else if (onAccept != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: isActionLoading ? null : onAccept,
                              icon: isActionLoading
                                  ? SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.bgDeep,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded, size: 15),
                              label: const Text('Konfirmasi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyan,
                                foregroundColor: AppColors.bgDeep,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                minimumSize: const Size(0, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: isActionLoading ? null : onReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: BorderSide(color: AppColors.borderSubtle),
                                backgroundColor: AppColors.bgSurface,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                minimumSize: const Size(0, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: AppTypography.labelSm,
                              ),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
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
