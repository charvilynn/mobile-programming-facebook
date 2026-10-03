import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/core_providers.dart';
import '../widgets/chat_widgets.dart';

// ─── Real Chat Rooms Provider ────────────────────────────────────────────────
final chatRoomsProvider = FutureProvider.autoDispose<List<ChatRoom>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  try {
    int myId = 1;
    try {
      final meRes = await api.get('/users/me');
      final meData = meRes.data['data'] as Map<String, dynamic>?;
      if (meData != null) myId = meData['id'] as int? ?? 1;
    } catch (_) {}

    final res = await api.get('/chat/dm/threads');
    final list = res.data['data'] as List<dynamic>? ?? [];

    return list.map((item) {
      final t = item as Map<String, dynamic>;
      final partner = t['partner'] as Map<String, dynamic>? ?? {};
      final lastMsg = t['lastMessage'] as Map<String, dynamic>? ?? {};
      final unreadCount = t['unreadCount'] as int? ?? 0;

      final partnerId = partner['id'] as int? ?? 0;
      final partnerName =
          (partner['full_name'] ?? partner['username'] ?? 'Pengguna')
              .toString();
      final partnerAvatar = partner['avatar_url'] as String?;

      final msgId = lastMsg['id'] as int? ?? 0;
      final msgSenderId = lastMsg['sender_id'] as int? ?? 0;
      final msgText = (lastMsg['content'] ?? '').toString();
      final isRead = lastMsg['is_read'] as bool? ?? false;
      final createdAt =
          DateTime.tryParse(lastMsg['createdAt'] as String? ?? '') ??
          DateTime.now();

      return ChatRoom(
        id: partnerId,
        isGroup: false,
        participants: [
          ChatParticipant(id: myId, name: 'Saya'),
          ChatParticipant(
            id: partnerId,
            name: partnerName,
            avatarUrl: partnerAvatar,
          ),
        ],
        lastMessage: ChatMessage(
          id: msgId,
          senderId: msgSenderId,
          senderName: msgSenderId == myId ? 'Saya' : partnerName,
          text: msgText,
          isRead: isRead,
          sentAt: createdAt,
        ),
        unreadCount: unreadCount,
      );
    }).toList();
  } catch (_) {
    return [];
  }
});

