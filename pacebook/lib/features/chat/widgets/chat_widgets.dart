import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

// ChatMessage model
class ChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final String? text;
  final String? mediaUrl;
  final bool isRead;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.text,
    this.mediaUrl,
    this.isRead = false,
    required this.sentAt,
  });
}

class ChatRoom {
  final int id;
  final bool isGroup;
  final String? groupName;
  final String? groupAvatar;
  final List<ChatParticipant> participants;
  final ChatMessage? lastMessage;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.isGroup,
    this.groupName,
    this.groupAvatar,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
  });
}

class ChatParticipant {
  final int id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;

  const ChatParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
  });
}

// ChatListTile
/// Chat list item — avatar, name, preview, timestamp, badge.
/// Purpose: primary entry point into a conversation from the chat list.
class ChatListTile extends StatelessWidget {
  final ChatRoom room;
  final int myUserId;
  final VoidCallback? onTap;

  const ChatListTile({
    super.key,
    required this.room,
    required this.myUserId,
    this.onTap,
  });

  String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final other = room.participants.firstWhere(
      (p) => p.id != myUserId,
      orElse: () => const ChatParticipant(id: 0, name: 'Grup'),
    );
    final name = room.isGroup ? (room.groupName ?? 'Grup Chat') : other.name;
    final hasUnread = room.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        child: Row(
          children: [
 // Avatar with online dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                  backgroundImage: room.isGroup && room.groupAvatar != null
                      ? NetworkImage(room.groupAvatar!)
                      : (!room.isGroup && other.avatarUrl != null
                          ? NetworkImage(other.avatarUrl!)
                          : null),
                  child: (room.isGroup && room.groupAvatar == null) ||
                          (!room.isGroup && other.avatarUrl == null)
                      ? Text(name[0].toUpperCase(),
                          style: AppTypography.labelLg
                              .copyWith(color: AppColors.cyan))
                      : null,
                ),
                if (!room.isGroup && other.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: OnlineStatusDot(isOnline: true),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
 // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTypography.labelMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    room.lastMessage?.text ?? 'Mulai percakapan...',
                    style: AppTypography.labelSm.copyWith(
                        color: hasUnread
                            ? AppColors.textSecondary
                            : AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
 // Time + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (room.lastMessage != null)
                  Text(_timeLabel(room.lastMessage!.sentAt),
                      style: AppTypography.labelSm.copyWith(
                          color: hasUnread ? AppColors.cyan : AppColors.textMuted,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400)),
                const SizedBox(height: 4),
                UnreadBadgeCounter(count: room.unreadCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ChatBubble
/// Chat message bubble — sent (right) vs received (left).
/// Includes text, optional media, timestamp, read receipt for sent.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool showAvatar;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showAvatar = true,
  });

  String _timeLabel(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 60 : AppSpacing.md,
        right: isMine ? AppSpacing.md : 60,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
 // Avatar (received only)
          if (!isMine && showAvatar) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
              backgroundImage: message.senderAvatar != null
                  ? NetworkImage(message.senderAvatar!)
                  : null,
              child: message.senderAvatar == null
                  ? Text(message.senderName[0].toUpperCase(),
                      style: TextStyle(
                          fontSize: 10, color: AppColors.cyan))
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
          ] else if (!isMine)
            const SizedBox(width: 32),
 // Bubble
          Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
 // Media preview
              if (message.mediaUrl != null)
                MessageMediaPreview(url: message.mediaUrl!, isMine: isMine),
 // Text bubble
              if (message.text != null && message.text!.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isMine
                        ? AppColors.cyan.withValues(alpha: 0.85)
                        : AppColors.bgSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMine ? 16 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text!,
                    style: AppTypography.bodyMd.copyWith(
                        color: isMine ? AppColors.bgDeep : AppColors.textPrimary),
                  ),
                ),
 // Timestamp + read receipt
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_timeLabel(message.sentAt),
                      style: AppTypography.labelSm.copyWith(
                          color: AppColors.textMuted, fontSize: 10)),
                  if (isMine) ...[
                    const SizedBox(width: 3),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: message.isRead ? AppColors.cyan : AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ChatInputBar
/// Message input field with send and attach buttons.
class ChatInputBar extends StatefulWidget {
  final void Function(String text) onSend;
  final VoidCallback? onAttach;

  const ChatInputBar({super.key, required this.onSend, this.onAttach});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
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
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file_outlined,
                color: AppColors.textMuted, size: 22),
            onPressed: widget.onAttach,
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: (v) =>
                  setState(() => _hasText = v.trim().isNotEmpty),
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.textPrimary),
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                hintStyle:
                    AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: _hasText ? _send : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _hasText ? AppColors.cyan : AppColors.bgSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded,
                  size: 20,
                  color: _hasText ? AppColors.bgDeep : AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// TypingIndicatorWidget
/// Animated 3-dot typing indicator.
class TypingIndicatorWidget extends StatefulWidget {
  final String typingName;
  const TypingIndicatorWidget({super.key, required this.typingName});

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final offset = ((_ctrl.value * 3 - i) % 1.0).clamp(0.0, 1.0);
                    final dy = offset < 0.5 ? offset * 2 : (1.0 - offset) * 2;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      transform:
                          Matrix4.translationValues(0, -dy * 4, 0),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.6 + dy * 0.4),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text('${widget.typingName} sedang mengetik...',
              style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// OnlineStatusDot
/// Green dot for online, grey for offline.
class OnlineStatusDot extends StatelessWidget {
  final bool isOnline;
  final double size;
  const OnlineStatusDot({super.key, required this.isOnline, this.size = 10});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isOnline ? AppColors.success : AppColors.textMuted,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.bgCard, width: 1.5),
        ),
      );
}

// GroupMemberAvatarStack
/// Stacked member avatars for group chat header.
class GroupMemberAvatarStack extends StatelessWidget {
  final List<ChatParticipant> members;
  final double radius;

  const GroupMemberAvatarStack({
    super.key,
    required this.members,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    const maxShow = 3;
    final showing = members.take(maxShow).toList();
    final extra = members.length - maxShow;

    return SizedBox(
      width: showing.length * (radius * 1.4) + (extra > 0 ? radius * 1.4 : 0),
      height: radius * 2,
      child: Stack(
        children: [
          ...List.generate(showing.length, (i) => Positioned(
                left: i * (radius * 1.4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgCard, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: radius,
                    backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                    backgroundImage: showing[i].avatarUrl != null
                        ? NetworkImage(showing[i].avatarUrl!)
                        : null,
                    child: showing[i].avatarUrl == null
                        ? Text(showing[i].name[0].toUpperCase(),
                            style: TextStyle(
                                fontSize: radius * 0.75,
                                color: AppColors.cyan))
                        : null,
                  ),
                ),
              )),
          if (extra > 0)
            Positioned(
              left: showing.length * (radius * 1.4),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgCard, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: AppColors.bgSurface,
                  child: Text('+$extra',
                      style: TextStyle(
                          fontSize: radius * 0.65,
                          color: AppColors.textSecondary)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// NotificationTile
/// Notification item with actor avatar, text, type icon.
class NotificationTile extends StatelessWidget {
 final String type; // 'like' | 'comment' | 'connection' | 'friend_request' | 'message'
  final String actorName;
  final String? actorAvatar;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
 final String? actionStatus; // 'accepted' | 'rejected'
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
      case 'post_reaction': return Icons.favorite;
      case 'comment':
      case 'post_comment':
      case 'comment_reply': return Icons.chat_bubble;
      case 'connection':
      case 'friend_request':
      case 'connection_request':
      case 'connection_accepted': return Icons.person_add;
      case 'message':
      case 'new_message': return Icons.message;
      case 'post_tag':
      case 'tag': return Icons.label_important_rounded;
      default: return Icons.notifications;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'like':
      case 'post_reaction': return AppColors.magenta;
      case 'comment':
      case 'post_comment':
      case 'comment_reply': return AppColors.cyan;
      case 'connection':
      case 'friend_request':
      case 'connection_request':
      case 'connection_accepted': return AppColors.electricBlue;
      case 'post_tag':
      case 'tag': return AppColors.cyan;
      default: return AppColors.textSecondary;
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
    if (trimmedActor.isNotEmpty && t.toLowerCase().startsWith(trimmedActor.toLowerCase())) {
      t = t.substring(trimmedActor.length).trim();
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final isFriendRequest = type == 'friend_request' || type == 'connection_request';

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? Colors.transparent : AppColors.cyan.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                  backgroundImage:
                      actorAvatar != null ? NetworkImage(actorAvatar!) : null,
                  child: actorAvatar == null
                      ? Text(
                          actorName.isNotEmpty ? actorName[0].toUpperCase() : '?',
                          style: AppTypography.labelMd
                              .copyWith(color: AppColors.cyan))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: _iconColor, shape: BoxShape.circle),
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
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: ' $_cleanedText',
                          style: AppTypography.bodyMd
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(_timeAgo(createdAt),
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.textMuted)),

 // Friend Request action buttons / feedback
                  if (isFriendRequest) ...[
                    if (actionStatus == 'accepted')
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: AppColors.cyan),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          'Permintaan dihapus',
                          style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                minimumSize: const Size(0, 32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                textStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: isActionLoading ? null : onReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: BorderSide(color: AppColors.borderSubtle),
                                backgroundColor: AppColors.bgSurface,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                minimumSize: const Size(0, 32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            if (!isRead && actionStatus == null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                    color: AppColors.cyan, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

// MessageMediaPreview
/// Image thumbnail in a chat bubble.
class MessageMediaPreview extends StatelessWidget {
  final String url;
  final bool isMine;
  const MessageMediaPreview({super.key, required this.url, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 200,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 200,
          height: 100,
          color: AppColors.bgSurface,
          child: Icon(Icons.broken_image_outlined,
              color: AppColors.textMuted),
        ),
      ),
    );
  }
}

// ChatDateSeparator
/// Date separator line between message groups.
class ChatDateSeparator extends StatelessWidget {
 final String label; // e.g. "Hari ini", "Kemarin", "27 Sep 2024"
  const ChatDateSeparator({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.xl),
        child: Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderSubtle, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(label,
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.textMuted)),
              ),
            ),
            Expanded(child: Divider(color: AppColors.borderSubtle, height: 1)),
          ],
        ),
      );
}

// UnreadBadgeCounter
/// Red badge for unread count on chat tile.
class UnreadBadgeCounter extends StatelessWidget {
  final int count;
  const UnreadBadgeCounter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: count > 99 ? 4 : 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18),
      decoration: BoxDecoration(
        color: AppColors.magenta,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