// ─── ChatListScreen ───────────────────────────────────────────────────────────
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ChatRoom> _filterRooms(List<ChatRoom> rooms) {
    if (_searchQuery.trim().isEmpty) return rooms;
    final q = _searchQuery.toLowerCase();
    return rooms.where((r) {
      final name = r.isGroup
          ? (r.groupName ?? '')
          : r.participants.where((p) => p.id != 1).map((p) => p.name).join('');
      final lastMsg = r.lastMessage?.text ?? '';
      return name.toLowerCase().contains(q) ||
          lastMsg.toLowerCase().contains(q);
    }).toList();
  }

  void _showCreateGroupSheet(BuildContext ctx) {
    final nameCtrl = TextEditingController();
    final selectedIds = <int>{};
    List<ChatParticipant> friends = [];
    bool isLoadingFriends = true;
    bool hasFetched = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          if (!hasFetched) {
            hasFetched = true;
            Future.microtask(() async {
              try {
                final api = ref.read(apiClientProvider);
                final res = await api.get('/users/me/connections');
                final list = res.data['data'] as List<dynamic>? ?? [];
                final loaded = list.map((item) {
                  final u = item as Map<String, dynamic>;
                  final id = u['id'] as int? ?? 0;
                  final name = (u['full_name'] ?? u['username'] ?? 'Pengguna')
                      .toString();
                  final avatar = u['avatar_url'] as String?;
                  return ChatParticipant(id: id, name: name, avatarUrl: avatar);
                }).toList();
                if (sheetCtx.mounted) {
                  setSheetState(() {
                    friends = loaded;
                    isLoadingFriends = false;
                  });
                }
              } catch (_) {
                if (sheetCtx.mounted) {
                  setSheetState(() => isLoadingFriends = false);
                }
              }
            });
          }

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Buat Grup Baru',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: TextField(
                    controller: nameCtrl,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nama grup...',
                      hintStyle: AppTypography.bodyMd.copyWith(
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pilih Anggota',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: isLoadingFriends
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.cyan,
                            strokeWidth: 2,
                          ),
                        )
                      : friends.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              'Belum ada teman terhubung untuk ditambahkan ke grup.\nKirim permintaan pertemanan terlebih dahulu!',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: friends.length,
                          itemBuilder: (_, i) {
                            final f = friends[i];
                            final selected = selectedIds.contains(f.id);
                            final initial = f.name.isNotEmpty
                                ? f.name[0].toUpperCase()
                                : '?';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.cyan.withValues(
                                  alpha: 0.2,
                                ),
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    color: AppColors.cyan,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(
                                f.name,
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              trailing: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected
                                      ? AppColors.cyan
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.cyan
                                        : AppColors.borderSubtle,
                                    width: 2,
                                  ),
                                ),
                                child: selected
                                    ? Icon(
                                        Icons.check,
                                        size: 14,
                                        color: AppColors.bgDeep,
                                      )
                                    : null,
                              ),
                              onTap: () => setSheetState(() {
                                selected
                                    ? selectedIds.remove(f.id)
                                    : selectedIds.add(f.id);
                              }),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md + MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedIds.isEmpty
                          ? null
                          : () {
                              final name = nameCtrl.text.trim().isEmpty
                                  ? 'Grup Baru'
                                  : nameCtrl.text.trim();
                              Navigator.of(sheetCtx).pop();
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Grup "$name" berhasil dibuat!',
                                  ),
                                  backgroundColor: AppColors.bgCard,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        disabledBackgroundColor: AppColors.bgCard,
                        foregroundColor: AppColors.bgDeep,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        selectedIds.isEmpty
                            ? 'Pilih anggota dulu'
                            : 'Buat Grup (${selectedIds.length} anggota)',
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari percakapan...',
                  hintStyle: AppTypography.bodyMd.copyWith(
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text(
                'PaceChat',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearching
                ? IconButton(
                    key: const ValueKey('close'),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    tooltip: 'Tutup pencarian',
                    onPressed: () => setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchCtrl.clear();
                    }),
                  )
                : Row(
                    key: const ValueKey('actions'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.search_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _isSearching = true),
                        tooltip: 'Cari percakapan',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.group_add_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => _showCreateGroupSheet(context),
                        tooltip: 'Buat grup baru',
                      ),
                    ],
                  ),
          ),
        ],
      ),
      body: roomsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.cyan,
            strokeWidth: 2,
          ),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_outlined,
                color: AppColors.textMuted,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Gagal memuat chat',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => ref.refresh(chatRoomsProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: AppColors.bgDeep,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (rooms) {
          final filtered = _filterRooms(rooms);
          if (filtered.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      color: AppColors.textMuted,
                      size: 64,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Tidak ada percakapan yang cocok'
                          : 'Belum ada percakapan',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Coba kata kunci lain.'
                          : 'Mulai chat dengan teman atau buat grup baru.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            separatorBuilder: (_, __) =>
                Divider(color: AppColors.borderSubtle, height: 1, indent: 80),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final r = filtered[i];
              final partner = r.participants.firstWhere(
                (p) => p.name != 'Saya',
                orElse: () => r.participants.isNotEmpty
                    ? r.participants.first
                    : const ChatParticipant(id: 0, name: 'Pengguna'),
              );
              return ChatListTile(
                room: r,
                myUserId: 1,
                onTap: () {
                  if (r.isGroup) {
                    context.push('/chat/${r.id}');
                  } else {
                    final encodedName = Uri.encodeComponent(partner.name);
                    final encodedAvatar = partner.avatarUrl != null
                        ? Uri.encodeComponent(partner.avatarUrl!)
                        : '';
                    context.push(
                      '/chat/dm/${partner.id}?name=$encodedName&avatar=$encodedAvatar',
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ─── ChatRoomScreen ───────────────────────────────────────────────────────────
// Supports two modes:
//   1. DM mode (targetUserId > 0): direct message with a specific user
//   2. Room mode (roomId > 0): open an existing chat room
class ChatRoomScreen extends ConsumerStatefulWidget {
  final int roomId;
  final int targetUserId;
  final String? targetName;
  final String? targetAvatar;

  const ChatRoomScreen({
    super.key,
    this.roomId = 0,
    this.targetUserId = 0,
    this.targetName,
    this.targetAvatar,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int _myUserId = 1;

  bool get _isDmMode => widget.targetUserId > 0;

  String get _displayName {
    if (widget.targetName != null && widget.targetName!.isNotEmpty) {
      return widget.targetName!;
    }
    if (_isDmMode) return 'Pengguna';
    return 'Percakapan';
  }

  String get _displayInitial =>
      _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/users/me');
      final data = res.data['data'] as Map<String, dynamic>?;
      if (data != null) _myUserId = data['id'] as int? ?? 1;
    } catch (_) {}
    await _loadMessages();
    if (_isDmMode) {
      try {
        final api = ref.read(apiClientProvider);
        await api.patch('/chat/dm/${widget.targetUserId}/read');
        ref.invalidate(chatRoomsProvider);
      } catch (_) {}
    }
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    if (_isDmMode) {
      try {
        final api = ref.read(apiClientProvider);
        final res = await api.get('/chat/dm/${widget.targetUserId}/messages');
        final list = res.data['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _isLoading = false;
            _messages.clear();
            _messages.addAll(
              list.map((m) {
                final map = m as Map<String, dynamic>;
                final senderId = map['sender_id'] as int? ?? 0;
                final senderData = map['sender'] as Map<String, dynamic>?;
                final senderName =
                    senderData?['full_name'] as String? ?? 'Pengguna';
                return ChatMessage(
                  id: map['id'] as int? ?? 0,
                  senderId: senderId,
                  senderName: senderName,
                  text: map['content'] as String? ?? '',
                  isRead: map['is_read'] as bool? ?? false,
                  sentAt:
                      DateTime.tryParse(map['createdAt'] as String? ?? '') ??
                      DateTime.now(),
                );
              }),
            );
          });
          _scrollToBottom();
        }
      } catch (_) {
        // Empty conversation — no prior messages
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sendMessage(String text) async {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: _myUserId,
      senderName: 'Saya',
      text: text,
      isRead: false,
      sentAt: DateTime.now(),
    );
    setState(() => _messages.add(msg));
    _scrollToBottom();

    if (_isDmMode) {
      try {
        final api = ref.read(apiClientProvider);
        await api.post(
          '/chat/dm/${widget.targetUserId}/messages',
          data: {'content': text},
        );
        ref.invalidate(chatRoomsProvider);
      } catch (_) {}
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
              child: Text(
                _displayInitial,
                style: TextStyle(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isDmMode ? 'Pesan langsung' : 'Percakapan',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.call_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Fitur panggilan belum tersedia'),
                  backgroundColor: AppColors.bgCard,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.cyan,
                      strokeWidth: 2,
                    ),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Mulai percakapan dengan $_displayName',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final showDate =
                          i == 0 ||
                          !_isSameDay(_messages[i - 1].sentAt, msg.sentAt);
                      return Column(
                        children: [
                          if (showDate)
                            ChatDateSeparator(label: _dateLabel(msg.sentAt)),
                          ChatBubble(
                            message: msg,
                            isMine: msg.senderId == _myUserId,
                            showAvatar:
                                i == 0 ||
                                _messages[i - 1].senderId != msg.senderId,
                          ),
                        ],
                      );
                    },
                  ),
          ),
          ChatInputBar(onSend: _sendMessage),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── NotificationCenterScreen ─────────────────────────────────────────────────
class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  final Map<int, String> _actionStatuses = {};
  final Set<int> _loadingNotifs = {};

  Future<void> _acceptFriendRequest(
    int notifId,
    int actorId,
    String actorName,
  ) async {
    setState(() => _loadingNotifs.add(notifId));
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/users/$actorId/accept-connection');
      if (!mounted) return;
      setState(() {
        _actionStatuses[notifId] = 'accepted';
        _loadingNotifs.remove(notifId);
      });
      ref.invalidate(notificationsProvider);
      ref.invalidate(friendSuggestionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sekarang berteman dengan $actorName!'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingNotifs.remove(notifId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menerima permintaan: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectFriendRequest(
    int notifId,
    int actorId,
    String actorName,
  ) async {
    setState(() => _loadingNotifs.add(notifId));
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/users/$actorId/reject-connection');
      if (!mounted) return;
      setState(() {
        _actionStatuses[notifId] = 'rejected';
        _loadingNotifs.remove(notifId);
      });
      ref.invalidate(notificationsProvider);
      ref.invalidate(friendSuggestionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permintaan pertemanan dari $actorName dihapus'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingNotifs.remove(notifId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus permintaan: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifikasi',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final api = ref.read(apiClientProvider);
                await api.patch('/notifications/read-all');
                ref.invalidate(notificationsProvider);
              } catch (_) {}
            },
            child: Text(
              'Tandai semua dibaca',
              style: AppTypography.labelSm.copyWith(color: AppColors.cyan),
            ),
          ),
        ],
      ),
      body: notifsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.cyan,
            strokeWidth: 2,
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Gagal memuat notifikasi',
            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
          ),
        ),
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.textMuted,
                    size: 56,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Belum ada notifikasi',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Notifikasi tanda (tag), komentar, dan koneksi akan muncul di sini',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.cyan,
            backgroundColor: AppColors.bgCard,
            onRefresh: () async => ref.refresh(notificationsProvider),
            child: ListView.separated(
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.borderSubtle, height: 1),
              itemCount: notifs.length,
              itemBuilder: (_, i) {
                final n = notifs[i];
                final notifId = n['id'] as int? ?? 0;
                final actor = n['actor'] as Map<String, dynamic>?;
                final actorId =
                    (actor?['id'] ?? n['actor_id'] ?? n['reference_id'] ?? 0)
                        as int;
                final actorName =
                    (actor?['full_name'] ??
                            actor?['name'] ??
                            actor?['username'] ??
                            'Seseorang')
                        .toString();
                final actorAvatar = actor?['avatar_url'] as String?;
                final type = (n['type'] ?? 'system').toString();
                final bodyText =
                    (n['body'] ?? n['message'] ?? 'Notifikasi baru').toString();
                DateTime createdAt;
                try {
                  createdAt = DateTime.parse(n['createdAt'] ?? n['created_at']);
                } catch (_) {
                  createdAt = DateTime.now();
                }
                final isRead =
                    n['is_read'] as bool? ?? n['isRead'] as bool? ?? false;
                final actionStatus = _actionStatuses[notifId];
                final isActionLoading = _loadingNotifs.contains(notifId);

                return NotificationTile(
                  type: type,
                  actorName: actorName,
                  actorAvatar: actorAvatar,
                  text: bodyText,
                  createdAt: createdAt,
                  isRead: isRead,
                  actionStatus: actionStatus,
                  isActionLoading: isActionLoading,
                  onAccept:
                      (type == 'friend_request' ||
                              type == 'connection_request') &&
                          actorId > 0
                      ? () => _acceptFriendRequest(notifId, actorId, actorName)
                      : null,
                  onReject:
                      (type == 'friend_request' ||
                              type == 'connection_request') &&
                          actorId > 0
                      ? () => _rejectFriendRequest(notifId, actorId, actorName)
                      : null,
                  onTap: () async {
                    if (!isRead) {
                      try {
                        final api = ref.read(apiClientProvider);
                        await api.patch('/notifications/$notifId/read');
                        ref.invalidate(notificationsProvider);
                      } catch (_) {}
                    }
                    if (type == 'friend_request' ||
                        type == 'connection_request' ||
                        type == 'connection_accepted') {
                      if (actorId > 0) context.push('/profile/$actorId');
                    } else if (n['reference_id'] != null &&
                        (type == 'post_tag' || type.startsWith('post_'))) {
                      context.push('/post/${n['reference_id']}');
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
